* sincronizar_todo.prg
* Orquestador Maestro - Arquitectura Modular - Fase 1

* Configuración global

* Saneamiento preventivo de transacciones huérfanas
DO WHILE TXNLEVEL() > 0
    ROLLBACK
ENDDO

SET SAFETY OFF
SET EXCLUSIVE OFF
SET EXACT ON
SET DELETED ON
SET MULTILOCKS ON
CLOSE DATABASES ALL

PUBLIC dirdata, PCESTADOENVIA, contaenviar
dirdata = "X:\Galepso\Data\Emp6\"
PCESTADOENVIA = ""
contaenviar = 0

* Asegurar que el helper esté cargado (ruta dinámica vía SYS(16))
SET PROCEDURE TO (ADDBS(JUSTPATH(SYS(16))) + "sync_upsert.prg") ADDITIVE

* Conexión ODBC
LOCAL lcStringConexion, lnhandle
lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=159.195.66.171;Port=3459;Database=bdsistemas2;Uid=galexo_kw;Pwd=PGXz&161WW0d;"
SQLSETPROP(0, "DispLogin", 3)
lnhandle = SQLSTRINGCONNECT(lcStringConexion)

IF lnhandle <= 0
    LOCAL ARRAY laError[1]
    AERROR(laError)
    MESSAGEBOX("El servidor rechazó la conexión. Motivo: " + CHR(13) + laError[2], 16, "Fallo ODBC")
    RETURN .F.
ENDIF

* Ejecución de módulos respetando el flujo bidireccional
DO clientes.prg WITH lnhandle
DO vendedores.prg WITH lnhandle
DO pedidos.prg WITH lnhandle
DO estados.prg WITH lnhandle
DO municipios.prg WITH lnhandle
DO productos.prg WITH lnhandle
DO precios.prg WITH lnhandle

* Cierre de la conexión
SQLDISCONNECT(lnhandle)
CLOSE DATABASES ALL

* Reportar resultado global
MESSAGEBOX("Sincronización Finalizada." + CHR(13) + CHR(13) + "Log de Operaciones:" + CHR(13) + PCESTADOENVIA, 64, "Proceso Completado")
