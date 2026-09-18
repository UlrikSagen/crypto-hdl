from pathlib import Path
from vunit import VUnit

ROOT = Path(__file__).parent

vu = VUnit.from_argv(compile_builtins=False)
vu.add_vhdl_builtins()
vu.set_compile_option("ghdl.a_flags", ["--std=08", "-Wno-hide"])

crypto = vu.add_library("crypto")
crypto.add_source_files(ROOT / "rtl" / "**" / "*.vhd")

tb = vu.add_library("tb")
tb.add_source_files(ROOT / "tb" / "**" / "*.vhd")

vu.main()