#
# NSI script for octave windows
# $Id$
#

# http://nsis.sourceforge.net/Docs
# Sort out command line parameters

!ifndef VERSION
!error "Start MakeNSIS with /DVERSION=2.1.xx [/DMINOR=-yyyymmdd] [/DROOT=C:\cygwin] octave.nsi"
!endif
!ifndef MINOR
!define MINOR ""
!endif
!ifndef ROOT
!define ROOT "C:\cygwin"
!endif

; Product and version
!include "MUI.nsh"
!define MUI_PRODUCT "GNU Octave ${VERSION}"
!define MUI_VERSION "${VERSION}${MINOR}"

XPStyle on
CrcCheck on
	
OutFile "octave-${MUI_VERSION}-inst.exe"
Icon "octave.ico"
UninstallIcon "octave.ico"

;-------------------------------
;Version Information

VIProductVersion "${VERSION}.0"
VIAddVersionKey "ProductName" "GNU Octave"
VIAddVersionKey "FileVersion" "${VERSION}.0"
VIAddVersionKey "LegalCopyright" "© John W. Eaton, et al."
VIAddVersionKey "FileDescription" "Octave+octave-forge+gnuplot"

# ****************** Localization ***********************
; Translate the following strings into all the languages
; that we support for the installer.  Some things may not
; yet be translated.  Search for the following strings:
;
;    Spanish  ;ESP

LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\Spanish.nlf"

; License data files --- put a translation of the GPL into
; the root of the octave-forge tree.
LicenseLangString LicenseFile ${LANG_ENGLISH} "..\..\COPYING.GPL"
LicenseLangString LicenseFile ${LANG_SPANISH} "..\..\COPYING.GPL-spanish"

;ESP
LangString LicenseTextStr ${LANG_ENGLISH} "GNU Octave is free software released under the GNU Public License.  Read below for your rights:" 
LangString LicenseTextStr ${LANG_SPANISH} "GNU Octave is free software released under the GNU Public License.  Read below for your rights:" 

LangString ^ComponentsText ${LANG_ENGLISH} "${MUI_PRODUCT} Setup"
LangString ^ComponentsText ${LANG_SPANISH} "Instalación de ${MUI_PRODUCT}"

LangString installcaption ${LANG_ENGLISH} "${MUI_PRODUCT} Setup"
LangString installcaption ${LANG_SPANISH} "Instalación de ${MUI_PRODUCT}"

LangString uninstcaption ${LANG_ENGLISH} "Uninstall ${MUI_PRODUCT}"
LangString uninstcaption ${LANG_SPANISH} "Desintalar de ${MUI_PRODUCT}"

LangString TITLE_Section1 ${LANG_ENGLISH} "${MUI_PRODUCT}"
LangString TITLE_Section1 ${LANG_SPANISH} "${MUI_PRODUCT}"

LangString DESC_Section1 ${LANG_ENGLISH} "Install the ${MUI_PRODUCT} for Windows binary distribution including gnuplot, epstk and the octave-forge extensions."
LangString DESC_Section1 ${LANG_SPANISH} "Instalar la version ejecutable the ${MUI_PRODUCT} para Windows la cual incluye gnuplot, epstk y las extensiones de octave-forge."

LangString TITLE_Section2 ${LANG_ENGLISH} "Start Menu Icons"
LangString TITLE_Section2 ${LANG_SPANISH} "Iconos de Menú de Inicio"

LangString DESC_Section2 ${LANG_ENGLISH} "Add a ${MUI_PRODUCT} folder to the Start Menu."
LangString DESC_Section2 ${LANG_SPANISH} "Agregar una carpeta de ${MUI_PRODUCT} al Menú de Inicio."

LangString TITLE_Section3 ${LANG_ENGLISH} "Desktop Icons"
LangString TITLE_Section3 ${LANG_SPANISH} "Iconos de Escritorio"

LangString DESC_Section3 ${LANG_ENGLISH} "Add a ${MUI_PRODUCT} icon to the Desktop."
LangString DESC_Section3 ${LANG_SPANISH} "Agregar un icono de ${MUI_PRODUCT} al Escritorio."

LangString UninstallLink ${LANG_ENGLISH} "$SMPROGRAMS\${MUI_PRODUCT}\Uninstall ${MUI_PRODUCT}.lnk"
LangString UninstallLink ${LANG_SPANISH} "$SMPROGRAMS\${MUI_PRODUCT}\Desinstalar ${MUI_PRODUCT}.lnk"

LangString ManualLink ${LANG_ENGLISH} "$SMPROGRAMS\${MUI_PRODUCT}\${MUI_PRODUCT} Manual (HTML).lnk"
LangString ManualLink ${LANG_SPANISH} "$SMPROGRAMS\${MUI_PRODUCT}\Manual de ${MUI_PRODUCT} (HTML).lnk"

LangString FunctionLink ${LANG_ENGLISH} "$SMPROGRAMS\${MUI_PRODUCT}\OctaveForge Quick Reference (HTML).url"
LangString FunctionLink ${LANG_SPANISH} "$SMPROGRAMS\${MUI_PRODUCT}\Refencia Rápida de OctaveForge (HTML).url"

LangString EpstkLink ${LANG_ENGLISH} "$SMPROGRAMS\${MUI_PRODUCT}\Epstk Manual (HTML).url"
LangString EpstkLink ${LANG_SPANISH} "$SMPROGRAMS\${MUI_PRODUCT}\Manual de Epstk (HTML).url"

LangString RefcardLink ${LANG_ENGLISH} "$SMPROGRAMS\${MUI_PRODUCT}\${MUI_PRODUCT} Quick Reference (PDF).lnk"
LangString RefcardLink ${LANG_SPANISH} "$SMPROGRAMS\${MUI_PRODUCT}\Refencia Rápida de ${MUI_PRODUCT} (PDF).lnk"

LangString PreviousCygwin ${LANG_ENGLISH} "A previous installation of cygwin was detected. This package is not to be used from within a cygwin enviroment. Click OK if you want to continue anyway or CANCEL if you want to abort the installation process."
LangString PreviousCygwin ${LANG_SPANISH} "Se detectó una versión de cygwin instalada. Este paquete no fue diseñado para funcionar dentro de un ambiente de cygwin. Presione Aceptar si desea continuar o Cancelar si desea detener el preceso de instalación."

LangString PreviousOctave ${LANG_ENGLISH} "A previous version of Octave ${VERSION} for Windows was detected. Please uninstall any previous version before running this installer. Click OK if you want to continue anyway or CANCEL if you want to abort the installation process."
LangString PreviousOctave ${LANG_SPANISH} "Se detectó una versión anterior de Octave ${VERSION} para Windows. Por favor desinstale cualquier versión anterior antes de ejecutar este instalador. Presione Aceptar si desea continuar o Cancelar si desea detener el proceso de instalación."

LangString GenuineIntel ${LANG_ENGLISH} "This version of Octave for Windows is optimized for Intel x86 processors and is known to cause troubles with other architectures. Click OK if you want to continue anyway or CANCEL if you want to abort the installation process."
LangString GenuineIntel ${LANG_SPANISH} "Esta versión de Octave para Windows ha sido optimizada para procesadores Intel x86 y puede no funcionar correctamente sobre otros procesadores. Presione Aceptar si desea continuar o Cancelar si desea detener el proceso de instalación."

;ESP
LangString Donation ${LANG_ENGLISH} "Octave needs your support!  Please donate to the University of Wisconsin Foundation, dedicated as follows:"
LangString Donation ${LANG_SPANISH} "Octave needs your support!  Please donate to the University of Wisconsin Foundation, dedicated as follows:"

; This function is for choosing languages.  If you add
; a new language, you will need to add the name of the
; language to this function in order for the user to
; select it.
Function ChooseLanguage
  Push ""
  Push ${LANG_ENGLISH}
  Push "English"
  Push ${LANG_SPANISH}
  Push "Español"
  Push A ; A means auto count languages
  ; for the auto count to work the first empty push (Push "") must remain
  LangDLL::LangDialog "Installer Language" "Please select the language of the installer"
  Pop $LANGUAGE
  StrCmp "$LANGUAGE" "cancel" Cancel
  Return
  Cancel:
  Abort
FunctionEnd

Function .onInit
  Push Tahoma
  Push 8
  Call ChooseLanguage
FunctionEnd

# ****************** End Localization ***********************

LicenseText $(LicenseTextStr) $(^NextBtn)
LicenseData $(LicenseFile)
Name "${MUI_PRODUCT}"
Caption $(installcaption)
UninstallCaption $(uninstcaption)

; Page structure
!include "MUI.nsh"
Page license BeforeFirstPage
Page components
Page directory
Page instfiles
PageEx license
  LicenseText $(Donation) $(^CloseBtn)
  LicenseData donation.txt
PageExEnd
UninstPage uninstConfirm
UninstPage instfiles

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT Section1 $(DESC_Section1)
!insertmacro MUI_DESCRIPTION_TEXT Section2 $(DESC_Section2)
!insertmacro MUI_DESCRIPTION_TEXT Section3 $(DESC_Section3)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; This is the command to start octave.
!define OctaveStart "rxvt.exe --keysym.0xFF50 '^a' --keysym.0xFF57 '^e' --keysym.0xFFFF '^f^h' -tn linux -title '${MUI_PRODUCT}' -geometry 80x25 -e /bin/sh  /opt/octave-${VERSION}/bin/start_octave.sh"

!define OCTKEY "GNUOctave ${VERSION}"
!define CYGKEY "${OCTKEY}\Cygwin"
!define MOUNTKEY "${CYGKEY}\mounts v2"

InstallDir "$PROGRAMFILES\${MUI_PRODUCT}"

; Files and registry keys
Section !$(TITLE_Section1) Section1

  CreateDirectory $INSTDIR\tmp
  CreateDirectory $INSTDIR\octave_files
  CreateDirectory $INSTDIR\cygwin
  CreateDirectory $INSTDIR\bin
  CreateDirectory $INSTDIR\base
  CreateDirectory $INSTDIR\site
  SetOutPath $INSTDIR\cygwin
  File "${ROOT}\cygwin\*.*"
  SetOutPath $INSTDIR\bin
  File install_octave.sh start_octave.sh
  File octave.ico
  File /r ${ROOT}\bin\*.*
  SetOutPath $INSTDIR\base
  File /r ${ROOT}\base\*.*
  SetOutPath $INSTDIR\site
  File /r ${ROOT}\site\*.*
  SetOutPath $INSTDIR\doc
  File /r ${ROOT}\doc\*.*
  WriteUninstaller "$INSTDIR\uninstall.exe"

  ;Write language to the registry (for the uninstaller)
  WriteRegStr HKCU "Software\${OCTKEY}" "Installer Language" $LANGUAGE

  ;File associations --- don't conflict with matlab's entries
  ClearErrors
  ReadRegStr $1 HKCR "" ".m"
  StrCmp $1 "matfile" Matlab NoMatlab
  NoMatlab:
  DetailPrint ";File associations for .m files"
  WriteRegStr HKCR ".m" "" "octfile"
  WriteRegStr HKCR "octfile" "" "Octave Script File"
  WriteRegStr HKCR "octfile\DefaultIcon" "" "$INSTDIR\bin\octave.ico"
  WriteRegStr HKCR "octfile\Shell\open\command" "" '"$WINDIR\notepad.exe" "%1"'
  Matlab:

  DetailPrint ";Cygwin's registry entries"
  WriteRegStr HKLM \
	"SOFTWARE\${MOUNTKEY}\/" "native" "$INSTDIR"
  WriteRegDWORD HKLM \
	"SOFTWARE\${MOUNTKEY}\/" "flags" "a"
  WriteRegStr HKLM \
	"SOFTWARE\${MOUNTKEY}\/bin" "native" "$INSTDIR/cygwin"
  WriteRegDWORD HKLM \
	"SOFTWARE\${MOUNTKEY}\/bin" "flags" "rx"
  WriteRegStr HKLM \
	"SOFTWARE\${MOUNTKEY}\/opt/octave-${VERSION}" "native" "$INSTDIR"
  WriteRegDWORD HKLM \
	"SOFTWARE\${MOUNTKEY}\/opt/octave-${VERSION}" "flags" "a"
  WriteRegStr HKLM \
	"SOFTWARE\${CYGKEY}\Program Options" "temp" "temp"
  DeleteRegValue HKLM \
	"SOFTWARE\${CYGKEY}\Program Options" "temp"

  WriteRegStr HKU \
	".DEFAULT\Software\${MOUNTKEY}\/" "native" "$INSTDIR"
  WriteRegDWORD HKU \
	".DEFAULT\Software\${MOUNTKEY}\/" "flags" "a"
  WriteRegStr HKU \
	".DEFAULT\Software\${MOUNTKEY}\/bin" "native" "$INSTDIR/cygwin"
  WriteRegDWORD HKU \
	".DEFAULT\Software\${MOUNTKEY}\/bin" "flags" "rx"
  WriteRegStr HKU \
	".DEFAULT\Software\${MOUNTKEY}\/opt/octave-${VERSION}" \
	"native" "$INSTDIR"
  WriteRegDWORD HKU \
	".DEFAULT\Software\${MOUNTKEY}\/opt/octave-${VERSION}" "flags" "a"
  WriteRegStr HKU \
	".DEFAULT\Software\${CYGKEY}\Program Options" "temp" "temp"
  DeleteRegValue HKU \
	".DEFAULT\Software\${CYGKEY}\Program Options" "temp"

  WriteRegStr HKCU \
	"Software\${MOUNTKEY}\/" "cygdrive prefix" "/cygdrive"
  WriteRegDWORD HKCU \
	"Software\${MOUNTKEY}\/" "cygdrive flags" "22"
  WriteRegStr HKCU \
	"Software\${CYGKEY}\Program Options" "temp" "temp"
  DeleteRegValue HKCU \
	"Software\${CYGKEY}\Program Options" "temp"

  ;Uninstaller registry entries
  WriteRegStr HKLM \
	"Software\Microsoft\Windows\CurrentVersion\Uninstall\${OCTKEY}" \
	"DisplayName" "${MUI_PRODUCT}"
  WriteRegStr HKLM \
	"Software\Microsoft\Windows\CurrentVersion\Uninstall\${OCTKEY}" \
	"DisplayIcon" "$INSTDIR\bin\octave.ico"
  WriteRegStr HKLM \
	"Software\Microsoft\Windows\CurrentVersion\Uninstall\${OCTKEY}" \
	"UninstallString" "$INSTDIR\uninstall.exe"
SectionEnd

; Start menu shortcuts
Section !$(TITLE_Section2) Section2
  CreateDirectory "$SMPROGRAMS\${MUI_PRODUCT}"
  CreateShortCut $(UninstallLink) \
	"$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\${MUI_PRODUCT}\${MUI_PRODUCT}.lnk" \
	"$INSTDIR\bin\run.exe" "${OctaveStart}" "$INSTDIR\bin\octave.ico" 0
  CreateShortCut $(ManualLink) \
	"$INSTDIR\opt\octave\doc\octave_toc.html"
  CreateShortCut $(RefcardLink) \
	"$INSTDIR\opt\octave\doc\refcard-letter.pdf"
  WriteINIStr $(FunctionLink) "InternetShortcut" "URL" \
	"http://octave.sourceforge.net/index/index.html"
  WriteINIStr $(EpstkLink) "InternetShortcut" "URL" \
	"http://epstk.sourceforge.net/epstk/quickref/index.html"
SectionEnd

; Desktop shortcuts
Section !$(TITLE_Section3) Section3
  CreateShortCut "$DESKTOP\${MUI_PRODUCT}.lnk" \
	"$INSTDIR\bin\run.exe" "${OctaveStart}" "$INSTDIR\bin\octave.ico" 0
SectionEnd

!ifdef SKIP
; Make links to drives
!include "DetectDrives.nsi"
Function MakeDriveLink
   StrCpy $R2 $R0 1
   DetailPrint "ln -sf /cygdrive/$R2 /$R2"
   # Need PATH=/bin here because the default path is the windows path.
   # We could try running $INSTDIR\bin\ln.exe directly.
   Exec `$INSTDIR\bin\sh.exe -c "PATH=/bin /bin/ln.exe -sf /cygdrive/$R2 /$R2"`
FunctionEnd
Section "-Make drive links"
   Push "All Local Drives"
   Push $0
   GetFunctionAddress $0 "MakeDriveLink"
   Exch $0
   Call DetectDrives
SectionEnd
!endif

; Post-installation configuration
Section "-Local Config"
  Exec "$INSTDIR\bin\run.exe rxvt -e /opt/octave-${VERSION}/bin/install_octave.sh"
SectionEnd

; Tests which are done before the first page, but can't
; be done in .onInit since LangStrings do not work in
; the .onInit function.
Function BeforeFirstPage
  ; We may be Intel-specific, especially if compiled against ATLAS.
  ClearErrors
  ReadRegStr $1 HKLM "HARDWARE\DESCRIPTION\System\CentralProcessor\0\" "VendorIdentifier"
  StrCmp $1 "GenuineIntel" Continue0 Error0
  Error0:
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION $(GenuineIntel) IDOK Continue0
    Abort
  Continue0:

  ; Detect an existing Octave installation
  ClearErrors
  ReadRegDWORD $1 HKLM "SOFTWARE\${MOUNTKEY}\/" flags
  IfErrors Continue1 Error1
  Error1:
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION $(PreviousOctave) IDOK Continue1
    Abort
  Continue1:

  ; Detect an existing Cygwin installation
  ClearErrors
  ReadRegDWORD $1 HKLM "SOFTWARE\Cygnus Solutions" flags
  IfErrors Continue2 Error2
  Error2:
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION $(PreviousCygwin) IDOK Continue2
    Abort
  Continue2:
FunctionEnd

Section "Uninstall"
  ClearErrors

  ; Clear file associations
  ReadRegStr $1 HKCR "" ".m"
  StrCmp $1 "octfile" NoMatlab Matlab
  NoMatlab:
  DeleteRegKey HKCR ".m"
  Matlab:
  DeleteRegKey HKCR "octfile\DefaultIcon"
  DeleteRegKey HKCR "octfile\Shell\open\command"
  DeleteRegKey HKCR "octfile"

  ; Clean up registry
  DeleteRegKey HKLM "SOFTWARE\${OCTKEY}"
  DeleteRegKey HKU ".DEFAULT\Software\${OCTKEY}"
  DeleteRegKey HKCU "Software\${OCTKEY}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${OCTKEY}"
  ;; The following used value is now stored in GNU Octave, which is cleaned above.
  ; DeleteRegKey HKCU "Software\${MUI_PRODUCT}" "Installer Language"

  ; Clean up start menu
  Delete "$DESKTOP\${MUI_PRODUCT}.lnk"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\*.*"
  Delete "$INSTDIR\*.*"
  RMDir "$SMPROGRAMS\${MUI_PRODUCT}"

  ; Clean up files
  RMDir /r "$INSTDIR"

  ;Display the Finish header 
SectionEnd

Function un.onInit
  ;Get language from registry
  ReadRegStr $LANGUAGE HKCU "Software\${OCTKEY}" "Installer Language"
FunctionEnd
