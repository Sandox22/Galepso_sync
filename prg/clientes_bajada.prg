* clientes_bajada.prg
* Módulo para sincronización bidireccional (Nube -> VFP) de clientes
* Arquitectura Modular - Fase 2

LPARAMETERS tnH
IF TYPE("tnH") <> "N" OR tnH <= 0
    MESSAGEBOX("Se requiere un handle de conexión ODBC válido.", 16, "Error")
    RETURN .F.
ENDIF

LOCAL lcDirData, lnResExt, lcIdsList, lcSqlUpdate
lcIdsList = ""

* Obtener directorio de data
IF TYPE("dirdata") = "U"
    lcDirData = "X:\Galepso\Data\Emp6\"
ELSE
    lcDirData = dirdata
ENDIF

* Apertura de tabla local
IF !USED("tclientes")
    IF FILE(lcDirData + "tclientes.dbf")
        USE (lcDirData + "tclientes.dbf") SHARED IN 0 ALIAS tclientes
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "No se encontro tclientes.dbf en " + lcDirData + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* 1. Extracción (Nube -> VFP)
lnResExt = SQLEXEC(tnH, "SELECT CNX_CLT_CODIGO, CNX_CLT_NOMBRE, CNX_CLT_RIF, CNX_CLT_EDO_CODIGO FROM conex_clientes WHERE CNX_CLT_CHECK = 0 AND (CNX_CLT_GALEXO = '' OR CNX_CLT_GALEXO IS NULL)", "cur_clientes_bajada")

IF lnResExt < 0
    LOCAL ARRAY laErr[1]
    AERROR(laErr)
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "Error leyendo clientes de la nube: " + laErr[2] + CHR(13)
    ENDIF
    RETURN .F.
ENDIF

* 2. Procesamiento Local (VFP)
SELECT cur_clientes_bajada
IF EOF()
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "No hay clientes nuevos en la nube para descargar." + CHR(13)
    ENDIF
    USE IN cur_clientes_bajada
    RETURN 0
ENDIF

BEGIN TRANSACTION

SELECT cur_clientes_bajada
SCAN
    LOCAL lcCod, lcNom, lcRif, lcEdo
    lcCod = ALLTRIM(cur_clientes_bajada.CNX_CLT_CODIGO)
    lcNom = cur_clientes_bajada.CNX_CLT_NOMBRE
    lcRif = cur_clientes_bajada.CNX_CLT_RIF
    lcEdo = cur_clientes_bajada.CNX_CLT_EDO_CODIGO
    
    SELECT tclientes
    LOCATE FOR ALLTRIM(cid_clien) == lcCod
    
    IF FOUND()
        * Actualizar
        REPLACE cnombre_cl WITH PADR(lcNom, LEN(cnombre_cl)), ;
                crif_cli WITH PADR(lcRif, LEN(crif_cli)), ;
                cid_estadc WITH PADR(lcEdo, LEN(cid_estadc))
    ELSE
        * Insertar
        APPEND BLANK
        REPLACE cid_clien WITH PADR(lcCod, LEN(cid_clien)), ;
                cnombre_cl WITH PADR(lcNom, LEN(cnombre_cl)), ;
                crif_cli WITH PADR(lcRif, LEN(crif_cli)), ;
                cid_estadc WITH PADR(lcEdo, LEN(cid_estadc))
    ENDIF
    
    * Acumular IDs para Acknowledge
    lcIdsList = lcIdsList + "'" + lcCod + "',"
ENDSCAN

END TRANSACTION

* 3. Confirmación / Acknowledge (VFP -> Nube)
IF LEN(lcIdsList) > 0
    * Quitar la última coma
    lcIdsList = SUBSTR(lcIdsList, 1, LEN(lcIdsList) - 1)
    
    lcSqlUpdate = "UPDATE conex_clientes SET CNX_CLT_CHECK = 1 WHERE CNX_CLT_CODIGO IN (" + lcIdsList + ")"
    
    LOCAL lnResAck
    lnResAck = SQLEXEC(tnH, lcSqlUpdate)
    
    IF lnResAck > 0
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "Clientes descargados y confirmados con exito. " + TTOC(DATETIME()) + CHR(13)
        ENDIF
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "Warning: Clientes descargados pero falló el Acknowledge en MariaDB." + CHR(13)
        ENDIF
    ENDIF
ENDIF

IF USED("cur_clientes_bajada")
    USE IN cur_clientes_bajada
ENDIF

RETURN .T.
