import fnmatch
import json
from pathlib import Path
import unittest


class HostingCacheTests(unittest.TestCase):
    def cache(self, path):
        config = json.loads((Path(__file__).resolve().parents[1] / 'firebase.json').read_text())
        result = None
        for rule in config['hosting']['headers']:
            if fnmatch.fnmatchcase(path, rule['source']):
                for header in rule['headers']:
                    if header['key'].lower() == 'cache-control':
                        result = header['value']
        return result

    def test_only_versioned_executables_are_immutable(self):
        for path in ['/main.1234567890abcdef.dart.js']:
            self.assertIn('immutable', self.cache(path))
        for path in ['/main.dart.js', '/flutter_bootstrap.js', '/flutter_bootstrap.1234567890abcdef.js', '/assets/exams/catalog.json']:
            self.assertNotIn('immutable', self.cache(path))
            self.assertIn('must-revalidate', self.cache(path))

    def test_entry_and_identity_pages_remain_fresh(self):
        for path in ['/', '/index.html', '/app-1234567890abcdef.html', '/build-version.txt', '/__/auth/handler']:
            self.assertIn('no-store', self.cache(path))

    def test_fonts_can_be_conditionally_reused(self):
        cache = self.cache('/assets/packages/flutter_math_fork/lib/katex_fonts/KaTeX_Main-Regular.ttf')
        self.assertNotIn('no-store', cache)
        self.assertIn('max-age=0', cache)


if __name__ == '__main__':
    unittest.main()
