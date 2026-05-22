import os
import re

def fix_content(content):
    # Fix the messed up intro layout that was converted to two-col-list
    # It looks like: <div class="two-col-list"><div class="term"><ul>...</ul></div><div>...logo...<ul>...</ul></div></div>

    pattern = re.compile(r'<div class="two-col-list"><div class="term">(.*?)<ul>(.*?)</ul>(.*?)</div><div>(.*?)<img([^>]*?)rasmollogo\.jpg([^>]*?)>(.*?)<ul>(.*?)</ul>(.*?)</div></div>', re.DOTALL | re.IGNORECASE)

    def sub(m):
        cyan_content = m.group(1) + "<ul>" + m.group(2) + "</ul>" + m.group(3)
        logo_html = f"<img{m.group(5)}rasmollogo.jpg{m.group(6)}>"
        yellow_content = m.group(7) + "<ul>" + m.group(8) + "</ul>" + m.group(9)

        return f"""
<div class="intro-flex">
  <div class="intro-box bg-cyan">
    {cyan_content.strip()}
  </div>
  <div class="intro-logo">
    {logo_html}
  </div>
  <div class="intro-box bg-yellow">
    {yellow_content.strip()}
  </div>
</div>
"""
    return pattern.sub(sub, content)

for filename in os.listdir('docs'):
    if filename.endswith('.html') or filename.endswith('.shtml'):
        filepath = os.path.join('docs', filename)
        with open(filepath, 'r') as f:
            content = f.read()
        new_content = fix_content(content)
        if new_content != content:
            with open(filepath, 'w') as f:
                f.write(new_content)
            print(f"Fixed intro layout in {filename}")
