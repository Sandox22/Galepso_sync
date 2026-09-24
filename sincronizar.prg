* sincronizar.prg
* Orquestador Maestro de Sincronizacion VFP -> MariaDB
* Arquitectura Modular - Fase 2 (Headless)

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
SET DELETED ON
SET EXACT ON
SET MULTILOCKS ON

ON ERROR DO ManejadorErrores WITH ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO()
* -------------------------------------------------

* Variables Globales Oficiales (Requeridas por los modulos)
PUBLIC dirdata, PCESTADOENVIA, contarecibe, contaenviar, PCESTADORECIBE
dirdata = "X:\Galepso\Data\Emp6\"
PCESTADOENVIA = ""
PCESTADORECIBE = ""
contaenviar = 0
contarecibe = 0

* Limpieza de transacciones huerfanas
DO WHILE TXNLEVEL() > 0
    ROLLBACK
ENDDO

LOCAL lcJsonPath, lcJsonStr, loScript
LOCAL lcServer, lcPort, lcUser, lcPass, lcDB
LOCAL llSyncVend, llSyncCli, llSyncPed, llSyncCat, llSyncCxC
LOCAL lcConnStr, lnConn
LOCAL lcLogFile, lcErrorFile

lcLogFile = "sync_log.txt"
lcErrorFile = "error_sync.txt"

DO EscribirLog WITH "Iniciando Orquestador Maestro", lcLogFile

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
    loScript.ExecuteStatement("var config = (" + lcJsonStr + ");")
    
    * Credenciales
    lcServer   = loScript.Eval("config.database.server")
    lcPort     = loScript.Eval("config.database.port")
    lcUser     = loScript.Eval("config.database.user")
    lcPass     = loScript.Eval("config.database.password")
    lcDB       = loScript.Eval("config.database.database")
    
    * Banderas
    LOCAL lcStr
    
    lcStr = UPPER(ALLTRIM(TRANSFORM(loScript.Eval("config.modules.vendedores"))))
    llSyncVend = INLIST(lcStr, ".T.", "TRUE", "1")

    lcStr = UPPER(ALLTRIM(TRANSFORM(loScript.Eval("config.modules.clientes"))))
    llSyncCli = INLIST(lcStr, ".T.", "TRUE", "1")
    
    * Catálogos (usando productos en config.json)
    lcStr = UPPER(ALLTRIM(TRANSFORM(loScript.Eval("config.modules.productos"))))
    llSyncCat = INLIST(lcStr, ".T.", "TRUE", "1")

    lcStr = UPPER(ALLTRIM(TRANSFORM(loScript.Eval("config.modules.pedidos"))))
    llSyncPed = INLIST(lcStr, ".T.", "TRUE", "1")
    
    lcStr = UPPER(ALLTRIM(TRANSFORM(loScript.Eval("config.modules.cxc"))))
    llSyncCxC = INLIST(lcStr, ".T.", "TRUE", "1")

CATCH TO loErr
    LOCAL lcDetalleError
    lcDetalleError = "Error de parseo JSON. Detalle: " + TRANSFORM(loErr.Message) + " / " + TRANSFORM(loErr.Description)
    STRTOFILE(lcDetalleError + CHR(13)+CHR(10), lcErrorFile, 1)
    llErrorParseo = .T.
ENDTRY

IF llErrorParseo
    QUIT
ENDIF

* 2. CONEXIÓN ODBC
SQLSETPROP(0, "DispLogin", 3)
lcConnStr = "DRIVER={MySQL ODBC 3.51 Driver};SERVER=" + TRANSFORM(lcServer) + ;
            ";PORT=" + TRANSFORM(lcPort) + ";DATABASE=" + TRANSFORM(lcDB) + ;
            ";UID=" + TRANSFORM(lcUser) + ";PWD=" + TRANSFORM(lcPass) + ";OPTION=3;"

lnConn = SQLSTRINGCONNECT(lcConnStr)

IF lnConn <= 0
    LOCAL ARRAY laErr[1]
    AERROR(laErr)
    DO EscribirLog WITH "ERROR Conexion ODBC: " + TRANSFORM(laErr[2]), lcErrorFile
    QUIT
ENDIF

DO EscribirLog WITH "Conexion ODBC Exitosa.", lcLogFile

* Asegurar que el helper de SyncUpsert este cargado para los catalogos
SET PROCEDURE TO prg\sync_upsert.prg ADDITIVE

* 3. FLUJO DE ORQUESTACIÓN Y RUTEO MODULAR
* Orden estricto para garantizar dependencias FK

* 3.1 Vendedores
IF llSyncVend
    DO EscribirLog WITH "Iniciando subida de Vendedores...", lcLogFile
    DO prg\vendedores.prg WITH lnConn
ENDIF

* 3.2 Clientes
IF llSyncCli
    DO EscribirLog WITH "Iniciando sincronizacion bidireccional de Clientes...", lcLogFile
    DO prg\clientes.prg WITH lnConn
ENDIF

* 3.3 Catálogos (Subida via SyncUpsert)
IF llSyncCat
    DO EscribirLog WITH "Iniciando subida de Catalogos (Productos, Precios, Estados, Municipios)...", lcLogFile
    DO prg\estados.prg WITH lnConn
    DO prg\municipios.prg WITH lnConn
    DO prg\productos.prg WITH lnConn
    DO prg\precios.prg WITH lnConn
ENDIF

* 3.4 Pedidos (Bajada transaccional)
IF llSyncPed
    DO EscribirLog WITH "Iniciando bajada transaccional de Pedidos...", lcLogFile
    DO prg\pedidos.prg WITH lnConn
ENDIF

* 3.5 CxC (Subida de llave compuesta y JSON)
IF llSyncCxC
    DO EscribirLog WITH "Iniciando subida transaccional de Cuentas por Cobrar (CxC)...", lcLogFile
    DO prg\cxc_sincro_subida.prg WITH lnConn
ENDIF

* 4. CIERRE SEGURO
SQLDISCONNECT(lnConn)

LOCAL lcResumenFinal
lcResumenFinal = "Ejecucion Finalizada." + CHR(13) + CHR(10) + ;
                 "LOG ENVIO:" + CHR(13) + CHR(10) + PCESTADOENVIA + CHR(13) + CHR(10) + ;
                 "LOG RECIBO:" + CHR(13) + CHR(10) + PCESTADORECIBE
                 
DO EscribirLog WITH lcResumenFinal, lcLogFile

QUIT

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
