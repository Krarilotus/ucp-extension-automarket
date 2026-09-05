"""Run the LuaJIT regression suite from the repository root (pip install lupa)."""
from pathlib import Path
import os
from lupa.luajit21 import LuaRuntime

root = Path(__file__).resolve().parents[1]
os.chdir(root)
LuaRuntime().execute((root / "tests/test_automarket.lua").read_text())
