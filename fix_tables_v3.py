import os
import re

def fix_file(filepath):
    if not os.path.exists(filepath): return
    with open(filepath, 'r') as f:
        content = f.read()

    # Case-insensitive replacement for table tags
    content = re.sub(r'<table', '<div class="legacy-table-wrapper"', content, flags=re.IGNORECASE)
    content = re.sub(r'</table>', '</div>', content, flags=re.IGNORECASE)
    content = re.sub(r'<tr', '<div class="legacy-tr"', content, flags=re.IGNORECASE)
    content = re.sub(r'</tr>', '</div>', content, flags=re.IGNORECASE)
    content = re.sub(r'<td', '<div class="legacy-td"', content, flags=re.IGNORECASE)
    content = re.sub(r'</td>', '</div>', content, flags=re.IGNORECASE)
    content = re.sub(r'<th', '<div class="legacy-th"', content, flags=re.IGNORECASE)
    content = re.sub(r'</th>', '</div>', content, flags=re.IGNORECASE)
    content = re.sub(r'<tbody', '<div class="legacy-tbody"', content, flags=re.IGNORECASE)
    content = re.sub(r'</tbody>', '</div>', content, flags=re.IGNORECASE)
    content = re.sub(r'<thead', '<div class="legacy-thead"', content, flags=re.IGNORECASE)
    content = re.sub(r'</thead>', '</div>', content, flags=re.IGNORECASE)

    with open(filepath, 'w') as f:
        f.write(content)

for filename in ['esrasmol2721.html', 'rasmol.html', 'notice.html', 'readme.html', 'install.html', 'changelog.html', 'todo.html', 'history.html']:
    fix_file(os.path.join('website/static/legacy', filename))
