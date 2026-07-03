#!/usr/bin/env python3
"""Simultaneous turns: do not disable when only AI is nearby (HoMM Olden Era)."""
from __future__ import annotations

import hashlib
import shutil
import sys
from pathlib import Path

PATCH_DIR = Path(__file__).resolve().parent
PATCH_RVAS = (0x22F6D00, 0x22F7310, 0x22F7B80)
OLD_REL_BYTE = 0xBD
NEW_REL_BYTE = 0xB7
PATCH_VERSION = "1.0.0"


def find_game_root() -> Path:
    candidates = [
        PATCH_DIR.parent,
        PATCH_DIR,
        Path.cwd(),
    ]
    for root in candidates:
        if (root / "GameAssembly.dll").is_file() and (root / "HeroesOldenEra.exe").is_file():
            return root.resolve()
    raise FileNotFoundError(
        "Не найдена папка игры.\n"
        "Скопируйте папку SimTurnsAI_Patch в корень игры (рядом с HeroesOldenEra.exe) "
        "и запустите УСТАНОВИТЬ.bat"
    )


def rva_to_offset(rva: int) -> int:
    return 0x400 + (rva - 0x1000)


def file_sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def paths(game_root: Path) -> tuple[Path, Path, Path]:
    return (
        game_root / "GameAssembly.dll",
        game_root / "GameAssembly.dll.simturns_backup",
        game_root / "SimTurnsAI_Patch.installed",
    )


def read_patch_site(data: bytearray, rva: int) -> tuple[int, bytes]:
    offset = rva_to_offset(rva)
    pattern = bytes([0x83, 0x78, 0x24, 0x01, 0x0F, 0x84])
    site = bytes(data[offset : offset + 10])
    if site[:6] != pattern:
        raise ValueError(
            f"Неожиданные байты в GameAssembly.dll (RVA 0x{rva:X}). "
            f"Возможно, другая версия игры: {site.hex()}"
        )
    return offset + 6, site


def ensure_backup(dll: Path, backup: Path) -> None:
    if backup.exists():
        return
    shutil.copy2(dll, backup)


def write_marker(marker: Path, game_root: Path, dll: Path) -> None:
    marker.write_text(
        f"version={PATCH_VERSION}\n"
        f"game={game_root}\n"
        f"sha256_patched={file_sha256(dll)}\n",
        encoding="utf-8",
    )


def apply() -> None:
    game_root = find_game_root()
    dll, backup, marker = paths(game_root)
    ensure_backup(dll, backup)
    data = bytearray(dll.read_bytes())
    changed = 0

    for rva in PATCH_RVAS:
        rel_offset, _ = read_patch_site(data, rva)
        if data[rel_offset] == NEW_REL_BYTE:
            print(f"  Уже пропатчено: RVA 0x{rva:X}")
            continue
        if data[rel_offset] != OLD_REL_BYTE:
            raise ValueError(
                f"Патч не подходит к этой версии GameAssembly.dll (RVA 0x{rva:X}). "
                f"Обновите игру и проверьте, вышла ли новая версия патча."
            )
        data[rel_offset] = NEW_REL_BYTE
        changed += 1
        print(f"  Пропатчено: RVA 0x{rva:X}")

    if changed == 0:
        print("Патч уже установлен.")
    else:
        dll.write_bytes(data)
        print(f"Готово. Изменено мест: {changed}.")

    write_marker(marker, game_root, dll)
    print(f"Игра: {game_root}")
    print(f"SHA-256 GameAssembly.dll: {file_sha256(dll)}")


def restore() -> None:
    game_root = find_game_root()
    dll, backup, marker = paths(game_root)
    if not backup.exists():
        raise FileNotFoundError(f"Резервная копия не найдена: {backup}")
    shutil.copy2(backup, dll)
    if marker.exists():
        marker.unlink()
    print("Оригинальный GameAssembly.dll восстановлен.")


def status() -> None:
    game_root = find_game_root()
    dll, backup, marker = paths(game_root)
    data = dll.read_bytes()
    states = []
    for rva in PATCH_RVAS:
        rel_offset, _ = read_patch_site(bytearray(data), rva)
        b = data[rel_offset]
        if b == NEW_REL_BYTE:
            states.append("OK (патч)")
        elif b == OLD_REL_BYTE:
            states.append("нет патча")
        else:
            states.append(f"неизвестно (0x{b:02X})")
    print(f"Игра: {game_root}")
    print("Статус:", ", ".join(states))
    print(f"Резервная копия: {'есть' if backup.exists() else 'нет'}")
    print(f"Маркер установки: {'есть' if marker.exists() else 'нет'}")
    if all(s.startswith("OK") for s in states):
        print("Вердикт: патч УСТАНОВЛЕН")
    elif all(s == "нет патча" for s in states):
        print("Вердикт: патч НЕ установлен (ванильная игра)")
    else:
        print("Вердикт: частичный или битый патч — запустите ОТКАТ, потом УСТАНОВИТЬ")


def main() -> int:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "apply"
    try:
        if cmd == "apply":
            apply()
        elif cmd == "restore":
            restore()
        elif cmd == "status":
            status()
        else:
            print("Использование: apply_patch.py [apply|restore|status]")
            return 1
    except Exception as exc:
        print(f"ОШИБКА: {exc}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
