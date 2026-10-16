Unicode true
!include MUI2.nsh
!include LogicLib.nsh
!include x64.nsh
!include WinVer.nsh

!define PRODUCT "复制路径 (Copy Path)"
!define VERSION "1.0.0"
!ifndef CLASSES_ROOT
  !define CLASSES_ROOT "Software\Classes"
!endif
!ifndef UNINSTALL_ROOT
  !define UNINSTALL_ROOT "Software\Microsoft\Windows\CurrentVersion\Uninstall\CopyPathMini"
!endif
!ifndef OUTPUT
  !define OUTPUT "build\CopyPath-Setup-1.0.0.exe"
!endif
!define FILE_MENU "${CLASSES_ROOT}\AllFilesystemObjects\shell\CopyPathToClipboard"
!define BG_MENU "${CLASSES_ROOT}\Directory\Background\shell\CopyPathToClipboard"

Name "${PRODUCT}"
OutFile "${OUTPUT}"
InstallDir "$LOCALAPPDATA\CopyPathMini"
RequestExecutionLevel user
SetCompressor /SOLID lzma
SetDatablockOptimize on
ShowInstDetails nevershow
ShowUninstDetails nevershow
BrandingText "Copy Path · 小巧，无后台常驻"
VIProductVersion "1.0.0.0"
VIAddVersionKey /LANG=2052 "ProductName" "${PRODUCT}"
VIAddVersionKey /LANG=2052 "FileDescription" "复制路径安装程序"
VIAddVersionKey /LANG=2052 "FileVersion" "${VERSION}"
VIAddVersionKey /LANG=2052 "LegalCopyright" "Copy Path contributors"

!define MUI_WELCOMEPAGE_TITLE "安装复制路径"
!define MUI_WELCOMEPAGE_TEXT "为文件、文件夹及文件夹空白处添加置顶的“复制路径”菜单。$\r$\n$\r$\n只为当前 Windows 用户安装，无需管理员权限，无后台常驻、联网或自动更新。$\r$\n$\r$\n已有同名菜单会先备份，卸载时恢复。"
!define MUI_FINISHPAGE_TITLE "安装完成"
!define MUI_FINISHPAGE_TEXT "现在可以右键文件、文件夹或文件夹空白处，选择“复制路径”，再粘贴到需要的位置。$\r$\n$\r$\nWindows 11 若未直接显示，请打开“显示更多选项”。$\r$\n$\r$\n需要卸载时，在 Windows 设置的应用列表中搜索“复制路径”。"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!insertmacro MUI_LANGUAGE "SimpChinese"

Var RegAccess
Var RegSwitch
Var PreserveBackup

!macro InitRegistry
  SetShellVarContext current
  StrCpy $RegAccess 0x20019
  StrCpy $RegSwitch "/reg:32"
  ${If} ${RunningX64}
    SetRegView 64
    StrCpy $RegAccess 0x20119
    StrCpy $RegSwitch "/reg:64"
  ${EndIf}
!macroend

!macro AcquireSetupLock
  System::Call 'kernel32::CreateMutexW(p 0, i 0, w "Local\CopyPathMini.Setup") p.r0 ?e'
  Pop $1
  ${If} $0 == 0
  ${OrIf} $1 == 183
    MessageBox MB_OK|MB_ICONINFORMATION "另一个安装或卸载程序正在运行，请等待完成后重试。" /SD IDOK
    SetErrorLevel 1
    Abort
  ${EndIf}
!macroend

Function .onInit
  !insertmacro AcquireSetupLock
  !insertmacro InitRegistry
  ${IfNot} ${AtLeastWin10}
    MessageBox MB_OK|MB_ICONINFORMATION "此安装包适用于 Windows 10 或 Windows 11。" /SD IDOK
    Abort
  ${EndIf}
FunctionEnd

Function un.onInit
  !insertmacro AcquireSetupLock
  !insertmacro InitRegistry
FunctionEnd

; Export each complete pre-existing subtree, including value types. A missing
; key is recorded explicitly; other registry errors stop before any menu change.
!macro BackupMenu Key Tag
  System::Call 'advapi32::RegOpenKeyExW(p 0x80000001, w "${Key}", i 0, i $RegAccess, *p .r0) i.r1'
  ${If} $1 == 0
    System::Call 'advapi32::RegCloseKey(p r0)'
    nsExec::ExecToStack '"$SYSDIR\reg.exe" export "HKCU\${Key}" "$INSTDIR\backup\${Tag}.reg" /y $RegSwitch'
    Pop $0
    Pop $1
    ${If} $0 != 0
      Goto backup_failed
    ${EndIf}
    WriteINIStr "$INSTDIR\state.ini" "original" "${Tag}" "present"
  ${ElseIf} $1 == 2
    WriteINIStr "$INSTDIR\state.ini" "original" "${Tag}" "absent"
  ${Else}
    Goto backup_failed
  ${EndIf}
!macroend

!macro RestoreMenu Key Tag
  ReadINIStr $0 "$INSTDIR\state.ini" "original" "${Tag}"
  ${If} $0 == "present"
    IfFileExists "$INSTDIR\backup\${Tag}.reg" +2
      Goto restore_failed
    DeleteRegKey HKCU "${Key}"
    nsExec::ExecToStack '"$SYSDIR\reg.exe" import "$INSTDIR\backup\${Tag}.reg" $RegSwitch'
    Pop $0
    Pop $1
    ${If} $0 != 0
      Goto restore_failed
    ${EndIf}
  ${ElseIf} $0 == "absent"
    DeleteRegKey HKCU "${Key}"
  ${Else}
    Goto restore_failed
  ${EndIf}
!macroend

!macro ValidateBackup Tag FailureLabel
  ReadINIStr $0 "$INSTDIR\state.ini" "original" "${Tag}"
  ${If} $0 == "present"
    IfFileExists "$INSTDIR\backup\${Tag}.reg" +2
      Goto ${FailureLabel}
  ${ElseIf} $0 != "absent"
    Goto ${FailureLabel}
  ${EndIf}
!macroend

!macro WriteMenu Key Placeholder
  DeleteRegKey HKCU "${Key}"
  ClearErrors
  WriteRegStr HKCU "${Key}" "" "复制路径"
  WriteRegStr HKCU "${Key}" "MUIVerb" "复制路径"
  WriteRegStr HKCU "${Key}" "Position" "Top"
  WriteRegStr HKCU "${Key}" "Icon" "imageres.dll,-5302"
  WriteRegStr HKCU "${Key}\command" "" '$\"$INSTDIR\CopyPath.exe$\" $\"${Placeholder}|$\"'
!macroend

Section "Install"
  SetOutPath "$INSTDIR"
  ReadINIStr $0 "$INSTDIR\state.ini" "install" "baseline"
  ${If} $0 != "1"
    ; Never replace an unrelated executable in a user-specified destination.
    IfFileExists "$INSTDIR\CopyPath.exe" backup_failed
    ClearErrors
    CreateDirectory "$INSTDIR\backup"
    IfErrors backup_failed
    !insertmacro BackupMenu "${FILE_MENU}" "files"
    !insertmacro BackupMenu "${BG_MENU}" "background"
    WriteINIStr "$INSTDIR\state.ini" "install" "baseline" "1"
    IfErrors backup_failed
  ${EndIf}
  !insertmacro ValidateBackup "files" backup_failed
  !insertmacro ValidateBackup "background" backup_failed

  ClearErrors
  SetOverwrite ifdiff
  File "build\CopyPath.exe"
  File /oname=使用说明.txt "USAGE.txt"
  File /oname=开源许可.txt "THIRD-PARTY-LICENSES.txt"
  IfErrors install_failed
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  IfErrors install_failed
  !insertmacro WriteMenu "${FILE_MENU}" "%1"
  IfErrors install_failed
  !insertmacro WriteMenu "${BG_MENU}" "%V"
  IfErrors install_failed

  WriteRegStr HKCU "${UNINSTALL_ROOT}" "DisplayName" "${PRODUCT}"
  WriteRegStr HKCU "${UNINSTALL_ROOT}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${UNINSTALL_ROOT}" "Publisher" "Copy Path"
  WriteRegStr HKCU "${UNINSTALL_ROOT}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_ROOT}" "UninstallString" '$\"$INSTDIR\Uninstall.exe$\"'
  WriteRegStr HKCU "${UNINSTALL_ROOT}" "QuietUninstallString" '$\"$INSTDIR\Uninstall.exe$\" /S'
  WriteRegStr HKCU "${UNINSTALL_ROOT}" "DisplayIcon" "$INSTDIR\Uninstall.exe"
  WriteRegDWORD HKCU "${UNINSTALL_ROOT}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTALL_ROOT}" "NoRepair" 1
  WriteRegDWORD HKCU "${UNINSTALL_ROOT}" "EstimatedSize" 256
  IfErrors install_failed
  System::Call 'shell32::SHChangeNotify(i 0x08000000, i 0, p 0, p 0)'
  SetErrorLevel 0
  Goto install_done

  backup_failed:
    MessageBox MB_OK|MB_ICONSTOP "未能安全备份原配置，安装已停止，右键菜单未作修改。请检查安装目录及权限后重试。" /SD IDOK
    SetErrorLevel 1
    Abort
  install_failed:
    !insertmacro RestoreMenu "${FILE_MENU}" "files"
    !insertmacro RestoreMenu "${BG_MENU}" "background"
    MessageBox MB_OK|MB_ICONSTOP "安装未完成，已恢复原右键配置。安装目录中的备份已保留，可重新运行安装包。" /SD IDOK
    SetErrorLevel 1
    Abort
  restore_failed:
    MessageBox MB_OK|MB_ICONSTOP "配置恢复未完成，原始备份已保留在安装目录的 backup 文件夹中。请保留此目录。" /SD IDOK
    SetErrorLevel 2
    Abort
  install_done:
SectionEnd

Section "Uninstall"
  StrCpy $PreserveBackup 0
  !insertmacro ValidateBackup "files" restore_failed
  !insertmacro ValidateBackup "background" restore_failed
  ; Restore only a menu that still invokes our exact installed executable.
  ReadRegStr $0 HKCU "${FILE_MENU}\command" ""
  ${If} $0 == '$\"$INSTDIR\CopyPath.exe$\" $\"%1|$\"'
    !insertmacro RestoreMenu "${FILE_MENU}" "files"
  ${Else}
    StrCpy $PreserveBackup 1
  ${EndIf}
  ReadRegStr $0 HKCU "${BG_MENU}\command" ""
  ${If} $0 == '$\"$INSTDIR\CopyPath.exe$\" $\"%V|$\"'
    !insertmacro RestoreMenu "${BG_MENU}" "background"
  ${Else}
    StrCpy $PreserveBackup 1
  ${EndIf}
  System::Call 'shell32::SHChangeNotify(i 0x08000000, i 0, p 0, p 0)'
  DeleteRegKey HKCU "${UNINSTALL_ROOT}"
  Delete "$INSTDIR\CopyPath.exe"
  Delete "$INSTDIR\使用说明.txt"
  Delete "$INSTDIR\开源许可.txt"
  ${If} $PreserveBackup == 0
    Delete "$INSTDIR\state.ini"
    Delete "$INSTDIR\backup\files.reg"
    Delete "$INSTDIR\backup\background.reg"
    RMDir "$INSTDIR\backup"
  ${EndIf}
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  SetErrorLevel 0
  Goto uninstall_done
  restore_failed:
    MessageBox MB_OK|MB_ICONSTOP "原配置尚未完全恢复，已停止卸载并保留程序和备份。请稍后重试。" /SD IDOK
    SetErrorLevel 2
    Abort
  uninstall_done:
SectionEnd

