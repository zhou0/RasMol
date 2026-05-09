import re

with open('CMakeLists.txt', 'r') as f:
    content = f.read()

# Add CMP0169 policy setting
policy_block = """if(POLICY CMP0169)
  cmake_policy(SET CMP0169 OLD)
endif()
"""

if 'CMP0169' not in content:
    content = content.replace(
        'if(POLICY CMP0135)',
        policy_block + '\nif(POLICY CMP0135)'
    )

with open('CMakeLists.txt', 'w') as f:
    f.write(content)
