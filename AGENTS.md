# AGENTS

## Project overview
- This repo is a single Windows batch script: `1Luobo-StartHelper.bat`.
- The script is a launcher + mod sync helper for a game (default `game=PEAK`) and expects a Stardew Valley/SMAPI-style install layout.
- It validates the environment, downloads 7-Zip helpers if missing, self-updates, syncs mods from a server package list, and finally launches the game.

## Key files
- `1Luobo-StartHelper.bat`: main logic (environment checks, update logic, mod sync, launch, debug labels).
- `README.md`: minimal project title only.

## Important script variables (near top of `1Luobo-StartHelper.bat`)
- `version`, `url`, `game`, `batname`, `mod_dir`, `Game_Main` control metadata, update URL, and target executable.
- `DEBUG`, `DEBUG_UPDATE`, `Steam_Check_Bypass`, `Env_Check_Bypass` drive debug behavior and environment checks.
- `temp_dir`, `temp_dir_package` for update/download staging.

## Common flow (labels)
- `:run` → `:run3` → environment checks (`SMAPI`/game exe).
- `:run1` downloads 7-Zip helpers if missing.
- `:updated`/`:run2` handles update checks and mod package processing.
- `:jumpout`/cleanup steps remove stale mods and temp directories.
- `:endprogram` exits after launching the game.

## Development notes
- Keep batch labels and flow consistent; avoid breaking fall-through sequencing.
- Any changes to download URLs or package formats must align with server expectations.
- Prefer minimal changes; batch scripts are sensitive to quoting and delayed expansion.

## Testing
- No automated tests. Manual validation on Windows is required (run the `.bat` in a game install directory).
