@echo off
setlocal enabledelayedexpansion

echo ========================================
echo       Nginx服务配置管理工具
echo ========================================
echo.

if "%1"=="" goto :show_menu
if "%1"=="list" goto :list_services
if "%1"=="enable" goto :enable_service
if "%1"=="disable" goto :disable_service
if "%1"=="delete" goto :delete_service
if "%1"=="test" goto :test_config
goto :show_usage

:show_menu
echo 请选择操作：
echo   1. 列出所有服务配置
echo   2. 启用服务配置
echo   3. 禁用服务配置
echo   4. 删除服务配置
echo   5. 测试配置语法
echo   6. 重新加载配置
echo   0. 退出
echo.
set /p choice=请输入选项 (0-6): 

if "%choice%"=="1" goto :list_services
if "%choice%"=="2" goto :enable_service_interactive
if "%choice%"=="3" goto :disable_service_interactive
if "%choice%"=="4" goto :delete_service_interactive
if "%choice%"=="5" goto :test_config
if "%choice%"=="6" goto :reload_config
if "%choice%"=="0" goto :end
goto :show_menu

:show_usage
echo 使用方法：
echo   manage-services.bat list                    # 列出所有服务
echo   manage-services.bat enable [服务名]         # 启用服务
echo   manage-services.bat disable [服务名]        # 禁用服务
echo   manage-services.bat delete [服务名]         # 删除服务
echo   manage-services.bat test                    # 测试配置
echo.
echo 示例：
echo   manage-services.bat enable user-service
echo   manage-services.bat disable order-service
echo.
goto :end

:list_services
echo 当前服务配置列表：
echo ========================================
echo.
echo 启用的服务：
if exist "nginx\sites-enabled\*.conf" (
    for %%f in (nginx\sites-enabled\*.conf) do (
        set filename=%%~nf
        if not "!filename!"=="service-template" (
            echo   ✓ !filename!
            call :show_service_info "%%f"
        )
    )
) else (
    echo   (无启用的服务)
)
echo.
echo 禁用的服务：
if exist "nginx\sites-disabled\*.conf" (
    for %%f in (nginx\sites-disabled\*.conf) do (
        set filename=%%~nf
        echo   ✗ !filename!
    )
) else (
    echo   (无禁用的服务)
)
echo.
goto :end

:show_service_info
set config_file=%~1
for /f "tokens=2 delims=:" %%a in ('findstr "proxy_pass" "%config_file%" 2^>nul') do (
    set backend=%%a
    set backend=!backend: =!
    echo     后端: !backend!
)
for /f "tokens=2" %%a in ('findstr "location" "%config_file%" 2^>nul') do (
    set path=%%a
    if not "!path!"=="/health" if not "!path!"=="{" (
        echo     路径: https://localhost!path!
        goto :eof
    )
)
goto :eof

:enable_service_interactive
echo.
echo 可禁用的服务：
if exist "nginx\sites-disabled\*.conf" (
    for %%f in (nginx\sites-disabled\*.conf) do (
        echo   - %%~nf
    )
    echo.
    set /p service_name=请输入要启用的服务名: 
    call :enable_service "!service_name!"
) else (
    echo   (无可启用的服务)
)
goto :end

:enable_service
set service_name=%~1
if "%service_name%"=="" (
    echo 错误：请指定服务名
    goto :end
)

if not exist "nginx\sites-disabled\%service_name%.conf" (
    echo 错误：服务 %service_name% 不存在或已启用
    goto :end
)

if not exist "nginx\sites-enabled" mkdir "nginx\sites-enabled"
move "nginx\sites-disabled\%service_name%.conf" "nginx\sites-enabled\%service_name%.conf" >nul
echo ✓ 服务 %service_name% 已启用
goto :end

:disable_service_interactive
echo.
echo 可禁用的服务：
if exist "nginx\sites-enabled\*.conf" (
    for %%f in (nginx\sites-enabled\*.conf) do (
        set filename=%%~nf
        if not "!filename!"=="service-template" (
            echo   - !filename!
        )
    )
    echo.
    set /p service_name=请输入要禁用的服务名: 
    call :disable_service "!service_name!"
) else (
    echo   (无可禁用的服务)
)
goto :end

:disable_service
set service_name=%~1
if "%service_name%"=="" (
    echo 错误：请指定服务名
    goto :end
)

if not exist "nginx\sites-enabled\%service_name%.conf" (
    echo 错误：服务 %service_name% 不存在或已禁用
    goto :end
)

if not exist "nginx\sites-disabled" mkdir "nginx\sites-disabled"
move "nginx\sites-enabled\%service_name%.conf" "nginx\sites-disabled\%service_name%.conf" >nul
echo ✓ 服务 %service_name% 已禁用
goto :end

:delete_service_interactive
echo.
echo 可删除的服务：
if exist "nginx\sites-enabled\*.conf" (
    for %%f in (nginx\sites-enabled\*.conf) do (
        set filename=%%~nf
        if not "!filename!"=="service-template" (
            echo   - !filename! (启用)
        )
    )
)
if exist "nginx\sites-disabled\*.conf" (
    for %%f in (nginx\sites-disabled\*.conf) do (
        echo   - %%~nf (禁用)
    )
)
echo.
set /p service_name=请输入要删除的服务名: 
set /p confirm=确认删除 %service_name% 吗？(y/N): 
if /i "%confirm%"=="y" (
    call :delete_service "!service_name!"
) else (
    echo 取消删除
)
goto :end

:delete_service
set service_name=%~1
if "%service_name%"=="" (
    echo 错误：请指定服务名
    goto :end
)

set deleted=0
if exist "nginx\sites-enabled\%service_name%.conf" (
    del "nginx\sites-enabled\%service_name%.conf"
    set deleted=1
)
if exist "nginx\sites-disabled\%service_name%.conf" (
    del "nginx\sites-disabled\%service_name%.conf"
    set deleted=1
)

if %deleted%==1 (
    echo ✓ 服务 %service_name% 已删除
) else (
    echo 错误：服务 %service_name% 不存在
)
goto :end

:test_config
echo 正在测试Nginx配置语法...
docker exec nginx-proxy-manager nginx -t
if %errorlevel%==0 (
    echo ✓ 配置语法正确
) else (
    echo ✗ 配置语法错误，请检查配置文件
)
goto :end

:reload_config
echo 正在重新加载Nginx配置...
docker exec nginx-proxy-manager nginx -s reload
if %errorlevel%==0 (
    echo ✓ 配置已重新加载
) else (
    echo ✗ 重新加载失败，请检查容器状态
)
goto :end

:end
echo.
pause