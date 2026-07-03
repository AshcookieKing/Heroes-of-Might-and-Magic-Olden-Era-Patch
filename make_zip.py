import zipfile
from pathlib import Path

game = Path(r"d:\Heroes of Might and Magic - Olden Era")
src = game / "SimTurnsAI_Patch"
out = game / "SimTurnsAI_Patch_v1.0.0.zip"

SKIP = {
    "BUILD_ZIP.bat", "BUILD_SETUP.bat", "make_zip.py",
    "installer.iss", "СОБРАТЬ_ZIP_ДЛЯ_ДРУЗЕЙ.bat",
}

with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
    for path in sorted(src.rglob("*")):
        if path.is_file() and path.name not in SKIP:
            zf.write(path, Path("SimTurnsAI_Patch") / path.relative_to(src))

print(f"Created: {out}")
print(f"Size: {out.stat().st_size:,} bytes")
