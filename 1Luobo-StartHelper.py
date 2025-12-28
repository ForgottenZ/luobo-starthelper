#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

VERSION = "v3.0.0.PEAK.20251228"
BASE_URL = "https://globalcdn.luoboo.top/static/peak-mods/"
GAME = "PEAK"
MOD_DIR = Path("BepInEx") / "plugins"
GAME_MAIN = "StardewModdingAPI.exe"

DEBUG = False
DEBUG_DONOTDELETE = False
DEBUG_UPDATE = True
STEAM_CHECK_BYPASS = True
ENV_CHECK_BYPASS = True

SCRIPT_DIR = Path(__file__).resolve().parent
NAME = f"Luobo {GAME}模组同步器"
TEMP_DIR = SCRIPT_DIR / "temp_mods_update"

SEVEN_ZIP_FILES = [
    "7z.exe",
    "7z.dll",
    "7z.sfx",
    "7-zip.dll",
]


def set_title(title: str) -> None:
    if os.name == "nt":
        os.system(f"title {title}")


def print_error(lines: list[str]) -> None:
    print("-----------ERROR-----------")
    for line in lines:
        print(line)
    print("-----------ERROR-----------")


def download_file(url: str, dest: Path) -> bool:
    try:
        dest.parent.mkdir(parents=True, exist_ok=True)
        with urllib.request.urlopen(url) as response, dest.open("wb") as file_handle:
            shutil.copyfileobj(response, file_handle)
    except Exception as exc:  # noqa: BLE001
        print(f"Download failed: {url}")
        print(exc)
        return False
    return True


def ensure_7zip() -> bool:
    if all((SCRIPT_DIR / name).exists() for name in SEVEN_ZIP_FILES):
        return True

    print("未找到7z.exe，正在从服务器获取...")
    base = f"{BASE_URL}/7-Zip-P6cq1JVf"
    for name in SEVEN_ZIP_FILES:
        if not download_file(f"{base}/{name}", SCRIPT_DIR / name):
            print_error(
                [
                    "启动游戏失败。 请检查你的网络或稍后重试。Errorcode=2",
                    "Failed to download 7z.exe file.",
                ]
            )
            return False
    return True


def parse_version_clean(version: str) -> int:
    version = version.strip()
    if version.startswith("v"):
        version = version[1:]
    parts = version.split(".")
    clean = "".join(parts[:3])
    try:
        return int(clean)
    except ValueError:
        return 0


def check_for_updates() -> None:
    if os.environ.get("UPDATED", "").lower() == "true":
        print("发现已进行更新。跳过校验。")
        return

    print("Checking for updates...  正在校验更新...")
    launcher_path = SCRIPT_DIR / "Launcher"
    if not download_file(f"{BASE_URL}/Launcher", launcher_path):
        return

    now_version = None
    with launcher_path.open("r", encoding="utf-8", errors="ignore") as handle:
        for line in handle:
            now_version = line.strip()
            break

    if not now_version:
        return

    now_clean = parse_version_clean(now_version)
    current_clean = parse_version_clean(VERSION)

    if DEBUG:
        print(f"[DEBUG] Now_version={now_version}")
        print(f"[DEBUG] version={VERSION}")
        print(f"[DEBUG] Now_version_clean={now_clean}")
        print(f"[DEBUG] version_clean={current_clean}")

    if now_clean < current_clean:
        print(f"服务器版本 [{now_version}] 比当前 [{VERSION}] 更旧，跳过更新。")
        time.sleep(3)
        return

    if now_clean > current_clean:
        print(f"检测到新版本 [{now_version}]（当前 [{VERSION}]），正在更新...")
        time.sleep(5)
        script_path = Path(__file__).resolve()
        update_path = script_path.with_suffix(script_path.suffix + ".new")
        if download_file(f"{BASE_URL}/{script_path.name}", update_path):
            try:
                os.replace(update_path, script_path)
            except OSError as exc:
                print("更新失败，无法替换当前脚本。")
                print(exc)
                return
            env = os.environ.copy()
            env["UPDATED"] = "true"
            subprocess.Popen([sys.executable, str(script_path)], env=env)
            sys.exit(0)
    else:
        print(f"当前版本 [{VERSION}] 已是最新，无需更新。")
        time.sleep(3)


def validate_environment() -> bool:
    if ENV_CHECK_BYPASS:
        return True

    env_1 = 0
    if not (SCRIPT_DIR / "StardewModdingAPI.exe").exists():
        env_1 = 1
    if not (SCRIPT_DIR / "Stardew Valley.exe").exists():
        env_1 = int(f"{env_1}2")

    if env_1 == 1:
        print_error(
            [
                "启动游戏失败。你没有安装SMAPI。这是启动模组所必需的。",
                "按下回车键来打开默认浏览器下载SMAPI。",
                "SMAPI not found, please install SMAPI first.",
            ]
        )
        input()
        if os.name == "nt":
            os.startfile("https://smapi.io/")
        input()
        return False

    if env_1 == 2:
        print_error(["未找到游戏本体。", "Stardew Valley.exe not found."])
        input()
        return False

    if env_1 == 12:
        print_error(["未找到游戏本体和SMAPI。尝试更换启动器位置。", "Stardew Valley.exe not found."])
        input()
        return False

    return True


def extract_mod(download_file: Path, target_dir: Path, ext: str) -> bool:
    seven_zip = SCRIPT_DIR / "7z.exe"
    if ext.lower() in {".zip", ".7z", ".rar"}:
        result = subprocess.run(
            [
                str(seven_zip),
                "x",
                str(download_file),
                f"-o{target_dir}",
                "-y",
            ],
            check=False,
        )
        return result.returncode == 0

    target_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy(download_file, target_dir / download_file.name)
    return True


def sync_mods() -> None:
    if TEMP_DIR.exists():
        shutil.rmtree(TEMP_DIR, ignore_errors=True)
    TEMP_DIR.mkdir(parents=True, exist_ok=True)

    package_path = TEMP_DIR / "package"
    print("正在检查服务器更新...")
    if not download_file(f"{BASE_URL}/package", package_path):
        print_error(
            [
                "启动游戏失败。请检查你的网络或稍后重试。Errorcode=3",
                "Failed to download package file.",
            ]
        )
        sys.exit(1)

    server_mods: set[str] = set()
    mods_dir = SCRIPT_DIR / MOD_DIR
    mods_dir.mkdir(parents=True, exist_ok=True)

    with package_path.open("r", encoding="utf-8", errors="ignore") as handle:
        for line in handle:
            if not line.strip():
                continue
            if ":" not in line:
                continue

            mod_name, mod_url = line.split(":", 1)
            mod_name = mod_name.strip()
            mod_url = mod_url.strip()

            if mod_name == "EOF":
                print("Skipping EOF..")
                break

            if not DEBUG:
                print(mod_name)
                print(mod_url)

            mod_url = mod_url.replace(" ", "%20")
            server_mods.add(mod_name)

            mod_path = mods_dir / mod_name
            if mod_path.exists():
                print(f"\"{mod_name}\" 模组已存在，跳过下载。")
                continue

            print(f"正在下载模组: {mod_name}...")
            ext = Path(urllib.parse.urlparse(mod_url).path).suffix
            download_name = f"{mod_name}{ext}" if ext else mod_name
            download_path = TEMP_DIR / download_name

            if not download_file(mod_url, download_path):
                print_error(
                    [
                        "启动游戏失败。请检查你的网络或稍后重试。Errorcode=4",
                        f"下载 {mod_name} 失败。",
                    ]
                )
                sys.exit(1)

            if not extract_mod(download_path, mod_path, ext):
                print_error(
                    [
                        "检查到文件异常，请检查占用和你的防病毒软件是否拦截了解压操作。Errorcode=5",
                        f"解压 {mod_name} 失败。",
                    ]
                )
                sys.exit(1)

    for entry in mods_dir.iterdir():
        if entry.is_dir() and entry.name not in server_mods:
            print(f"Deleting local mod {entry.name} not found on server...")
            shutil.rmtree(entry, ignore_errors=True)

    if not DEBUG_DONOTDELETE:
        shutil.rmtree(TEMP_DIR, ignore_errors=True)


def launch_game() -> None:
    print("-----------DONE-----------")
    print("校验已完成，等待游戏加载。")
    print(f"{NAME} {VERSION}")
    print("-----------DONE-----------")
    if not DEBUG:
        time.sleep(3)

    game_path = SCRIPT_DIR / GAME_MAIN
    if not DEBUG:
        subprocess.Popen([str(game_path)], cwd=SCRIPT_DIR)
        time.sleep(60)


def debug_menu() -> None:
    global DEBUG
    global DEBUG_DONOTDELETE
    while True:
        print("1.netstat <port> 2.taskkill <pid> 3.tasklist <pid> 4.ShowVar")
        print("5.no_remove_temp 6.go 7.disable_and_go 8.select_go_where")
        print("9.command")
        choice = input().strip()

        if choice == "1":
            port = input("<port>=")
            os.system(f"netstat -ano|findstr {port}")
        elif choice == "2":
            pid = input("<pid>=")
            os.system(f"taskkill /f /pid {pid}")
        elif choice == "3":
            pid = input("<pid>=what? type .n to just tasklist")
            if pid == ".n":
                os.system("tasklist")
            else:
                os.system(f"tasklist|findstr {pid}")
        elif choice == "4":
            print(f"url={BASE_URL}")
            print(f"game={GAME}")
            print(f"mod_dir={MOD_DIR}")
            print(f"script_dir={SCRIPT_DIR}")
            print(f"name={NAME}")
            print(f"version={VERSION}")
            print(f"DEBUG={DEBUG}")
            print(f"DEBUG_DONOTDELETE={DEBUG_DONOTDELETE}")
            print(f"DEBUG_UPDATE={DEBUG_UPDATE}")
            print(f"temp_dir={TEMP_DIR}")
        elif choice == "5":
            DEBUG_DONOTDELETE = not DEBUG_DONOTDELETE
            print(f"DONOTDELETE={'true' if DEBUG_DONOTDELETE else 'false'}")
        elif choice == "6":
            return
        elif choice == "7":
            DEBUG = False
            return
        elif choice == "8":
            jump = input("按下数字决定跳转到哪里执行。")
            if jump == "1":
                ensure_7zip()
            elif jump == "2":
                sync_mods()
            elif jump == "3":
                validate_environment()
        elif choice == "9":
            command = input("command:")
            os.system(command)
        else:
            print("Error. Retry.")


def main() -> None:
    set_title(f"{NAME} {VERSION}")

    if DEBUG:
        set_title(f"{NAME}[Debugging] {VERSION}")

    if not validate_environment():
        return

    if not ensure_7zip():
        return

    if DEBUG_UPDATE:
        check_for_updates()

    sync_mods()
    launch_game()

    if DEBUG:
        debug_menu()


if __name__ == "__main__":
    main()
