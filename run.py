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

tb.test_bench("tb_sha256_pkg").set_generic("vector_file", str(ROOT / "vectors" / "sha256_pkg_functions.txt"))

vu.main()