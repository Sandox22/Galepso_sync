*------------------------------------------------------------------------------
* sincronizar_api.prg
*   Ejecuta todos los procesos de sincronizacion via API REST
*   Alternativa a los botones del formulario frmrespaldos
*
*   USO: DO sincronizar_api
*------------------------------------------------------------------------------

CLOSE DATABASES ALL
SET SAFETY OFF
SET EXCLUSIVE OFF
SET DELETED ON
SET DATE TO british

LOCAL lcPrgPath, lcDataPath
lcPrgPath = JUSTPATH(SYS(16))
lcDataPath = ADDBS(JUSTPATH(lcPrgPath)) + "DATA"
SET PATH TO (lcDataPath), (lcPrgPath)
SET PROCEDURE TO (lcPrgPath + "\api_helper.prg")

PCESTADOENVIA = ""

*--- Ejecutar cada sync en orden ---
WAIT WINDOW "Sincronizando pedidos via API..." NOWAIT
DO pedidos_api
WAIT CLEAR

WAIT WINDOW "Sincronizando visitas via API..." NOWAIT
DO visitas_api
WAIT CLEAR

WAIT WINDOW "Sincronizando devoluciones via API..." NOWAIT
DO devoluciones_api
WAIT CLEAR

WAIT WINDOW "Sincronizando recibos via API..." NOWAIT
DO recibos_api
WAIT CLEAR

WAIT WINDOW "Sincronizando inventario via API..." NOWAIT
DO inventario_api
WAIT CLEAR

WAIT WINDOW "Sincronizando CXC via API..." NOWAIT
DO cxc_api
WAIT CLEAR

MESSAGEBOX("Sincronizacion API completada" + CHR(13) + PCESTADOENVIA, 64, "API Sync")
