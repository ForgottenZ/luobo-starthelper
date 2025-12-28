@echo off
setlocal enabledelayedexpansion

REM 唉，我可能得重构你，真的。

:: INIT
set "version=v3.0.0.PEAK.20251228"
set "url=https://globalcdn.luoboo.top/static/peak-mods/"
set "game=PEAK"
set "batname=1Luobo-StartHelper.bat"
set "mod_dir=BepInEx\plugins\"
set "Game_Main=StardewModdingAPI.exe"

:: Local Settings
set "DEBUG=false"
set "DEBUG_DONOTDELETE=false"
set "DEBUG_UPDATE=true"
set "Steam_Check_Bypass=1"
set "Env_Check_Bypass=1"



:: 初始化变量
set "script_dir=%~dp0"
set "name=Luobo %game%模组同步器"
set "ENV_1=0"
set "target_line=1"
set "current_line=0"
set "STEAM_LAUNCHED=false"
set "temp_dir=%~dp0temp_mods_update"
set "temp_dir_package=%~dp0temp_mods_update\package"


:: dev check
echo !version! | findstr /i "dev unstable beta alpha" >nul

if "%DEBUG%" neq "true" (
    if %errorlevel% equ 0 (
        color E4
        echo 您当前正在运行开发版本，该版本不稳定，容易出现bug，如需回退版本，请联系开发者。
        echo 开发者不对该版本造成的任何损害负责。
        echo 由于该版本的特殊性，该文件禁止以任何其他形式的非本人授权的二次分发。
        echo 如需分发，您需提前告知我。
        echo 如果您不同意该声明，请立刻停止使用该软件并删除有关其的所有原件及备份。继续使用将被认为对该声明的同意。
        echo 按任意键以继续。
        echo You are currently running a development version, which is unstable and prone to bugs. If you need to revert to a previous version, please contact the developer.  
        echo The developer is not liable for any damage caused by this version.
        echo Due to the special nature of this version, this file is prohibited from being redistributed in any other form without the author's authorization.  
        echo If you wish to redistribute it, you must notify me in advance.  
        echo If you do not agree to this statement, please immediately stop using this software and delete all original copies and backups. Continuing to use it will be deemed as agreement to this statement.  
        echo Press any key to continue.
        timeout 20
        color 07
        cls
    )
)

:: 初始化一个变量来存储服务器上的模组列表
set "server_mods="
title %name% %version%

:: Debug
if "%DEBUG%" equ "true" (
    title %name%[Debugging] %version%
    goto bugfix
)

:run

:run3
set "current_line=0"

:: 游戏环境检测
if %Env_Check_Bypass% neq 1 (
    if not exist "%~dp0StardewModdingAPI.exe" (
        set "ENV_1=1"
    )
    if not exist "%~dp0Stardew Valley.exe" (
        set "ENV_1=%ENV_1%2"
    )
)
:run0

    if %ENV_1% equ 1 (
        if "%DEBUG%" neq "true" (
            cls
        )
        color F4
        echo -----------ERROR-----------
        echo 启动游戏失败。你没有安装SMAPI。这是启动模组所必需的。
        echo 按下回车键来打开默认浏览器下载SMAPI。
        echo SMAPI not found, please install SMAPI first.
        echo -----------ERROR-----------
        pause
        color 07
        start https://smapi.io/
        pause
        if "%DEBUG%" equ "true" ( goto bugfix )
        exit
    )
    if %ENV_1% equ 2 (
        if "%DEBUG%" neq "true" (
            cls
        )
        color F4
        echo -----------ERROR-----------
        echo 未找到游戏本体。
        echo Stardew Valley.exe not found.
        echo -----------ERROR-----------
        pause
        if "%DEBUG%" equ "true" ( goto bugfix )
        exit
    )
    if %ENV_1% equ 12 (
        if "%DEBUG%" neq "true" (
            cls
        )
        color F4
        echo -----------ERROR-----------
        echo 未找到游戏本体和SMAPI。尝试更换启动器位置。
        echo Stardew Valley.exe not found.
        echo -----------ERROR-----------
        pause
        if "%DEBUG%" equ "true" ( goto bugfix )
        exit
    )

:run1

:: 检查curl是否存在
where curl >nul 2>&1
if %errorlevel% neq 0 (
    if "%DEBUG%" neq "true" (
        cls
    )
    color F4
    echo -----------ERROR-----------
    echo 启动游戏失败。你的系统缺少关键组件。Errorcode=1
    echo Curl not found, please install curl first.
    echo -----------ERROR-----------
    pause
    exit /b
)

:: 检查7z.exe是否存在，如果不存在则下载7zip相关文件
if not exist "%~dp07z.exe" (
    echo 未找到7z.exe，正在从服务器获取...
    curl -o "%~dp07z.exe" "%url%/7-Zip-P6cq1JVf/7z.exe"
    if %errorlevel% neq 0 (
        if "%DEBUG%" neq "true" (
            cls
        )
        color F4
        echo -----------ERROR-----------
        echo 启动游戏失败。 请检查你的网络或稍后重试。Errorcode=2
        echo Failed to download 7z.exe file.
        echo -----------ERROR-----------
        pause
        exit /b
    )
    curl -o "%~dp07z.dll" "%url%/7-Zip-P6cq1JVf/7z.dll"
    curl -o "%~dp07z.sfx" "%url%/7-Zip-P6cq1JVf/7z.sfx"
    curl -o "%~dp07-zip.dll" "%url%/7-Zip-P6cq1JVf/7-zip.dll"
)
if not exist "%~dp07z.dll" (
    echo 未找到7z.exe，正在从服务器获取...
    curl -o "%~dp07z.exe" "%url%/7-Zip-P6cq1JVf/7z.exe"
    if %errorlevel% neq 0 (
        if "%DEBUG%" neq "true" (
            cls
        )
        color F4
        echo -----------ERROR-----------
        echo 启动游戏失败。 请检查你的网络或稍后重试。Errorcode=2
        echo Failed to download 7z.exe file.
        echo -----------ERROR-----------
        pause
        exit /b
    )
    curl -o "%~dp07z.dll" "%url%/7-Zip-P6cq1JVf/7z.dll"
    curl -o "%~dp07z.sfx" "%url%/7-Zip-P6cq1JVf/7z.sfx"
    curl -o "%~dp07-zip.dll" "%url%/7-Zip-P6cq1JVf/7-zip.dll"
)
if not exist "%~dp07z.sfx" (
    echo 未找到7z.exe，正在从服务器获取...
    curl -o "%~dp07z.exe" "%url%/7-Zip-P6cq1JVf/7z.exe"
    if %errorlevel% neq 0 (
        if "%DEBUG%" neq "true" (
            cls
        )
        color F4
        echo -----------ERROR-----------
        echo 启动游戏失败。 请检查你的网络或稍后重试。Errorcode=2
        echo Failed to download 7z.exe file.
        echo -----------ERROR-----------
        pause
        exit /b
    )
    curl -o "%~dp07z.dll" "%url%/7-Zip-P6cq1JVf/7z.dll"
    curl -o "%~dp07z.sfx" "%url%/7-Zip-P6cq1JVf/7z.sfx"
    curl -o "%~dp07-zip.dll" "%url%/7-Zip-P6cq1JVf/7-zip.dll"
)
if not exist "%~dp07-zip.dll" (
    echo 未找到7z.exe，正在从服务器获取...
    curl -o "%~dp07z.exe" "%url%/7-Zip-P6cq1JVf/7z.exe"
    if %errorlevel% neq 0 (
        if "%DEBUG%" neq "true" (
            cls
        )
        color F4
        echo -----------ERROR-----------
        echo 启动游戏失败。 请检查你的网络或稍后重试。Errorcode=2
        echo Failed to download 7z.exe file.
        echo -----------ERROR-----------
        pause
        exit /b
    )
    curl -o "%~dp07z.dll" "%url%/7-Zip-P6cq1JVf/7z.dll"
    curl -o "%~dp07z.sfx" "%url%/7-Zip-P6cq1JVf/7z.sfx"
    curl -o "%~dp07-zip.dll" "%url%/7-Zip-P6cq1JVf/7-zip.dll"
)

:: Check IF Updated
if "%UPDATED%" equ "true" (
    echo 发现已进行更新。跳过校验。
    goto updated
)

:: 自我更新
if "%DEBUG_UPDATE%" equ "true" (
    echo Checking for updates...  正在校验更新...
    curl -o "%~dp0Launcher" "%url%/Launcher"
    for /f "delims=" %%i in (Launcher) do (
        set /a line+=1
        if "!line!" equ "1" (
            set "Now_version=%%i"

            :: 提取纯净版版本号（去掉 v、. 和后缀）
            for /f "tokens=1-4 delims=." %%a in ("!Now_version:~1!") do (
                set "Now_version_clean=%%a%%b%%c"
            )
            for /f "tokens=1-4 delims=." %%a in ("%version:~1%") do (
                set "version_clean=%%a%%b%%c"
            )

            :: 调试信息 - 显示原始和清理后的版本号
            if "%DEBUG%" equ "true" (
                echo [DEBUG] Now_version=!Now_version!
                echo [DEBUG] version=%version!
                echo [DEBUG] Now_version_clean=!Now_version_clean!
                echo [DEBUG] version_clean=!version_clean!
            )

            :: 比较版本号（按整数大小比较）
            if !Now_version_clean! lss !version_clean! (
                echo 服务器版本 [!Now_version!] 比当前 [!version!] 更旧，跳过更新。
                timeout 3
                goto updated
            )
            if !Now_version_clean! gtr !version_clean! (
                echo 检测到新版本 [!Now_version!]（当前 [!version!]），正在更新...
                timeout 5
                curl -o "%~dp0%batname%" "%url%/%batname%"
                set "UPDATED=true"
                del Launcher
                call %batname%
            ) else (
                echo 当前版本 [!version!] 已是最新，无需更新。
                timeout 3
            )
        )
    )
)
:updated
:run2

:: 创建临时文件夹
if exist "%temp_dir%" rd /s /q "%temp_dir%"
mkdir "%temp_dir%"

:: 下载package文件
echo 正在检查服务器更新...
curl -o "%temp_dir%\package" "%url%/package"
if "%DEBUG%" equ "true" (
   echo Step 1:Check Update .. done
   echo errorlevel=%errorlevel%
   pause
)
if %errorlevel% neq 0 (
    if "%DEBUG%" neq "true" ( cls )
        color F4
        echo -----------ERROR-----------
        echo 启动游戏失败。请检查你的网络或稍后重试。Errorcode=3
        echo Failed to download package file.
        echo -----------ERROR-----------
        pause
        exit /b
)
:: 读取package文件并处理每一行
pushd %temp_dir%

for /f "tokens=1,* delims=:" %%a in (package) do (
    if !errorlevel! neq 0 (
        if "%DEBUG%" neq "true" ( cls )
        color F4
        echo -----------ERROR-----------
        echo 在启动游戏过程中失败。未知错误。Errorcode=6
        echo Occurred Unknown Error while starting the game.
        echo -----------ERROR-----------
        pause
        exit /b
    )

    set "mod_name=%%a"
    set "mod_url=%%b"
    if "%DEBUG%" neq "true" (
        echo !mod_name!
        echo !mod_url!
    )


    :: 处理URL中的空格
    set "mod_url=!mod_url: =%%20!"

    :: 将mod_name添加到服务器模组列表中
    set "server_mods=!server_mods! !mod_name!"

    :: 检查mods文件夹中是否存在该mod文件夹
    if not exist "%~dp0%mod_dir%!mod_name!" (
        if "!mod_name!" equ "EOF" (
                echo Skipping EOF..
                goto :jumpout
        )

        echo 正在下载模组: !mod_name!...

        :: 获取文件扩展名
        for %%i in ("!mod_url!") do set "ext=%%~xi"

        :: 根据扩展名设置下载文件名
        set "download_file=%temp_dir%\!mod_name!!ext!"

        :: 下载mod文件
        curl -o "!download_file!" "!mod_url!"
        if %DEBUG% equ "true" (
            echo 下载地址: !mod_url!
        )

        if %errorlevel% neq 0 (
            if "%DEBUG%" neq "true" (
                cls
            )
            color F4
            echo -----------ERROR-----------
            echo 启动游戏失败。请检查你的网络或稍后重试。Errorcode=4
            echo 下载 !mod_name! 失败。
            echo -----------ERROR-----------
            pause
            if "%DEBUG%" equ "true" ( goto bugfix )
            exit /b
        )

        :: 根据文件扩展名执行不同的解压操作
        if /i "!ext!" equ ".zip" (
            "%~dp07z.exe" x "!download_file!" -o"%~dp0%mod_dir%!mod_name!" -y
        ) else if /i "!ext!" equ ".7z" (
            "%~dp07z.exe" x "!download_file!" -o"%~dp0%mod_dir%!mod_name!" -y
        ) else if /i "!ext!" equ ".rar" (
            "%~dp07z.exe" x "!download_file!" -o"%~dp0%mod_dir%!mod_name!" -y
        ) else (
            :: 如果不是压缩文件，直接创建目录并复制文件
            mkdir "%~dp0%mod_dir%!mod_name!"
            copy "!download_file!" "%~dp0%mod_dir%!mod_name!"
        )

        if %errorlevel% neq 0 (
            if "%DEBUG%" neq "true" (
                cls
            )
            if "%DEBUG%" equ "true" (
                echo !mod_name!
            )
            color F4
            echo -----------ERROR-----------
            echo 检查到文件异常，请检查占用和你的防病毒软件是否拦截了解压操作。Errorcode=5
            echo 解压 !mod_name! 失败。
            echo -----------ERROR-----------
            pause
            if "%DEBUG%" equ "true" ( goto bugfix )
            exit /b
        )
    ) else (
        echo "!mod_name! 模组已存在，跳过下载。"
    )
)

:jumpout

popd

if "%DEBUG%" equ "true" (
    echo Now in: %cd%
)


REM if not exist "%~dp0Content\version.txt" (
REM     curl -o "%temp_dir%\Modified-Portraits.zip" "%url%/Portraits-2pQyqOY2/Portraits.zip"
REM     rmdir /s /q "%~dp0Content\Portraits\"
REM     if not exist "%~dp0Content\Portraits\Abigail_Winter.xnb" (
REM         mkdir "%~dp0Content\Portraits\"
REM     )
REM     "%~dp07z.exe" x "%temp_dir%\Modified-Portraits.zip" -o"%~dp0Content\Portraits\" -y
REM         if %errorlevel% neq 0 (
REM             if "%DEBUG%" neq "true" (
REM                 cls
REM             )
REM             if "%DEBUG%" equ "true" (
REM                 echo !mod_name!
REM             )
REM             color F4
REM             echo -----------ERROR-----------
REM             echo 检查到文件异常，请检查占用和你的防病毒软件是否拦截了解压操作。Errorcode=5
REM             echo Failed to extract !mod_name!.
REM             echo -----------ERROR-----------
REM             pause
REM             exit /b
REM         )
REM     echo %RESversion% > "%~dp0Content\version.txt"
REM ) else (
REM     echo Already loaded Portraits.
REM )


:: 删除本地不存在于服务器的模组
for /d %%d in ("%~dp0%mod_dir%*") do (
    set "folder_name=%%~nxd"
    if "!server_mods: %%~nxd =!"=="!server_mods!" (
        echo Deleting local mod %%~nxd not found on server...
        rd /s /q "%%d"
    )
)


:: 删除临时文件夹
if "%DEBUG_DONOTDELETE%" neq "true" (
        rd /s /q "%temp_dir%"
)


:: 版权/提示
if "%DEBUG%" neq "true" (
    cls
)
echo -----------DONE-----------
echo 校验已完成，等待游戏加载。
echo %name% %version%
echo -----------DONE-----------
if "%DEBUG%" neq "true" (
    timeout /T 3 /NOBREAK
)


:: 启动游戏
cd "%~dp0"
if "%DEBUG%" neq "true" (
    start %Game_Main%
    timeout /t 60 >nul
)

if "%DEBUG%" equ "true" (
    goto bugfix
)

goto endprogram


:bugfix
echo "1.netstat <port> 2.taskkill <pid> 3.tasklist <pid> 4.ShowVar"
echo "5.no_remove_temp 6.go 7.disable_and_go 8.select_go_where"
echo "9.command"
set /p q=
if %q%==1 (
	set q=0
	goto bugfix1
)
if %q%==2 (
	set q=0
	goto bugfix2
)
if %q%==3 (
	set q=0
	goto bugfix3
)
if %q%==4 (
	set q=0
	goto bugfix4
)
if %q%==5 (
	if "%DEBUG_DONOTDELETE%"=="true" (
		set "DEBUG_DONOTDELETE=false"
		echo DONOTDELETE=false
	)
	if "%DEBUG_DONOTDELETE%"=="false" (
		set "DEBUG_DONOTDELETE=true"
		echo DONOTDELETE=true
	)
	set q=0
	goto bugfix
)
if %q%==6 (
	set q=0
	goto run
)
if %q%==7 (
	set q=0
    set "DEBUG=false"
	goto run
)
if %q%==8 (
	set q=0
	goto bugfix5
)
if %q%==9 (
	set q=0
	goto bugfix6
) else (
	echo Error. Retry.
	goto bugfix
)

:bugfix1
echo "<port>="
set /p port=
netstat -ano|findstr %port%
set port=
goto bugfix

:bugfix2
echo "<pid>="
set /p pid=
taskkill /f /pid %pid%
goto bugfix

:bugfix3
echo "<pid>=what? type .n to just tasklist"
set /p pid=
if %pid%==.n (
	tasklist
	goto bugfix
)
tasklist|findstr %pid%
goto bugfix

:bugfix4
echo url=%url%
echo game=%game%
echo batname=%batname%
echo mod_dir=%mod_dir%
echo script_dir=%script_dir%
echo name=%name%
echo version=%version%
echo ENV_1=%ENV_1%
echo target_line=%target_line%
echo current_line=%current_line%
echo DEBUG=%DEBUG%
echo DEBUG_DONOTDELETE=%DEBUG_DONOTDELETE%
echo DEBUG_UPDATE=%DEBUG_UPDATE%
echo STEAM_LAUNCHED=%STEAM_LAUNCHED%
echo temp_dir=%temp_dir%
echo temp_dir_package=%temp_dir_package%
echo Steam_Check_Bypass=%Steam_Check_Bypass%
echo server_mods=%server_mods%
echo Now_version=%Now_version%
echo UPDATED=%UPDATED%
echo lowerPath=%lowerPath%
echo qwer=%qwer%
echo mod_name=%mod_name%
echo mod_url=%mod_url%
echo line=%line%
echo port=%port%
echo pid=%pid%
echo showall=%showall%
echo jumptowhere=%jumptowhere%
echo command=%command%
echo TEXT "set" below to show all parameters, or press Enter to skip.
set /p showall=
%showall%
set showall=
goto bugfix

:bugfix5
echo 按下数字决定跳转到哪里执行。
set /p jumptowhere=
goto run%jumptowhere%

:bugfix6
echo command:
set /p command=
%command%
set command=
goto bugfix


:endprogram
echo Done.
timeout /T 1 /NOBREAK
endlocal
popd
