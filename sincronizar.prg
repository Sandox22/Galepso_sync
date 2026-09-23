* sincronizar.prg
* Motor de Sincronizacion de Vendedores y Clientes (VFP -> MariaDB)

* --- CONFIGURACION DE MODO SIGILOSO (HEADLESS) ---
_SCREEN.Visible = .F.
SYS(2335, 0)

SET SAFETY OFF
SET TALK OFF
SET NOTIFY OFF
SET NOTIFY CURSOR OFF
SET EXCLUSIVE OFF
SET CPDIALOG OFF
SET REPROCESS TO AUTOMATIC

ON ERROR DO ManejadorErrores WITH ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO()
* -------------------------------------------------

LOCAL lcJsonPath, lcJsonStr, loScript
LOCAL lcServer, lcPort, lcUser, lcPass, lcDB, lcDirData
LOCAL llSyncVend, llSyncCli, llSyncPed
LOCAL lcConnStr, lnConn
LOCAL lcLogFile, lcErrorFile

lcLogFile = "sync_log.txt"
lcErrorFile = "error_sync.txt"

DO EscribirLog WITH "Iniciando", lcLogFile

* 1. LECTURA Y SANITIZACIÓN DEL JSON
lcJsonPath = "config.json"
IF !FILE(lcJsonPath)
    STRTOFILE("Error: No se encontro config.json" + CHR(13)+CHR(10), lcErrorFile, 1)
    QUIT
ENDIF

lcJsonStr = FILETOSTR(lcJsonPath)

* Limpiar posible firma BOM de UTF-8 al inicio del archivo
IF LEFT(lcJsonStr, 3) = CHR(239) + CHR(187) + CHR(191)
    lcJsonStr = SUBSTR(lcJsonStr, 4)
ENDIF

* Limpiar saltos de línea y tabulaciones para evitar errores multilínea en JScript
lcJsonStr = STRTRAN(lcJsonStr, CHR(13), "")
lcJsonStr = STRTRAN(lcJsonStr, CHR(10), "")
lcJsonStr = STRTRAN(lcJsonStr, CHR(9), "")

LOCAL llErrorParseo
llErrorParseo = .F.

TRY
    loScript = CREATEOBJECT("MSScriptControl.ScriptControl")
    loScript.Language = "JScript"
    * Se envuelve en paréntesis para evaluar como expresión de objeto pura
    loScript.ExecuteStatement("var config = (" + lcJsonStr + ");")
    
    * Extracción de credenciales (Asegúrate de usar los nombres exactos que genera Python)
    lcServer   = loScript.Eval("config.database.server")
    lcPort     = loScript.Eval("config.database.port")
    lcUser     = loScript.Eval("config.database.user")
    lcPass     = loScript.Eval("config.database.password")
    lcDB       = loScript.Eval("config.database.database")
    
    LOCAL lcSyncVendStr, lcSyncCliStr
    
    lcSyncVendStr = UPPER(ALLTRIM(TRANSFORM(loScript.Eval("config.modules.vendedores"))))
    llSyncVend = INLIST(lcSyncVendStr, ".T.", "TRUE", "1")

    lcSyncCliStr = UPPER(ALLTRIM(TRANSFORM(loScript.Eval("config.modules.clientes"))))
    llSyncCli = INLIST(lcSyncCliStr, ".T.", "TRUE", "1")
    
    LOCAL lcSyncPedStr
    lcSyncPedStr = UPPER(ALLTRIM(TRANSFORM(loScript.Eval("config.modules.pedidos"))))
    llSyncPed = INLIST(lcSyncPedStr, ".T.", "TRUE", "1")

CATCH TO loErr
    LOCAL lcDetalleError
    lcDetalleError = "Error de parseo JSON. Detalle: " + TRANSFORM(loErr.Message) + " / " + TRANSFORM(loErr.Description)
    STRTOFILE(lcDetalleError + CHR(13)+CHR(10), lcErrorFile, 1)
    llErrorParseo = .T.
ENDTRY

IF llErrorParseo
    QUIT
ENDIF

* Requerimiento explícito: Ruta de los DBF hardcodeada a X:\Galepso\Data\Emp6\
lcDirData = "X:\Galepso\Data\Emp6\"

* Regla OBLIGATORIA (GEMINI.md): SQLSETPROP(0, "DispLogin", 3) antes de SQLSTRINGCONNECT()
SQLSETPROP(0, "DispLogin", 3)

lcConnStr = "DRIVER={MySQL ODBC 3.51 Driver};SERVER=" + TRANSFORM(lcServer) + ;
            ";PORT=" + TRANSFORM(lcPort) + ";DATABASE=" + TRANSFORM(lcDB) + ;
            ";UID=" + TRANSFORM(lcUser) + ";PWD=" + TRANSFORM(lcPass) + ";OPTION=3;"

lnConn = SQLSTRINGCONNECT(lcConnStr)

IF lnConn <= 0
    LOCAL ARRAY laErr[1]
    AERROR(laErr)
    DO EscribirLog WITH "ERROR Conexion: " + TRANSFORM(laErr[2]), lcErrorFile
    QUIT
ENDIF

DO EscribirLog WITH "Conexion exitosa", lcLogFile

IF llSyncVend
    DO EscribirLog WITH "Sincronizando Vendedores...", lcLogFile
    DO SyncVendedores WITH lnConn, lcDirData, lcErrorFile
ENDIF

IF llSyncCli
    DO EscribirLog WITH "Sincronizando Clientes...", lcLogFile
    DO SyncClientes WITH lnConn, lcDirData, lcErrorFile
ENDIF

IF llSyncPed
    DO EscribirLog WITH "Sincronizando Pedidos (Bajada)...", lcLogFile
    DO prg\pedidos.prg WITH lnConn
ENDIF

SQLDISCONNECT(lnConn)
DO EscribirLog WITH "Finalizado", lcLogFile

QUIT

*---------------------------------------------------------
PROCEDURE SyncVendedores
LPARAMETERS tnConn, tcDirData, tcErrorFile
LOCAL lcTabla, lcSQL, lnRet, lcCod, lcNom, lcVenCedula

lcTabla = tcDirData + "tvendedores.dbf"
IF FILE(lcTabla)
    * Apertura defensiva de tablas según Reglas
    IF !USED("vendedores")
        USE (lcTabla) SHARED IN 0 ALIAS vendedores
    ENDIF

    SELECT vendedores
    EscribirLog("Iniciando envío de Vendedores. Registros locales: " + TRANSFORM(RECCOUNT()), "sync_log.txt")
    GO TOP
    SCAN
        * Análisis validado contra el esquema:
        * cid_vende (PK), cnombrev, ccedula / crif
        lcCod = PADL(ALLTRIM(TRANSFORM(cid_vende)), 5, '0')
        * Escapar comillas simples con STRTRAN
        lcNom = STRTRAN(ALLTRIM(TRANSFORM(cnombrev)), "'", "\'")
        
        lcVenCedula = ALLTRIM(TRANSFORM(crif_ven))
        
        lcSQL = "REPLACE INTO conex_vendedores (CNX_VEN_CODIGO, CNX_VEN_NOMBRE, CNX_VEN_CEDULA) VALUES (" + ;
                "'" + lcCod + "', '" + lcNom + "', '" + lcVenCedula + "')"
                
        lnRet = SQLEXEC(tnConn, lcSQL)
        IF lnRet < 0
            LOCAL ARRAY laErr[1]
            AERROR(laErr)
            EscribirLog("Fallo SQL: " + TRANSFORM(laErr[2]) + " | Comando: " + lcSQL, "error_sync.txt")
        ENDIF
    ENDSCAN
    SQLEXEC(tnConn, "COMMIT")

    IF USED("vendedores")
        USE IN vendedores
    ENDIF
ELSE
    DO EscribirLog WITH "ADVERTENCIA: No se encontro tvendedores.dbf en " + tcDirData, tcErrorFile
ENDIF
ENDPROC

*---------------------------------------------------------
PROCEDURE SyncClientes
LPARAMETERS tnConn, tcDirData, tcErrorFile
LOCAL lcTabla, lcSQL, lnRet, lcCod, lcNom, lcVen

lcTabla = tcDirData + "tclientes.dbf"
IF FILE(lcTabla)
    * Apertura defensiva de tablas
    IF !USED("clientes")
        USE (lcTabla) SHARED IN 0 ALIAS clientes
    ENDIF

    SELECT clientes
    EscribirLog("Iniciando envío de Clientes. Registros locales: " + TRANSFORM(RECCOUNT()), "sync_log.txt")
    GO TOP
    SCAN
        * Análisis validado de tclientes:
        * cid_clien (PK), cnombre_cl, cid_vende (FK Vendedor)
        lcCod = PADL(ALLTRIM(TRANSFORM(cid_clien)), 5, '0')
        lcNom = STRTRAN(ALLTRIM(TRANSFORM(cnombre_cl)), "'", "\'")
        lcVen = PADL(ALLTRIM(TRANSFORM(cid_vende)), 5, '0')
        
        * Usando los nombres remotos oficiales del diccionario de datos (galepso-data-dictionary)
        lcSQL = "REPLACE INTO conex_clientes (CNX_CLT_CODIGO, cnx_clt_galexo, CNX_CLT_NOMBRE, CNX_CLT_VEN_CODIGO) VALUES (" + ;
                "'" + lcCod + "', '" + lcCod + "', '" + lcNom + "', '" + lcVen + "')"
                
        lnRet = SQLEXEC(tnConn, lcSQL)
        IF lnRet < 0
            LOCAL ARRAY laErr[1]
            AERROR(laErr)
            EscribirLog("Fallo SQL: " + TRANSFORM(laErr[2]) + " | Comando: " + lcSQL, "error_sync.txt")
        ENDIF
    ENDSCAN
    SQLEXEC(tnConn, "COMMIT")

    IF USED("clientes")
        USE IN clientes
    ENDIF
ELSE
    DO EscribirLog WITH "ADVERTENCIA: No se encontro tclientes.dbf en " + tcDirData, tcErrorFile
ENDIF
ENDPROC

*---------------------------------------------------------
PROCEDURE EscribirLog
LPARAMETERS tcMensaje, tcArchivo
LOCAL lcMsg
* Adosar log sin sobrescribir (flag 1 en STRTOFILE)
lcMsg = TTOC(DATETIME()) + " - " + TRANSFORM(tcMensaje) + CHR(13) + CHR(10)
STRTOFILE(lcMsg, tcArchivo, 1)
ENDPROC

*---------------------------------------------------------
PROCEDURE ManejadorErrores
LPARAMETERS tnError, tcMessage, tcMessage1, tcProgram, tnLineNo
LOCAL lcErrorMsg
lcErrorMsg = TTOC(DATETIME()) + " - ERROR CRITICO: " + ;
             "Num: " + TRANSFORM(tnError) + " | " + ;
             "Msj: " + TRANSFORM(tcMessage) + " | " + ;
             "Cod: " + TRANSFORM(tcMessage1) + " | " + ;
             "Prog: " + TRANSFORM(tcProgram) + " | " + ;
             "Linea: " + TRANSFORM(tnLineNo)

* Escribir al log de error_sync.txt
STRTOFILE(lcErrorMsg + CHR(13) + CHR(10), "error_sync.txt", 1)

* Asegurar que todo se cierra
CLOSE DATABASES ALL
SQLDISCONNECT(0)

* Salir de la aplicacion
QUIT
ENDPROC
