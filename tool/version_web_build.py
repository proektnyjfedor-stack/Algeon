"""Give executable assets immutable names to bypass old browser caches."""
import argparse
import hashlib
from pathlib import Path
import re


def version_build(root):
    root = Path(root)
    main = (root / 'main.dart.js').read_bytes()
    version = hashlib.sha256(main).hexdigest()[:16]
    main_name = f'main.{version}.dart.js'
    bootstrap, count = re.subn(r'"mainJsPath":"[^"]+"', f'"mainJsPath":"{main_name}"',
                              (root / 'flutter_bootstrap.js').read_text())
    if count != 1:
        raise ValueError('Expected one JavaScript entry in Flutter bootstrap')
    bootstrap_name = f'flutter_bootstrap.{version}.js'
    index, count = re.subn(r'src="flutter_bootstrap(?:\.[a-f0-9]+)?\.js"',
                          f'src="{bootstrap_name}"', (root / 'index.html').read_text())
    if count != 1:
        raise ValueError('Expected one Flutter bootstrap script in index.html')
    (root / main_name).write_bytes(main)
    (root / bootstrap_name).write_text(bootstrap)
    (root / 'index.html').write_text(index)
    (root / f'app-{version}.html').write_text(index)
    (root / 'build-version.txt').write_text(version)
    return version


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--web-root', type=Path, default=Path(__file__).resolve().parent.parent / 'build/web')
    args = parser.parse_args()
    version = version_build(args.web_root)
    print(f'Fresh preview: http://127.0.0.1:8765/app-{version}.html#/exams')
