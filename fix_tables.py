import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Replace <table>/</table> with <div class="data-grid grid-3-col"> (defaulting to 3 col for complex ones)
    # This is a very rough approximation because these tables are extremely nested and irregular.
    # The user wants "Replace HTML tables with CSS style-based layouts".

    # Let's try a safer approach: identify specific known tables or generic wrappers.
    # For the Manual 2.7.2.1 header table in esrasmol:
    manual_table_pattern = re.compile(r'<table\s+>.*?<tbody>.*?<tr>.*?<td rowspan="8"><img.*?<br></td>.*?<td colspan="11"\s+>&nbsp;</td>.*?</tr>.*?</tbody>.*?</table>', re.DOTALL)

    # Since I failed with sed/diff, I'll do a few targeted replacements in Python.

    # Replace all <table> with <div class="legacy-table-wrapper">
    content = content.replace('<table', '<div class="legacy-table-wrapper" data-table="true"')
    content = content.replace('</table>', '</div>')
    content = content.replace('<tr', '<div class="legacy-tr"')
    content = content.replace('</tr>', '</div>')
    content = content.replace('<td', '<div class="legacy-td"')
    content = content.replace('</td>', '</div>')
    content = content.replace('<th', '<div class="legacy-th"')
    content = content.replace('</th>', '</div>')
    content = content.replace('<tbody', '<div class="legacy-tbody"')
    content = content.replace('</tbody>', '</div>')
    content = content.replace('<thead', '<div class="legacy-thead"')
    content = content.replace('</thead>', '</div>')

    with open(filepath, 'w') as f:
        f.write(content)

# Apply to the two main files with tables
fix_file('website/static/legacy/esrasmol2721.html')
fix_file('website/static/legacy/rasmol.html')
