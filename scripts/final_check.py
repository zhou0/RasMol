import os
import re

docs_dir = 'docs'
files = [f for f in os.listdir(docs_dir) if f.endswith(('.html', '.shtml', '.htm'))]

for filename in files:
    filepath = os.path.join(docs_dir, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    issues = []
    if filename != filename.lower():
        issues.append("Filename not lowercase")
    if 'OpenRasMol' in content:
        issues.append("Contains OpenRasMol")
    if 'openrasmol.org' in content:
        issues.append("Contains openrasmol.org")
    if re.search(r'\sstyle\s*=', content, re.I):
        issues.append("Contains inline style attribute")
    if '<style' in content.lower():
        issues.append("Contains <style> tag")
    if '<!DOCTYPE html>' not in content:
        issues.append("Missing DOCTYPE")
    if '<html lang="en">' not in content:
        issues.append("Missing lang='en'")

    # Check landmarks
    for landmark in ['<header>', '<nav', '<main>', '<footer>']:
        if landmark not in content:
            issues.append(f"Missing {landmark}")

    # Check image alt
    imgs = re.findall(r'<img[^>]*>', content, re.S|re.I)
    for img in imgs:
        if 'alt=' not in img.lower():
            issues.append(f"Image missing alt: {img.strip()}")

    if issues:
        print(f"File: {filename}")
        for issue in issues:
            print(f"  - {issue}")

print("Check finished.")
