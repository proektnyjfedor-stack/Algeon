"""Validate and copy a Flutter release without stale entries or iCloud duplicates."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import tempfile

GENERATED_ENTRY = re.compile(r'(?:app-[0-9a-f]{16}\.html|main\.[0-9a-f]{16}\.dart\.js|flutter_bootstrap\.[0-9a-f]{16}\.js)')
DUPLICATE = re.compile(r' \d+(?=\.|$)')


def included(relative, version):
    if any(DUPLICATE.search(part) for part in relative.parts):
        return False
    if len(relative.parts) == 1 and GENERATED_ENTRY.fullmatch(relative.name):
        return relative.name in {f'app-{version}.html', f'main.{version}.dart.js', f'flutter_bootstrap.{version}.js'}
    return True


def validate_release(root, project):
    version = (root / 'build-version.txt').read_text().strip()
    if not re.fullmatch(r'[0-9a-f]{16}', version):
        raise ValueError('Invalid build version')
    main = (root / 'main.dart.js').read_bytes()
    if hashlib.sha256(main).hexdigest()[:16] != version:
        raise ValueError('Build version does not match compiled JavaScript')
    if (root / f'main.{version}.dart.js').read_bytes() != main:
        raise ValueError('Versioned JavaScript differs from compiled JavaScript')
    bootstrap = (root / f'flutter_bootstrap.{version}.js').read_text()
    if f'"mainJsPath":"main.{version}.dart.js"' not in bootstrap:
        raise ValueError('Bootstrap points at the wrong JavaScript')
    index = (root / 'index.html').read_bytes()
    if f'flutter_bootstrap.{version}.js'.encode() not in index:
        raise ValueError('HTML points at the wrong bootstrap')
    if (root / f'app-{version}.html').read_bytes() != index:
        raise ValueError('Versioned HTML differs from index.html')
    if not (root / 'assets/AssetManifest.bin').is_file():
        raise ValueError('Flutter asset manifest is missing')
    for folder in ['assets/exams', 'assets/sounds']:
        for asset in (project / folder).rglob('*'):
            if not asset.is_file():
                continue
            relative = asset.relative_to(project)
            if any(DUPLICATE.search(part) for part in relative.parts):
                continue
            copy = root / 'assets' / relative
            if not copy.is_file() or copy.read_bytes() != asset.read_bytes():
                raise ValueError(f'Missing or modified asset: {relative}')
    return version


def prepare_release(source, destination, project):
    source, destination, project = map(lambda p: Path(p).resolve(), [source, destination, project])
    if source == destination or source in destination.parents or destination in source.parents:
        raise ValueError('Source and destination must be separate directories')
    # Replacing generated build/web is allowed; unrelated existing directories
    # are never cleared, even if a caller supplies the wrong output argument.
    if destination.exists() and destination != project / 'build/web' and any(destination.iterdir()):
        raise ValueError('Output already contains files; choose an empty directory')
    version = validate_release(source, project)
    destination.parent.mkdir(parents=True, exist_ok=True)
    staging = Path(tempfile.mkdtemp(prefix='.algeon-web-', dir=destination.parent))
    previous = None
    try:
        count = 0
        for path in source.rglob('*'):
            if not path.is_file():
                continue
            relative = path.relative_to(source)
            if not included(relative, version):
                continue
            target = staging / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)
            count += 1
        validate_release(staging, project)
        if destination.exists():
            previous = Path(tempfile.mkdtemp(prefix='.algeon-old-web-', dir=destination.parent))
            previous.rmdir()
            destination.rename(previous)
        try:
            staging.rename(destination)
        except Exception:
            if previous is not None:
                previous.rename(destination)
                previous = None
            raise
        if previous is not None:
            shutil.rmtree(previous)
        return version, count
    finally:
        if staging.exists():
            shutil.rmtree(staging)


def main():
    project = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=project / 'build/web')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--firebase-config', action='store_true', help='Write a hosting-only firebase.json beside the output')
    args = parser.parse_args()
    if args.firebase_config:
        config_path = args.output.resolve().parent / 'firebase.json'
        if config_path.exists():
            raise ValueError('Refusing to overwrite an existing Firebase configuration')
    version, count = prepare_release(args.source, args.output, project)
    if args.firebase_config:
        hosting = json.loads((project / 'firebase.json').read_text())['hosting']
        hosting['public'] = str(args.output.resolve())
        config_path.write_text(json.dumps({'hosting': hosting}, indent=2))
    print(f'Release {version}: {count} verified files in {args.output.resolve()}')


if __name__ == '__main__':
    main()
