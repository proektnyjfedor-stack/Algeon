import tempfile
import unittest
from unittest import mock
from pathlib import Path
from version_web_build import version_build
from prepare_web_release import prepare_release, validate_release


class WebReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.project = Path(self.temporary.name) / 'project'
        self.source = Path(self.temporary.name) / 'compiled'
        self.output = self.project / 'build/web'
        self.source.mkdir()
        (self.source / 'main.dart.js').write_text('compiled application')
        (self.source / 'flutter_bootstrap.js').write_text('{"mainJsPath":"main.dart.js"}')
        (self.source / 'index.html').write_text('<script src="flutter_bootstrap.js"></script>')
        (self.source / 'assets').mkdir()
        (self.source / 'assets/AssetManifest.bin').write_bytes(b'manifest')
        for name in ['assets/exams/catalog.json', 'assets/sounds/right.wav']:
            asset = self.project / name
            asset.parent.mkdir(parents=True, exist_ok=True)
            asset.write_text('asset')
            copy = self.source / 'assets' / name
            copy.parent.mkdir(parents=True, exist_ok=True)
            copy.write_bytes(asset.read_bytes())
        self.version = version_build(self.source)

    def test_keeps_current_release_and_removes_duplicates(self):
        old = '0' * 16
        for name in [f'app-{old}.html', f'main.{old}.dart.js', f'flutter_bootstrap.{old}.js', 'index 2.html', 'assets/old 3.png']:
            (self.source / name).write_text('stale')
        version, count = prepare_release(self.source, self.output, self.project)
        self.assertEqual(version, self.version)
        self.assertEqual(validate_release(self.output, self.project), version)
        self.assertFalse((self.output / f'app-{old}.html').exists())
        self.assertFalse((self.output / 'index 2.html').exists())
        self.assertFalse((self.output / 'assets/old 3.png').exists())
        self.assertGreater(count, 5)

    def test_missing_assets_do_not_replace_previous_build(self):
        prepare_release(self.source, self.output, self.project)
        (self.output / 'previous.txt').write_text('keep')
        (self.source / 'assets/assets/exams/catalog.json').unlink()
        with self.assertRaises(ValueError):
            prepare_release(self.source, self.output, self.project)
        self.assertEqual((self.output / 'previous.txt').read_text(), 'keep')

    def test_failed_directory_swap_restores_previous_build(self):
        prepare_release(self.source, self.output, self.project)
        (self.output / 'previous.txt').write_text('keep')
        rename = Path.rename

        def fail_new_directory(path, target):
            if path.name.startswith('.algeon-web-'):
                raise OSError('Simulated filesystem failure')
            return rename(path, target)

        with mock.patch.object(Path, 'rename', fail_new_directory):
            with self.assertRaises(OSError):
                prepare_release(self.source, self.output, self.project)
        self.assertEqual((self.output / 'previous.txt').read_text(), 'keep')
        self.assertEqual(validate_release(self.output, self.project), self.version)

    def test_modified_javascript_is_rejected(self):
        (self.source / 'main.dart.js').write_text('wrong build')
        with self.assertRaises(ValueError):
            prepare_release(self.source, self.output, self.project)
        self.assertFalse(self.output.exists())

    def test_broken_entry_is_rejected(self):
        (self.source / f'flutter_bootstrap.{self.version}.js').write_text('wrong entry')
        with self.assertRaises(ValueError):
            prepare_release(self.source, self.output, self.project)

    def test_unrelated_directory_is_never_replaced(self):
        unrelated = self.project / 'my-files'
        unrelated.mkdir()
        (unrelated / 'important.txt').write_text('keep')
        with self.assertRaises(ValueError):
            prepare_release(self.source, unrelated, self.project)
        self.assertEqual((unrelated / 'important.txt').read_text(), 'keep')

    def test_overlapping_paths_are_rejected(self):
        with self.assertRaises(ValueError):
            prepare_release(self.source, self.source / 'nested', self.project)

    def test_versioning_requires_a_bootstrap_entry(self):
        (self.source / 'index.html').write_text('not a Flutter page')
        with self.assertRaises(ValueError):
            version_build(self.source)

    def test_repeated_versioning_keeps_the_same_entry(self):
        self.assertEqual(version_build(self.source), self.version)
        self.assertEqual(validate_release(self.source, self.project), self.version)


if __name__ == '__main__':
    unittest.main()
