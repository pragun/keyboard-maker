import kiutils
from kiutils.libraries import *
from pathlib import Path

config_path = "/home/pragun/.config/kicad/8.0"
fp_path = Path(config_path,'fp-lib-table')
sym_path = Path(config_path,'sym-lib-table')
 

fp_lib =  LibTable.from_file(f"{fp_path}")


print("---\n")
print(fp_lib)

for i in fp_lib.libs:
	print(i)

print("---\n\n\n")

sym_lib = LibTable.from_file(f"{sym_path}")

print(sym_lib)
for i in sym_lib.libs:
	print(i)




