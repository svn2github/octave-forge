; Script generated by the HM NIS Edit Script Wizard.

; Determine which configuration to use
#!define CONFIG_HOME
#!define USE_DEBUG
#!define USE_TIMING
!define OCTAVE_SUFFIX "2.9.12"
!define OCTAVE_VERSION "2.9.12"
#!define OCTAVE_CVS_VERSION "20070225"
#!define ATLAS_PM
!define USE_OCTPLOT
!define USE_OCTAVE_FORGE
!define USE_MSYS
!define JHANDLES_VERSION "0.2.0"

!ifdef USE_DEBUG
!define OCTAVE_BASE "octave-${OCTAVE_SUFFIX}-debug"
!else
!define OCTAVE_BASE "octave-${OCTAVE_SUFFIX}"
!endif

; Location of various components
!ifdef CONFIG_HOME
!define OCTAVE_ROOT "C:\Software\MSYS\local\${OCTAVE_BASE}"
!define GNUWIN32_ROOT "C:\Software\GnuWin32"
!define VCLIBS_ROOT "C:\Software\VCLibs"
!define CONSOLE_ROOT "C:\Software\Console2"
!define SCITE_ROOT "C:\Software\wscite"
!define GNUPLOT_ROOT "C:\Software\Gnuplot4.2"
!define OCTAVE_FORGE "C:\Sources\playground\c\octave-forge-cvs"
!ifdef OCTAVE_CVS_VERSION
!define OCTAVE_SRC "C:\Sources\playground\c\octave-cvs"
!else
!define OCTAVE_SRC "C:\Sources\playground\c\octave-${OCTAVE_SUFFIX}"
!endif
!define MSYS_ROOT "C:\Software\MSYS"
!define VCREDIST_FILE "C:\Temp\vcredist_x86.exe"
!else
!define OCTAVE_ROOT "D:\Software\MSYS\local\${OCTAVE_BASE}"
!define GNUWIN32_ROOT "D:\Software\GnuWin32"
!define VCLIBS_ROOT "D:\Software\VCLibs"
!define CONSOLE_ROOT "D:\Software\Console2"
!define SCITE_ROOT "D:\Software\wscite"
!define GNUPLOT_ROOT "D:\Software\Gnuplot4.2"
!define OCTAVE_FORGE "D:\Sources\MixDT\playground\c\octave-forge-cvs"
!ifdef OCTAVE_CVS_VERSION
!define OCTAVE_SRC "D:\Sources\MixDT\playground\c\octave-cvs"
!else
!define OCTAVE_SRC "D:\Sources\MixDT\playground\c\octave-${OCTAVE_SUFFIX}"
!endif
!define VCREDIST_FILE "D:\Temp\vcredist_x86.exe"
!define MSYS_ROOT "D:\Software\MSYS"
!endif

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "GNU Octave"
!ifdef OCTAVE_CVS_VERSION
!define PRODUCT_VERSION "snapshot-${OCTAVE_CVS_VERSION} (${OCTAVE_VERSION})"
!else
!define PRODUCT_VERSION "${OCTAVE_VERSION}"
!endif
!define PRODUCT_PUBLISHER ""
!define PRODUCT_WEB_SITE "http://www.octave.org"
!define OCTAVE_FORGE_WEB_SITE "http://octave.dbateman.org"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\octave-${OCTAVE_VERSION}.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"
!define PRODUCT_ROOT_KEY "HKLM"
!define PRODUCT_KEY "Software\Octave"

; MUI 1.67 compatible ------
!include "MUI.nsh"
!include "Sections.nsh"
!include "WordFunc.nsh"
!insertmacro WordReplace

!define LA_GEN "Generic (works on all systems)"
!define LA_P4 "Intel Pentium 4 with SSE2"
!ifdef ATLAS_PM
!define LA_PM "Intel Pentium M with SSE2"
!define LA_COUNT 3
!define LA_ALL "${LA_GEN}|${LA_P4}|${LA_PM}"
!else
!define LA_COUNT 2
!define LA_ALL "${LA_GEN}|${LA_P4}"
!endif

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!ifdef OCTAVE_CVS_VERSION
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_WELCOMEPAGE_TEXT "$(MUI_TEXT_WELCOME_INFO_TEXT)\r\n\r\nWARNING: THIS PACKAGE IS A DEVELOPMENT VERSION PROVIDED FOR TESTING PURPOSE. NORMAL USERS SHOULD USE A REGULAR RELEASE VERSION."
!endif
!insertmacro MUI_PAGE_WELCOME
; License page
!define MUI_LICENSEPAGE_TEXT_BOTTOM "Click Next to continue."
!define MUI_LICENSEPAGE_BUTTON "Next >"
!insertmacro MUI_PAGE_LICENSE "${OCTAVE_FORGE}\COPYING.GPL"
; CPU detection page
Page custom AtlasCpu AtlasCpuEnd
; Components page
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Start menu page
var ICONS_GROUP
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "GNU Octave"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
;!define MUI_FINISHPAGE_RUN "$INSTDIR\bin\octave-${OCTAVE_VERSION}.exe"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
!ifdef OCTAVE_CVS_VERSION
OutFile "octave-${OCTAVE_CVS_VERSION}(${OCTAVE_VERSION})-setup.exe"
!else
OutFile "octave-${OCTAVE_VERSION}-setup.exe"
!endif
InstallDir "$PROGRAMFILES\Octave"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

SectionGroup /e "Core" GRP_CORE

Section "Core" SEC_CORE
  SetOutPath "$INSTDIR\bin"
  SetOverwrite try
  ; octave executables
  File "${OCTAVE_ROOT}\bin\cruft.dll"
  File "${OCTAVE_ROOT}\bin\octave-${OCTAVE_VERSION}.exe"
  File "${OCTAVE_ROOT}\bin\octave-bug"
  File "${OCTAVE_ROOT}\bin\octave-bug-${OCTAVE_VERSION}"
  File "${OCTAVE_ROOT}\bin\octave.dll"
  File "${OCTAVE_ROOT}\bin\octave.exe"
  File "${OCTAVE_ROOT}\bin\octinterp.dll"
  File "${OCTAVE_FORGE}\admin\Windows\cygwin\octave.ico"
  ; octave compiled modules
  SetOutPath "$INSTDIR\libexec"
  File /r /x "COM" "${OCTAVE_ROOT}\libexec\*.*"
  ; octave script modules
  SetOutPath "$INSTDIR\share"
  File /r /x "packages" /x "octave_packages" "${OCTAVE_ROOT}\share\*.*"
  ; support libraries and executables
  SetOutPath "$INSTDIR\bin"
  File "${VCLIBS_ROOT}\bin\pcre70.dll"
  File "${VCLIBS_ROOT}\bin\readline.dll"
  File "${VCLIBS_ROOT}\bin\libfftw3-3.dll"
  File "${VCLIBS_ROOT}\bin\hdf5.dll"
  File "${VCLIBS_ROOT}\bin\glpk49.dll"
  File "${VCLIBS_ROOT}\bin\fftw-wisdom.exe"
  File "${VCLIBS_ROOT}\bin\zlib1.dll"
  ; licenses
  SetOutPath "$INSTDIR\license"
  File "/oname=COPYING" "${OCTAVE_FORGE}\COPYING.GPL"
  File "${VCLIBS_ROOT}\license\COPYING.HDF5"
  ; README
  SetOutPath "$INSTDIR"
  File "${OCTAVE_FORGE}\admin\Windows\msvc\README.txt"

; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Octave.lnk" "$INSTDIR\bin\octave-${OCTAVE_VERSION}.exe" "" \
    "$INSTDIR\bin\octave.ico" 0
  CreateShortCut "$DESKTOP\Octave.lnk" "$INSTDIR\bin\octave-${OCTAVE_VERSION}.exe" "" \
    "$INSTDIR\bin\octave.ico" 0
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "Development files" SEC_DEV
  SetOverwrite try
  SetOutPath "$INSTDIR\include"
  File /r "${OCTAVE_ROOT}\include\*.*"
  SetOutPath "$INSTDIR\lib"
  File /r /x *.lib.${OCTAVE_VERSION} /x octave_fixed.lib "${OCTAVE_ROOT}\lib\*.*"
  SetOutPath "$INSTDIR\bin"
  File "${OCTAVE_ROOT}\bin\mkoctfile.exe"
  File "/oname=mkoctfile-${OCTAVE_VERSION}" "${OCTAVE_ROOT}\bin\mkoctfile.exe"
  ;File "${OCTAVE_ROOT}\bin\mkoctfile"
  ;File "${OCTAVE_ROOT}\bin\mkoctfile-${OCTAVE_VERSION}"
  File "${OCTAVE_ROOT}\bin\octave-config.exe"
  File "/oname=octave-config-${OCTAVE_VERSION}" "${OCTAVE_ROOT}\bin\octave-config.exe"
  ;File "${OCTAVE_ROOT}\bin\octave-config"
  ;File "${OCTAVE_ROOT}\bin\octave-config-${OCTAVE_VERSION}"
  File "${VCLIBS_ROOT}\bin\cc-msvc.exe"
  ; Additional dependent library files (required by mkoctfile, although not really used)
  SetOutPath "$INSTDIR\lib"
  File "${VCLIBS_ROOT}\lib\blas.lib"
  File "${VCLIBS_ROOT}\lib\lapack.lib"
  File "${VCLIBS_ROOT}\lib\fftw3.lib"
  File "${VCLIBS_ROOT}\lib\readline.lib"
  File "${VCLIBS_ROOT}\lib\hdf5.lib"
  File "${VCLIBS_ROOT}\lib\zlib.lib"
  File "${VCLIBS_ROOT}\lib\f2c.lib"
  ; Additional headers required by some octave headers
  ; HDF5
  SetOutPath "$INSTDIR\include"
  File "${VCLIBS_ROOT}\include\H5*.h"
  File "${VCLIBS_ROOT}\include\hdf5.h"

; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

!ifdef USE_MSYS
!include "octave_msys.nsi"
!endif

SectionGroup /e "Linear Algebra Libraries" GRP_LINALG

Section "Generic" SEC_LA_GEN
  SetOutPath "$INSTDIR\bin"
  SetOverwrite try
  File /oname=blas.dll "${VCLIBS_ROOT}\bin\blas_f77.dll"
  File /oname=lapack.dll "${VCLIBS_ROOT}\bin\lapack_f77.dll"
SectionEnd

Section /o "P4/SSE2" SEC_LA_P4SSE2
  SetOutPath "$INSTDIR\bin"
  SetOverwrite try
  File /oname=blas.dll "${VCLIBS_ROOT}\bin\blas_atl_P4SSE2.dll"
  File /oname=lapack.dll "${VCLIBS_ROOT}\bin\lapack_atl_P4SSE2.dll"
SectionEnd

!ifdef ATLAS_PM
Section /o "PM/SSE2" SEC_LA_PMSSE2
  SetOutPath "$INSTDIR\bin"
  SetOverwrite try
  File /oname=blas.dll "${VCLIBS_ROOT}\bin\blas_atl_PMSSE2.dll"
  File /oname=lapack.dll "${VCLIBS_ROOT}\bin\lapack_atl_PMSSE2.dll"
SectionEnd
!endif

SectionGroupEnd

Section /o "C/C++ Runtime Libraries" SEC_VC
  ;Call InstallRuntime
  SetOverwrite try
  SetOutPath "$INSTDIR\bin\Microsoft.VC80.CRT"
  File "${VCLIBS_ROOT}\bin\Microsoft.VC80.CRT\*.*"
SectionEnd

SectionGroupEnd

!ifdef USE_OCTAVE_FORGE
SectionGroup "Octave Forge" GRP_FORGE
!include "${OCTAVE_FORGE}\octave_forge.nsi"
SectionGroupEnd
!endif

SectionGroup /e "Graphics" GRP_GRAPHICS

!ifdef JHANDLES_VERSION
Section "JHandles" SEC_JHANDLES
  SetOverwrite try
  SetOutPath "$INSTDIR\share\octave\packages\jhandles-${JHANDLES_VERSION}"
  File /r "${OCTAVE_ROOT}\share\octave\packages\jhandles-${JHANDLES_VERSION}\*"
  SetOutPath "$INSTDIR\bin"
  File "${OCTAVE_ROOT}\bin\jogl.jar"
  File "${OCTAVE_ROOT}\bin\jogl.dll"
  File "${OCTAVE_ROOT}\bin\jogl_awt.dll"
  SetOutPath "$INSTDIR\license"
  File "${VCLIBS_ROOT}\license\COPYING.JOGL"
SectionEnd
!endif

Section "Gnuplot" SEC_GNUPLOT
  SetOverwrite try
  SetOutPath "$INSTDIR\bin"
  File /x "*.dll" /x "*.GID" "${GNUPLOT_ROOT}\bin\*.*"
  File "${VCLIBS_ROOT}\bin\bgd.dll"
  File "${VCLIBS_ROOT}\bin\iconv.dll"
  File "${VCLIBS_ROOT}\bin\intl.dll"
  File "${VCLIBS_ROOT}\bin\jpeg6b.dll"
  File "${VCLIBS_ROOT}\bin\libcairo-2.dll"
  File "${VCLIBS_ROOT}\bin\libglib-2.0-0.dll"
  File "${VCLIBS_ROOT}\bin\libgmodule-2.0-0.dll"
  File "${VCLIBS_ROOT}\bin\libgobject-2.0-0.dll"
  File "${VCLIBS_ROOT}\bin\libgthread-2.0-0.dll"
  File "${VCLIBS_ROOT}\bin\libpango-1.0-0.dll"
  File "${VCLIBS_ROOT}\bin\libpangocairo-1.0-0.dll"
  File "${VCLIBS_ROOT}\bin\libpangowin32-1.0-0.dll"
  File "${VCLIBS_ROOT}\bin\libpng13.dll"
  ;File "${VCLIBS_ROOT}\bin\zlib1.dll"
  SetOutPath "$INSTDIR\etc"
  File /r "${GNUPLOT_ROOT}\etc\*.*"
  SetOutPath "$INSTDIR\share"
  File /r "${GNUPLOT_ROOT}\share\*.*"
  SetOutPath "$INSTDIR\tools\gnuplot"
  File /r /x "bin" /x "share" /x "etc" "${GNUPLOT_ROOT}\*.*"

; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
;  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Help.lnk" "$INSTDIR\bin\wgnuplot.hlp"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

!ifdef USE_OCTPLOT
Section "Octplot" SEC_OPLOT
  SetOverwrite try
  SetOutPath "$INSTDIR\bin"
  File "${VCLIBS_ROOT}\bin\fltkdll.dll"
  File "${VCLIBS_ROOT}\bin\freetype6.dll"
  SetOutPath "$INSTDIR\octplot"
  File /r /x octplot_path.oct /x octplot_redraw.oct "${OCTAVE_ROOT}\octplot\*.*"
  SetOutPath "$INSTDIR\license"
  File "${VCLIBS_ROOT}\license\COPYING.FLTK"
SectionEnd
!endif

SectionGroupEnd

Sectiongroup /e "Documentation" GRP_DOC

Section "HTML" DOC_HTML
  SetOverwrite try
  SetOutPath "$INSTDIR\doc\HTML\faq"
  File "${OCTAVE_SRC}\doc\faq\HTML\*.*"
  SetOutPath "$INSTDIR\doc\HTML\interpreter"
  File "${OCTAVE_SRC}\doc\interpreter\HTML\*.*"
  SetOutPath "$INSTDIR\doc\HTML\liboctave"
  File "${OCTAVE_SRC}\doc\liboctave\HTML\*.*"
  
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP\Documentation\HTML"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Documentation\HTML\Octave.lnk" "$INSTDIR\doc\HTML\interpreter\index.html"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Documentation\HTML\Octave C++ API.lnk" "$INSTDIR\doc\HTML\liboctave\index.html"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Documentation\HTML\FAQ.lnk" "$INSTDIR\doc\HTML\faq\index.html"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "PDF" DOC_PDF
  SetOverwrite try
  SetOutPath "$INSTDIR\doc\PDF"
  File "${OCTAVE_SRC}\doc\faq\Octave-FAQ.pdf"
  File "${OCTAVE_SRC}\doc\interpreter\octave.pdf"
  File "${OCTAVE_SRC}\doc\liboctave\liboctave.pdf"
  File "${OCTAVE_SRC}\doc\refcard\refcard-*.pdf"
  
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP\Documentation\PDF"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Documentation\PDF\Octave.lnk" "$INSTDIR\doc\PDF\octave.pdf"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Documentation\PDF\Quick Refernce Card.lnk" "$INSTDIR\doc\PDF\refcard-a4.pdf"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Documentation\PDF\Octave C++ API.lnk" "$INSTDIR\doc\PDF\liboctave.pdf"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Documentation\PDF\FAQ.lnk" "$INSTDIR\doc\PDF\Octave-FAQ.pdf"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

SectionGroupEnd

SectionGroup /e "Misc" GRP_MISC

Section "Tools" SEC_TOOLS
  SetOutPath "$INSTDIR\bin"
  SetOverwrite try
  File "${VCLIBS_ROOT}\bin\less.exe"
  ;File "${VCLIBS_ROOT}\bin\pcre70.dll"
  File "${VCLIBS_ROOT}\bin\sed.exe"
  File "${VCLIBS_ROOT}\bin\iconv.dll"
  File "${VCLIBS_ROOT}\bin\intl.dll"
  File "${VCLIBS_ROOT}\bin\makeinfo.exe"

; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "SciTE editor" SEC_SCITE
  SetOutPath "$INSTDIR\tools\wscite"
  SetOverwrite try
  File /r /x License.txt "${SCITE_ROOT}\*.*"
  SetOutPath "$INSTDIR\license"
  File /oname=COPYRIGHT.SCITE "${SCITE_ROOT}\License.txt"
  SetOutPath "$INSTDIR"

; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\SciTE editor.lnk" "$INSTDIR\tools\wscite\SciTE.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section /o "Console" SEC_CONSOLE
  SetOutPath "$INSTDIR\tools\console"
  SetOverwrite try
  File /x console.xml "${CONSOLE_ROOT}\*.*"
  IfFileExists "$WINDIR\system32\msvcr71.dll" no_runtime_71
  File "C:\WINDOWS\system32\msvcr71.dll"
  File "C:\WINDOWS\system32\msvcp71.dll"
no_runtime_71:
  StrCpy $0 "$INSTDIR\tools\console\console_oct.xml"
  StrCpy $1 "$INSTDIR\tools\console\console.xml"
  Call ReplaceOctDir
  Delete "$INSTDIR\tools\console\console_oct.xml"

; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Octave.lnk" "$INSTDIR\tools\console\Console.exe" \
	"" "$INSTDIR\bin\octave.ico"
  CreateShortCut "$DESKTOP\Octave.lnk" "$INSTDIR\tools\console\Console.exe" "" \
    "$INSTDIR\bin\octave.ico" 0
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

SectionGroupEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Octave Home Page.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  WriteIniStr "$INSTDIR\Octave-Forge.url" "InternetShortcut" "URL" "${OCTAVE_FORGE_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Octave-Forge Home Page.lnk" "$INSTDIR\Octave-Forge.url"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "$INSTDIR\uninst.exe"
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP\Documentation"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Documentation\README.lnk" "$INSTDIR\README.txt"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\bin\octave-${OCTAVE_VERSION}.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\bin\octave-${OCTAVE_VERSION}.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_KEY}" "InstallPath" "$INSTDIR"
  WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_KEY}" "Version" "${OCTAVE_VERSION}"

  InitPluginsDir
  File "/oname=$PLUGINSDIR\do_pkg_init.m" "${OCTAVE_FORGE}\admin\Windows\msvc\do_pkg_init.m"
  ExecWait '"$INSTDIR\bin\octave.exe" -q "$PLUGINSDIR\do_pkg_init.m"'
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CORE} "Octave core files"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_DEV} "Octave development files (include and library files)"
!ifdef USE_MSYS
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MSYS} "UNIX-like shell environment, required to use the Octave package manager"
!endif
!ifdef USE_OCTAVE_FORGE
  !insertmacro MUI_DESCRIPTION_TEXT ${GRP_FORGE} "Additional toolboxes for Octave"
  !include "${OCTAVE_FORGE}\octave_forge_desc.nsi"
!endif
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_GNUPLOT} "Basic plotting component of Octave. If not selected, Gnuplot binary must in your PATH."
!ifdef USE_OCTPLOT
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_OPLOT} "Alternative graphics/plot engine for Octave"
!endif
!ifdef JHANDLES_VERSION
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_JHANDLES} "Java/OpenGL based 2D/3D graphics backend for Octave with high compatibility with Matlab handle graphics"
!endif
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_TOOLS} "Additional GNU tools required (less, makeinfo, sed...). If not selected, those tools must be available in your PATH."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_VC} "Microsoft C/C++ runtime libraries required by Octave. It is STRONGLY recommended to use the default setting."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_SCITE} "Powerful code editor with syntax highlighting, directly accessible from the octave prompt (http://www.scintilla.org)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CONSOLE} "Advanced console for Windows, with multi-tab and editing capabilities (http://sourceforge.net/projects/console)"
  
  !insertmacro MUI_DESCRIPTION_TEXT ${GRP_CORE} ""
  !insertmacro MUI_DESCRIPTION_TEXT ${GRP_GRAPHICS} ""
  !insertmacro MUI_DESCRIPTION_TEXT ${GRP_MISC} ""
  !insertmacro MUI_DESCRIPTION_TEXT ${GRP_DOC} ""
  !insertmacro MUI_DESCRIPTION_TEXT ${GRP_LINALG} ""
  
  !insertmacro MUI_DESCRIPTION_TEXT ${DOC_HTML} ""
  !insertmacro MUI_DESCRIPTION_TEXT ${DOC_PDF} ""
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_LA_GEN} ""
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_LA_P4SSE2} ""
!ifdef ATLAS_PM
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_LA_PMSSE2} ""
!endif
!insertmacro MUI_FUNCTION_DESCRIPTION_END


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Function .onInit
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "atlascpu.ini"
!ifndef USE_TIMING
  !insertmacro MUI_INSTALLOPTIONS_WRITE "atlascpu.ini" "Settings" "NumFields" "4"
!endif
  !insertmacro MUI_INSTALLOPTIONS_WRITE "atlascpu.ini" "Field 3" "ListItems" "${LA_ALL}"
  !insertmacro SetSectionFlag ${SEC_CORE} ${SF_RO}
  ;!insertmacro SetSectionFlag ${SEC_VC} ${SF_RO}
  !insertmacro SetSectionFlag ${SEC_LA_GEN} ${SF_RO}
  !insertmacro SetSectionFlag ${SEC_LA_P4SSE2} ${SF_RO}
!ifdef ATLAS_PM
  !insertmacro SetSectionFlag ${SEC_LA_PMSSE2} ${SF_RO}
!endif
  Call CheckMSVCR80
  Pop $0
  StrCmp $0 1 noruntime
  ;Call CheckAdmin
  !insertmacro SetSectionFlag ${SEC_VC} ${SF_SELECTED}
noruntime:
  Call DetectJVM
  Pop $0
  StrCmp "" "$0" nojvm jvm
jvm:
  !insertmacro SetSectionFlag ${SEC_JAVA} ${SF_SELECTED}
  !insertmacro SetSectionFlag ${SEC_JHANDLES} ${SF_SELECTED}
  Goto endjvm
nojvm:
  !insertmacro ClearSectionFlag ${SEC_JAVA} ${SF_SELECTED}
  !insertmacro ClearSectionFlag ${SEC_JHANDLES} ${SF_SELECTED}
endjvm:
!ifdef USE_MSYS
  Call DetectMSYS
  Pop $0
  StrCmp $0 1 msys nomsys
msys:
  !insertmacro ClearSectionFlag ${SEC_MSYS} ${SF_SELECTED}
  Goto endmsys
nomsys:
  !insertmacro SetSectionFlag ${SEC_MSYS} ${SF_SELECTED}
endmsys:
!endif
FunctionEnd

Function AtlasCpu
  !insertmacro MUI_HEADER_TEXT "CPU selection" "Choose the CPU type corresponding to your system."
  ReadRegStr $0 HKLM HARDWARE\DESCRIPTION\System\CentralProcessor\0 "ProcessorNameString"
  StrCpy $1 10
  System::Call "kernel32::IsProcessorFeaturePresent(i) &i1 (r1) .r1"
  StrCmp $1 1 0 +4
  StrCpy $1 " (SSE2 detected)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "atlascpu.ini" "Field 3" "State" "${LA_P4}"
  Goto +2
  StrCpy $1 " (SSE2 not detected)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "atlascpu.ini" "Field 2" "Text" "$0$1"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "atlascpu.ini"
FunctionEnd

Function AtlasCpuEnd
  !insertmacro MUI_INSTALLOPTIONS_READ $0 "atlascpu.ini" "Settings" "State"
  StrCmp $0 0 validate
  StrCmp $0 5 timing
  Goto validate
timing:
!ifdef USE_TIMING
  MessageBox MB_ICONINFORMATION|MB_OK "This operation can take a while. Please avoid using your$\ncomputer during the whole process to get correct timing values."
  !insertmacro SectionFlagIsSet ${SEC_VC} ${SF_SELECTED} 0 dotiming
  MessageBox MB_ICONEXCLAMATION|MB_YESNO "This operation requires the installation of the component 'C/C++ Runtime Libraries'.$\nThis component is required by Octave and will be installed anyway.$\n$\nDo you want to continue the timing process?" /SD IDYES IDNO timingabort
  Call InstallRuntime
dotiming:
  Call DoTiming
timingabort:
!endif
  Abort
validate:
  !insertmacro ClearSectionFlag ${SEC_LA_GEN} ${SF_SELECTED}
  !insertmacro ClearSectionFlag ${SEC_LA_P4SSE2} ${SF_SELECTED}
!ifdef ATLAS_PM
  !insertmacro ClearSectionFlag ${SEC_LA_PMSSE2} ${SF_SELECTED}
!endif
  !insertmacro MUI_INSTALLOPTIONS_READ $0 "atlascpu.ini" "Field 3" "State"
  StrCmp $0 "${LA_GEN}" generic0
  StrCmp $0 "${LA_P4}" p4sse20
!ifdef ATLAS_PM
  StrCmp $0 "${LA_PM}" pmsse20
!endif
  Abort "Internal error: unexpected CPU type"
generic0:
  !insertmacro SetSectionFlag ${SEC_LA_GEN} ${SF_SELECTED}
  Goto atlasend
p4sse20:
  !insertmacro SetSectionFlag ${SEC_LA_P4SSE2} ${SF_SELECTED}
  Goto atlasend
!ifdef ATLAS_PM
pmsse20:
  !insertmacro SetSectionFlag ${SEC_LA_PMSSE2} ${SF_SELECTED}
  Goto atlasend
!endif
atlasend:
FunctionEnd

!ifdef USE_TIMING
Function InstallRuntime
  InitPluginsDir
  File "/oname=$PLUGINSDIR\vcredist_x86.exe" "${VCREDIST_FILE}"
  ExecWait '"$PLUGINSDIR\vcredist_x86.exe"'
FunctionEnd

Function DoTiming
  InitPluginsDir
  ClearErrors
  FileOpen $0 "$PLUGINSDIR\blas.desc" w
  IfErrors timingend
  FileWrite $0 "${LA_COUNT}$\n"
  FileWrite $0 "${LA_GEN}$\n"
  FileWrite $0 "$PLUGINSDIR\blas_f77.dll$\n"
  FileWrite $0 "${LA_P4}$\n"
  FileWrite $0 "$PLUGINSDIR\blas_atl_P4SSE2.dll$\n"
!ifdef ATLAS_PM
  FileWrite $0 "${LA_PM}$\n"
  FileWrite $0 "$PLUGINSDIR\blas_atl_PMSSE2.dll$\n"
!endif
  FileClose $0
  File "/oname=$PLUGINSDIR\blas_timer.exe" "${VCLIBS_ROOT}\bin\blas_timer.exe"
  File "/oname=$PLUGINSDIR\blas_f77.dll" "${VCLIBS_ROOT}\bin\blas_f77.dll"
  File "/oname=$PLUGINSDIR\blas_atl_P4SSE2.dll" "${VCLIBS_ROOT}\bin\blas_atl_P4SSE2.dll"
!ifdef ATLAS_PM
  File "/oname=$PLUGINSDIR\blas_atl_PMSSE2.dll" "${VCLIBS_ROOT}\bin\blas_atl_PMSSE2.dll"
!endif
  ExecWait '"$PLUGINSDIR\blas_timer.exe" "$PLUGINSDIR\blas.desc"'
timingend:
FunctionEnd
!endif

Section Uninstall
  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
  RMDir /r "$INSTDIR"

  Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Octave Home Page.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Octave-Forge Home Page.lnk"
;  Delete "$SMPROGRAMS\$ICONS_GROUP\Help.lnk"
  Delete "$DESKTOP\Octave.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Octave.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\SciTE editor.lnk"
  RMDir /r "$SMPROGRAMS\$ICONS_GROUP\Documentation"

  RMDir "$SMPROGRAMS\$ICONS_GROUP"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DeleteRegKey ${PRODUCT_ROOT_KEY} "${PRODUCT_KEY}"
  SetAutoClose true
SectionEnd

Function CheckMSVCR80
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  StrCpy $0 0
  FindFirst $1 $2 "$WINDIR\WinSxS\*"
  loop:
    StrCmp $2 "" done
    FindFirst $3 $4 "$WINDIR\WinSxS\$2\msvcr80.dll"
    FindClose $3
    StrCmp $4 "" 0 found
    FindNext $1 $2
    Goto loop
  found:
    StrCpy $0 1
  done:
    FindClose $0
;  StrCmp $0 0 0 +3
;  MessageBox MB_OK|MB_ICONSTOP "MSVCR80.DLL does not seems to be installed on your system. This component is required by GNU Octave.$\n$\nPlease download the 'Visual C++ 2005 Redistributable Package' for your platform from the Microsoft web$\nsite (http://www.microsoft.com/downloads/) and install it on your system.$\n$\nThen run this installer again."
;  Abort
  Pop $4
  Pop $3
  Pop $2
  Pop $1
;  Pop $0
  Exch $0
FunctionEnd

Function CheckAdmin
  Push $0
  Push $1
  UserInfo::GetName
  IfErrors win9x
  Pop $0
  UserInfo::GetAccountType
  Pop $1
  StrCmp $1 "Admin" win9x
    MessageBox MB_OK|MB_ICONEXCLAMATION|MB_YESNO "Microsoft C/C++ Runtime Libraries have not been found on your system. This$\r$\nrequired component can be installed by the installer, but requires Administrator$\r$\nprivileges. You don't seem to have such privileges.$\r$\n$\r$\nProceed anyway? (Choosing 'Yes' may lead to installation failure)" IDYES win9x
    Abort
  win9x:
  Pop $1
  Pop $0
FunctionEnd

Function ReplaceOctDir
  Push $0
  Push $1
  Push $2
  Push $3
  ClearErrors
  FileOpen $2 $0 r
  IfErrors done
  FileOpen $3 $1 w
  IfErrors close
doit:
  FileRead $2 $0
  StrCmp $0 "" close1 0
  ${WordReplace} $0 "@OCTAVE_DIR@" "$INSTDIR" "+" $1
  FileWrite $3 $1
  Goto doit
close1:
  FileClose $3
close:
  FileClose $2
done:
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd

Function DetectJVM
  Push $0
  ReadRegStr $0 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" CurrentVersion
  Exch $0
FunctionEnd

!ifdef USE_MSYS
Function DetectMSYS
  Push $0
  StrCpy $0 1
  IfFileExists "$WINDIR\MSYS.INI" done
  StrCpy $0 0
done:
  Exch $0
FunctionEnd
!endif
