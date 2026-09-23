* clientes.prg
* Sincronización bidireccional: tclientes <-> conex_clientes

LPARAMETERS tnH
IF TYPE("tnH") <> "N" OR tnH <= 0
    MESSAGEBOX("Se requiere un handle de conexión ODBC válido para sincronizar clientes.", 16, "Error")
    RETURN .F.
ENDIF

LOCAL lcDirData
IF TYPE("dirdata") = "U"
    lcDirData = "X:\Galepso\Data\Emp6\"
ELSE
    lcDirData = dirdata
ENDIF

* Apertura defensiva de la tabla
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

* Apertura defensiva de tcontroles (correlativos)
IF !USED("tcontroles")
    IF FILE(lcDirData + "tcontroles.dbf")
        USE (lcDirData + "tcontroles.dbf") SHARED IN 0 ALIAS tcontroles
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "No se encontro tcontroles.dbf en " + lcDirData + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Habilitar Buffering Optimista de Tabla
CURSORSETPROP("Buffering", 5, "tclientes")

* ==============================================================================
* 1. BAJADA: MariaDB (conex_clientes) -> VFP Local (tclientes)
* ==============================================================================

* Leer correlativo desde tcontroles (fuente de verdad del ERP)
* NCLIENTE guarda el PROXIMO codigo disponible
LOCAL lnMaxCid, lcNewCid, lnOrigNCliente
SELECT tcontroles
GO TOP
lnOrigNCliente = tcontroles.NCLIENTE
lnMaxCid = lnOrigNCliente - 1

* Obtener registros pendientes de la nube
LOCAL lnResBajada
lnResBajada = SQLEXEC(tnH, ;
    "SELECT cnx_clt_codigo, cnx_clt_nombre, cnx_clt_rif, cnx_clt_edo_codigo, cnx_clt_mpo_codigo, cnx_clt_direccion1, cnx_clt_telefono1 " + ;
    "FROM conex_clientes " + ;
    "WHERE cnx_clt_check = 0 AND (cnx_clt_galexo IS NULL OR TRIM(cnx_clt_galexo) = '')", ;
    "curNubeBajada")

IF lnResBajada > 0
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + " / Clientes de nube a bajar: " + TRANSFORM(RECCOUNT("curNubeBajada"))
    ENDIF
ENDIF

IF lnResBajada > 0 AND RECCOUNT("curNubeBajada") > 0
    SELECT curNubeBajada
    SCAN
        * Generar nuevo código local secuencial (autoincremental nativo del DBF local)
        lnMaxCid = lnMaxCid + 1
        lcNewCid = STR(lnMaxCid, 5)

        * Mapeo explícito: El identificador único de la nube se guarda obligatoriamente en el campo NIT local
        LOCAL lcNubeCodigo
        lcNubeCodigo = ALLTRIM(curNubeBajada.cnx_clt_codigo)

        * Insertar en tabla local
        INSERT INTO tclientes (cid_clien, cnombre_cl, crif_cli, cid_estadc, cid_ciudac, cdir_cli1, ctele_cli, cnit_cli) ;
            VALUES (lcNewCid, ;
                    curNubeBajada.cnx_clt_nombre, ;
                    curNubeBajada.cnx_clt_rif, ;
                    STR(curNubeBajada.cnx_clt_edo_codigo, 2), ;
                    STR(curNubeBajada.cnx_clt_mpo_codigo, 2), ;
                    curNubeBajada.cnx_clt_direccion1, ;
                    curNubeBajada.cnx_clt_telefono1, ;
                    lcNubeCodigo)

        * Marcar en la nube como sincronizado devolviendo el nuevo ID local (galexo)
        LOCAL lnResUpdateNube
        lnResUpdateNube = SQLEXEC(tnH, "UPDATE conex_clientes SET cnx_clt_galexo = ?lcNewCid, cnx_clt_check = 1 WHERE cnx_clt_codigo = ?curNubeBajada.cnx_clt_codigo")
    ENDSCAN
ENDIF

IF USED("curNubeBajada")
    USE IN curNubeBajada
ENDIF

* Guardar cambios de la Bajada
TABLEUPDATE(.T., .T., "tclientes")

* Actualizar correlativo en tcontroles con bloqueo de concurrencia
* Solo si se insertaron clientes nuevos (lnMaxCid habrá avanzado)
IF lnMaxCid >= lnOrigNCliente
    SELECT tcontroles
    GO TOP
    LOCAL llLocked
    llLocked = RLOCK()
    IF llLocked
        REPLACE NCLIENTE WITH (lnMaxCid + 1)
        UNLOCK
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + " / tcontroles.NCLIENTE actualizado a: " + TRANSFORM(lnMaxCid + 1) + CHR(13)
        ENDIF
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "[Clientes] WARNING: No se pudo bloquear tcontroles para actualizar NCLIENTE" + CHR(13)
        ENDIF
    ENDIF
ENDIF

* ==============================================================================
* 1.5 RESCATE DE CÓDIGOS ADN: Actualizar cnit_cli cuando ADN modifica cnx_clt_codigo
* ==============================================================================
* Regla de negocio: Cuando Galepso sube un cliente, ADN puede modificar
* cnx_clt_codigo asignándole su propio ID interno. Galepso debe descargar
* ese código definitivo y actualizar su campo local cnit_cli.

LOCAL lnResRescate, lnRescatados
lnRescatados = 0

lnResRescate = SQLEXEC(tnH, ;
    "SELECT cnx_clt_codigo, cnx_clt_galexo " + ;
    "FROM conex_clientes " + ;
    "WHERE cnx_clt_galexo IS NOT NULL AND TRIM(cnx_clt_galexo) <> ''", ;
    "curRescateCodigos")

IF lnResRescate < 0
    LOCAL ARRAY laErrRescate[1]
    AERROR(laErrRescate)
    IF TYPE("PCESTADORECIBE") = "C"
        PCESTADORECIBE = PCESTADORECIBE + "[Clientes-Rescate] ERROR SQL: " + ;
            ALLTRIM(TRANSFORM(laErrRescate[2])) + " " + TTOC(DATETIME()) + CHR(13)
    ENDIF
ENDIF

IF lnResRescate > 0 AND RECCOUNT("curRescateCodigos") > 0
    SELECT curRescateCodigos
    SCAN
        LOCAL lcCodigoADN, lcGalexo
        lcCodigoADN = ALLTRIM(curRescateCodigos.cnx_clt_codigo)
        lcGalexo    = ALLTRIM(curRescateCodigos.cnx_clt_galexo)

        * Buscar el cliente local por su cid_clien que coincida con cnx_clt_galexo
        SELECT tclientes
        LOCATE FOR ALLTRIM(cid_clien) == lcGalexo

        IF FOUND()
            * Solo actualizar si el código ADN difiere del cnit_cli actual
            IF ALLTRIM(tclientes.cnit_cli) <> lcCodigoADN
                REPLACE cnit_cli WITH lcCodigoADN IN tclientes
                lnRescatados = lnRescatados + 1
            ENDIF
        ENDIF
    ENDSCAN
ENDIF

IF USED("curRescateCodigos")
    USE IN curRescateCodigos
ENDIF

* Guardar cambios del Rescate de Códigos
IF lnRescatados > 0
    TABLEUPDATE(.T., .T., "tclientes")
ENDIF

IF TYPE("PCESTADORECIBE") = "C"
    PCESTADORECIBE = PCESTADORECIBE + "[Clientes-Rescate] Códigos ADN actualizados: " + ;
        TRANSFORM(lnRescatados) + " " + TTOC(DATETIME()) + CHR(13)
ENDIF

IF TYPE("contarecibe") = "N"
    contarecibe = contarecibe + lnRescatados
ENDIF

* ==============================================================================
* 2. SUBIDA: VFP Local (tclientes) -> MariaDB (conex_clientes)
* ==============================================================================
SELECT VAL(cid_clien) AS cnx_clt_galexo, ;
       cnombre_cl AS cnx_clt_nombre, ;
       crif_cli AS cnx_clt_rif, ;
       cid_estadc AS cnx_clt_edo_codigo, ;
       cid_clien ;
FROM tclientes ;
WHERE EMPTY(cnit_cli) ;
INTO CURSOR curSubidaLocal

IF TYPE("PCESTADOENVIA") = "C"
    PCESTADOENVIA = PCESTADOENVIA + " / Clientes locales a subir: " + TRANSFORM(RECCOUNT("curSubidaLocal"))
ENDIF

IF RECCOUNT("curSubidaLocal") > 0
    SELECT curSubidaLocal
    SCAN
        LOCAL lnGalexo, lcNombre, lcRif, lnEdoCodigo, lcCidClien
        lnGalexo    = curSubidaLocal.cnx_clt_galexo
        
        * Sanitización estricta del código: limpieza rigurosa usando ALLTRIM y STRTRAN 
        * para garantizar que viaje libre de espacios o caracteres extraños
        lcCidClien  = ALLTRIM(STRTRAN(curSubidaLocal.cid_clien, " ", ""))
        
        lcNombre    = CHRTRAN(ALLTRIM(curSubidaLocal.cnx_clt_nombre), "'", "")
        lcRif       = ALLTRIM(curSubidaLocal.cnx_clt_rif)
        lnEdoCodigo = VAL(curSubidaLocal.cnx_clt_edo_codigo)
        
        LOCAL lcSqlInsert, lnResInsert
        * Upsert Blindado: Actualiza si ya existe sin generar duplicados ni alterar su identidad
        lcSqlInsert = "INSERT INTO conex_clientes (cnx_clt_codigo, cnx_clt_galexo, cnx_clt_nombre, cnx_clt_rif, cnx_clt_edo_codigo) " + ;
                      "VALUES (?lcCidClien, ?lcCidClien, ?lcNombre, ?lcRif, ?lnEdoCodigo) " + ;
                      "ON DUPLICATE KEY UPDATE " + ;
                      "cnx_clt_galexo = VALUES(cnx_clt_galexo), " + ;
                      "cnx_clt_nombre = VALUES(cnx_clt_nombre), " + ;
                      "cnx_clt_rif = VALUES(cnx_clt_rif), " + ;
                      "cnx_clt_edo_codigo = VALUES(cnx_clt_edo_codigo)"
        
        lnResInsert = SQLEXEC(tnH, lcSqlInsert, 'curResult')
        
        IF lnResInsert < 0
            LOCAL ARRAY laError[1]
            AERROR(laError)
            IF TYPE("PCESTADOENVIA") = "C"
                PCESTADOENVIA = PCESTADOENVIA + " | ERROR SQL NUBE: " + TRANSFORM(laError[2])
            ENDIF
        ENDIF
        
        IF lnResInsert > 0
            * Marca el registro local como ya subido
            UPDATE tclientes SET cnit_cli = curSubidaLocal.cid_clien WHERE cid_clien = curSubidaLocal.cid_clien
        ENDIF
    ENDSCAN
ENDIF

IF USED("curSubidaLocal")
    USE IN curSubidaLocal
ENDIF

* Guardar cambios de la Subida
TABLEUPDATE(.T., .T., "tclientes")

* Control de Estado de Envío
IF TYPE("PCESTADOENVIA") = "C"
    PCESTADOENVIA = PCESTADOENVIA + "Sincronización de Clientes (Subida/Bajada) completada con éxito " + TTOC(DATETIME()) + CHR(13)
ENDIF

RETURN .T.
