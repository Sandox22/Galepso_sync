* vendedores.prg
* Sincronizacion de Vendedores hacia conex_vendedores
* Patrón A: SyncUpsert

LPARAMETERS tnH

IF TYPE("tnH") <> "N" OR tnH <= 0
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "[Vendedores] ERROR: Handle ODBC inválido." + CHR(13)
    ENDIF
    RETURN .F.
ENDIF

LOCAL lcDirData
IF TYPE("dirdata") = "C" AND !EMPTY(dirdata)
    lcDirData = dirdata
ELSE
    IF TYPE("PCUNIDAD") = "C" AND TYPE("pcSistema") = "C" AND TYPE("pcEmpresa") = "C"
        lcDirData = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
    ELSE
        lcDirData = "X:\Galepso\Data\Emp6\"
    ENDIF
ENDIF

* Apertura defensiva de tvendedores
IF !USED("tvendedores")
    IF FILE(lcDirData + "tvendedores.dbf")
        USE (lcDirData + "tvendedores.dbf") SHARED IN 0 ALIAS tvendedores
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "[Vendedores] No se encontro tvendedores.dbf en " + lcDirData + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* CAUSA RAÍZ DEL FALLO SILENCIOSO ORIGINAL: 
* Posible problema de variables fuera de alcance o el módulo nunca se estaba invocando 
* desde el orquestador principal. Además, se estaba utilizando un anti-patrón (ciclo manual).
* SOLUCIÓN:
* 1. Usamos el campo real crif_ven (verificado).
* 2. Aplicamos el Patrón A de SyncUpsert como manda la arquitectura.

SELECT PADL(ALLTRIM(NVL(cid_vende, "")), 5, '0') AS cid_vende, ;
       NVL(cnombrev, "") AS cnombrev, ;
       NVL(crif_ven, "") AS crif_ven ;
FROM tvendedores INTO CURSOR cur_vendedores_sync

* --- INYECCIÓN DE TELEMETRÍA: RADAR DE LECTURA ---
LOCAL lnCountRadar
SELECT cur_vendedores_sync
COUNT TO lnCountRadar
IF TYPE("PCESTADOENVIA") = "C"
    PCESTADOENVIA = PCESTADOENVIA + "[Vendedores] RADAR LECTURA: " + TRANSFORM(lnCountRadar) + " registros extraídos de tvendedores a cursor." + CHR(13)
ENDIF
GO TOP
* -------------------------------------------------

* Mapa de sincronización para Patrón A
LOCAL lcMap, lnRet
lcMap = "cid_vende|CNX_VEN_CODIGO|C, " + ;
        "cnombrev|CNX_VEN_NOMBRE|C, " + ;
        "crif_ven|CNX_VEN_CEDULA|C"

lnRet = SyncUpsert(tnH, "cur_vendedores_sync", "conex_vendedores", lcMap)

IF lnRet < 0
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "[Vendedores] Finalizado con errores en SyncUpsert. Revise LOG." + CHR(13)
    ENDIF
ELSE
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "Sincronizacion de Vendedores completada. (" + TRANSFORM(lnRet) + " regs)" + CHR(13)
    ENDIF
ENDIF

IF USED("cur_vendedores_sync")
    USE IN cur_vendedores_sync
ENDIF

RETURN .T.
