import os

files = ['src/rasmol.h', 'src/molecule.c', 'src/multiple.c', 'src/vector.c', 'src/command.c']
for f in files:
    os.system(f"git checkout {f}")
