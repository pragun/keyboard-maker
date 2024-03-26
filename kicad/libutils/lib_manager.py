from kiutils.libraries import *
from pathlib import Path
import argparse

config_path = "/home/pragun/.config/kicad/8.0"

sym_path = Path(config_path,'sym-lib-table')
sym_lib = LibTable.from_file(f"{sym_path}")


def add_footprint_library(args):
    fp_path = Path(config_path,'fp-lib-table')
    fp_table =  LibTable.from_file(f"{fp_path}")
    new_lib = Library(name=args.name,uri=args.path)
    fp_table.libs.append(new_lib)
    fp_table.to_file(f"{fp_path}")
    print(f"Footprint library {args.name} added successfully.")

def add_symbol_library(args):
    sym_path = Path(config_path,'sym-lib-table')
    sym_table = LibTable.from_file(f"{sym_path}")
    new_lib = Library(name=args.name,uri=args.path)
    sym_table.libs.append(new_lib)
    sym_table.to_file(f"{sym_path}")
    print(f"Symbol library {args.name} added successfully.")

def main():
    parser = argparse.ArgumentParser(description="Tool to add footprint and symbol libraries to KiCad's default global config.")
    subparsers = parser.add_subparsers(help='Sub-command help')

    # Sub-command for adding footprint libraries
    parser_fp = subparsers.add_parser('add-fp', help='Add a footprint library')
    parser_fp.add_argument('--name', type=str, help='Name of the footprint library', required=True)
    parser_fp.add_argument('--path', type=str, help='Path to the footprint library file', required=True)
    parser_fp.set_defaults(func=add_footprint_library)

    # Sub-command for adding symbol libraries
    parser_sym = subparsers.add_parser('add-sym', help='Add a symbol library')
    parser_sym.add_argument('--name', type=str, help='Name of the symbol library', required=True)
    parser_sym.add_argument('--path', type=str, help='Path to the symbol library file', required=True)
    parser_sym.set_defaults(func=add_symbol_library)

    args = parser.parse_args()

    if hasattr(args, 'func'):
        args.func(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()

