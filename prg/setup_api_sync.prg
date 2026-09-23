*------------------------------------------------------------------------------
* setup_api_sync.prg
*   Agrega campo LAPI_REST a respaldos.dbf y modifica frmrespaldos.scx
*   para incluir un OptionGroup (radio button) que permita elegir entre
*   "MySQL Directo" y "API REST"
*
*   Ejecutar UNA SOLA VEZ desde la ventana de comandos de VFP:
*     DO setup_api_sync
*------------------------------------------------------------------------------

* Derivar raíz del proyecto dinámicamente
LOCAL lcAppRoot
lcAppRoot = ADDBS(JUSTPATH(JUSTPATH(SYS(16))))

CLOSE DATABASES ALL
SET SAFETY OFF

*=== 1. Verificar/Agregar campo LAPI_REST en respaldos.dbf ===
IF !FILE(lcAppRoot+"data\respaldos.dbf")
    MESSAGEBOX("No se encuentra respaldos.dbf en " + lcAppRoot + "data\",48)
    RETURN
ENDIF

USE (lcAppRoot+"data\respaldos.dbf") IN 0 SHARED
SELECT respaldos
nCampos = AFIELDS(laEstructura)
llExiste = .F.
FOR nI = 1 TO nCampos
    IF UPPER(ALLTRIM(laEstructura[nI,1])) == "LAPI_REST"
        llExiste = .T.
        EXIT
    ENDIF
ENDFOR

IF !llExiste
    SELECT respaldos
    USE
    USE (lcAppRoot+"data\respaldos.dbf") EXCLUSIVE
    ALTER TABLE respaldos ADD COLUMN lapi_rest L
    MESSAGEBOX("Campo LAPI_REST agregado a respaldos.dbf",64)
ENDIF
SELECT respaldos
USE

*=== 2. Agregar OptionGroup a frmrespaldos.scx ===
LOCAL lcScxPath, lcSctPath, lcFormName
lcScxPath = lcAppRoot+"formularios\frmrespaldos.scx"
lcSctPath = lcAppRoot+"formularios\frmrespaldos.sct"

IF !FILE(lcScxPath)
    MESSAGEBOX("No se encuentra " + lcScxPath,48)
    RETURN
ENDIF

* Abrir SCX como tabla
USE (lcScxPath) IN 0 EXCLUSIVE ALIAS form_scx
SELECT form_scx

* Buscar nombre del formulario
LOCATE FOR UPPER(ALLTRIM(CLASS)) == "FORM" AND EMPTY(ALLTRIM(PARENT))
IF !FOUND()
    * Intentar con el primer registro
    GO TOP
ENDIF
lcFormName = ALLTRIM(OBJNAME)
IF EMPTY(lcFormName)
    lcFormName = "frmrespaldos"
ENDIF

* Verificar si ya existe el OptionGroup
LOCATE FOR UPPER(ALLTRIM(OBJNAME)) == "OPGRUPOAPI"
IF FOUND()
    MESSAGEBOX("El OptionGroup OPGRUPOAPI ya existe en el formulario",64)
    SELECT form_scx
    USE
    RETURN
ENDIF

* Generar IDs unicos
lcIdGrp  = SYS(2015)  && OptionGroup
lcIdOpt1 = SYS(2015)  && Option1 (MySQL)
lcIdOpt2 = SYS(2015)  && Option2 (API REST)

*--- Insertar OptionGroup (objeto padre) ---
SELECT form_scx
APPEND BLANK
REPLACE PLATFORM  WITH "WINDOWS"
REPLACE UNIQUEID  WITH lcIdGrp
REPLACE TIMESTAMP WITH INT((DATETIME() - {^2000-01-01}) * 86400)
REPLACE CLASS     WITH "OptionGroup"
REPLACE CLASSLOC  WITH ""
REPLACE BASECLASS WITH "OptionGroup"
REPLACE OBJNAME   WITH "opgrupoapi"
REPLACE PARENT    WITH lcFormName
REPLACE PROPERTIES WITH ;
    "This.Name = " + Chr(34) + "opgrupoapi" + Chr(34) + CRLF + ;
    "This.ControlCount = 2" + CRLF + ;
    "This.Value = " + IIF(llExiste OR RECCOUNT("respaldos")>0, "IIF(respaldos.lapi_rest,2,1)", "1") + CRLF + ;
    "This.Top = 10" + CRLF + ;
    "This.Left = 10" + CRLF + ;
    "This.Width = 210" + CRLF + ;
    "This.Height = 55" + CRLF + ;
    "This.AutoSize = .T." + CRLF + ;
    "This.Visible = .T." + CRLF + ;
    "This.Enabled = .T." + CRLF + ;
    "This.TabIndex = 100" + CRLF + ;
    "This.ControlSource = ""respaldos.lapi_rest""" + CRLF + ;
    "This.SpecialEffect = 0" + CRLF + ;
    "This.BorderStyle = 1" + CRLF + ;
    "This.InteractiveChange = THISFORM.opgrupoapi_InteractiveChange" + CRLF

*--- Insertar Option1 (MySQL Directo) ---
SELECT form_scx
APPEND BLANK
REPLACE PLATFORM  WITH "WINDOWS"
REPLACE UNIQUEID  WITH lcIdOpt1
REPLACE TIMESTAMP WITH INT((DATETIME() - {^2000-01-01}) * 86400)
REPLACE CLASS     WITH "OptionButton"
REPLACE CLASSLOC  WITH ""
REPLACE BASECLASS WITH "OptionButton"
REPLACE OBJNAME   WITH "opgmysql"
REPLACE PARENT    WITH "opgrupoapi"
REPLACE PROPERTIES WITH ;
    "This.Name = " + Chr(34) + "opgmysql" + Chr(34) + CRLF + ;
    "This.Caption = " + Chr(34) + "MySQL Directo" + Chr(34) + CRLF + ;
    "This.Top = 5" + CRLF + ;
    "This.Left = 10" + CRLF + ;
    "This.Width = 180" + CRLF + ;
    "This.Height = 20" + CRLF + ;
    "This.AutoSize = .T." + CRLF + ;
    "This.Visible = .T." + CRLF + ;
    "This.Enabled = .T." + CRLF + ;
    "This.TabIndex = 1" + CRLF + ;
    "This.Style = 0" + CRLF + ;
    "This.FontName = " + Chr(34) + "Arial" + Chr(34) + CRLF + ;
    "This.FontSize = 9" + CRLF

*--- Insertar Option2 (API REST) ---
SELECT form_scx
APPEND BLANK
REPLACE PLATFORM  WITH "WINDOWS"
REPLACE UNIQUEID  WITH lcIdOpt2
REPLACE TIMESTAMP WITH INT((DATETIME() - {^2000-01-01}) * 86400)
REPLACE CLASS     WITH "OptionButton"
REPLACE CLASSLOC  WITH ""
REPLACE BASECLASS WITH "OptionButton"
REPLACE OBJNAME   WITH "opgapi"
REPLACE PARENT    WITH "opgrupoapi"
REPLACE PROPERTIES WITH ;
    "This.Name = " + Chr(34) + "opgapi" + Chr(34) + CRLF + ;
    "This.Caption = " + Chr(34) + "API REST" + Chr(34) + CRLF + ;
    "This.Top = 28" + CRLF + ;
    "This.Left = 10" + CRLF + ;
    "This.Width = 180" + CRLF + ;
    "This.Height = 20" + CRLF + ;
    "This.AutoSize = .T." + CRLF + ;
    "This.Visible = .T." + CRLF + ;
    "This.Enabled = .T." + CRLF + ;
    "This.TabIndex = 2" + CRLF + ;
    "This.Style = 0" + CRLF + ;
    "This.FontName = " + Chr(34) + "Arial" + Chr(34) + CRLF + ;
    "This.FontSize = 9" + CRLF

*=== 3. Agregar metodo InteractiveChange al formulario ===
SELECT form_scx
LOCATE FOR UPPER(ALLTRIM(OBJNAME)) == lcFormName AND EMPTY(ALLTRIM(PARENT))
IF FOUND()
    lcMetodos = ALLTRIM(METHODS)
    IF AT("opgrupoapi_InteractiveChange", lcMetodos) = 0
        REPLACE METHODS WITH lcMetodos + CRLF + ;
            "PROCEDURE opgrupoapi_InteractiveChange" + CRLF + ;
            "    IF THISFORM.opgrupoapi.Value = 2" + CRLF + ;
            "        respaldos.lapi_rest = .T." + CRLF + ;
            "    ELSE" + CRLF + ;
            "        respaldos.lapi_rest = .F." + CRLF + ;
            "    ENDIF" + CRLF + ;
            "ENDPROC" + CRLF
    ENDIF
ENDIF

SELECT form_scx
USE
USE (lcSctPath) IN 0 EXCLUSIVE ALIAS form_sct
SELECT form_sct
USE

MESSAGEBOX("Formulario frmrespaldos.scx modificado con exito!" + CHR(13) + ;
    "Se ha agregado el OptionGroup 'opgrupoapi' con las opciones:" + CHR(13) + ;
    "  - MySQL Directo (default)" + CHR(13) + ;
    "  - API REST" + CHR(13) + CHR(13) + ;
    "Abra el formulario en el Form Designer para ajustar posicion y tamaño.",64)

CLOSE DATABASES ALL
