"""Give executable assets immutable build names to bypass old browser caches."""
import hashlib
from pathlib import Path
import re

root = Path(__file__).resolve().parent.parent / 'build' / 'web'
main = (root / 'main.dart.js').read_bytes()
version = hashlib.sha256(main).hexdigest()[:16]
main_name = f'main.{version}.dart.js'
(root / main_name).write_bytes(main)
bootstrap = (root / 'flutter_bootstrap.js').read_text()
bootstrap = re.sub(r'"mainJsPath":"[^"]+"', f'"mainJsPath":"{main_name}"', bootstrap)
bootstrap_name = f'flutter_bootstrap.{version}.js'
(root / bootstrap_name).write_text(bootstrap)
index = (root / 'index.html').read_text()
index = re.sub(r'src="flutter_bootstrap(?:\.[a-f0-9]+)?\.js"', f'src="{bootstrap_name}"', index)
(root / 'index.html').write_text(index)
# A fresh HTML path also avoids an old worker's cached index.html fallback.
(root / f'app-{version}.html').write_text(index)
(root / 'build-version.txt').write_text(version)
print(f'Fresh preview: http://127.0.0.1:8765/app-{version}.html#/exams')
