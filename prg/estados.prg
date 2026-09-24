* estados.prg
* Módulo independiente para sincronización de la tabla testados a conex_estados
* Arquitectura Modular - Fase 1

LPARAMETERS tnH
IF TYPE("tnH") <> "N" OR tnH <= 0
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "[Estados] ERROR: Handle ODBC invalido." + CHR(13)
    ENDIF
    RETURN .F.
ENDIF

LOCAL tcMapEdo, lnResEdo, lcDirData

* Obtener directorio de data
IF TYPE("dirdata") = "U"
    lcDirData = "X:\Galepso\Data\Emp6\"
ELSE
    lcDirData = dirdata
ENDIF

* Apertura defensiva de la tabla
IF !USED("testados")
    IF FILE(lcDirData + "testados.dbf")
        USE (lcDirData + "testados.dbf") SHARED IN 0 ALIAS testados
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "No se encontro testados.dbf en " + lcDirData + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Construcción del cursor temporal
SELECT CID_ESTADO AS edo_codigo, ;
       ALLTRIM(CDESCRIPCI) AS edo_descri, ;
       1 AS edo_activo ;
FROM testados ;
INTO CURSOR cur_estados_sync READWRITE

tcMapEdo = "edo_codigo|CNX_EDOCODIGO|N,edo_descri|CNX_EDODESCRI|C,edo_activo|CNX_EDOACTIVO|N"

lnResEdo = SyncUpsert(tnH, "cur_estados_sync", "conex_estados", tcMapEdo)

* Cierre exclusivo del cursor temporal
IF USED("cur_estados_sync")
    USE IN cur_estados_sync
ENDIF

* Control de errores y reporte global
IF TYPE("PCESTADOENVIA") = "C"
    IF lnResEdo > 0
        IF TYPE("contaenviar") = "N"
            contaenviar = contaenviar + lnResEdo
        ENDIF
        PCESTADOENVIA = PCESTADOENVIA + "Estados Insertados con exito " + TTOC(DATETIME()) + CHR(13)
    ELSE
        IF lnResEdo < 0
            LOCAL ARRAY laErrEdo[1]
            AERROR(laErrEdo)
            LOCAL lcErrMsgEdo
            lcErrMsgEdo = IIF(TYPE("laErrEdo[2]") = "C", laErrEdo[2], "Error SQL Desconocido o código: " + TRANSFORM(lnResEdo))
            PCESTADOENVIA = PCESTADOENVIA + CHR(13) + "ERROR ESTADOS: " + lcErrMsgEdo + CHR(13)
        ELSE
            PCESTADOENVIA = PCESTADOENVIA + "No se encontraron registros para Estados " + TTOC(DATETIME()) + CHR(13)
        ENDIF
    ENDIF
ENDIF

RETURN lnResEdo
