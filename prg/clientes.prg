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
    "WHERE cnx_clt_galexo IS NULL OR TRIM(cnx_clt_galexo) = ''", ;
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
                    NVL(curNubeBajada.cnx_clt_nombre, ""), ;
                    NVL(curNubeBajada.cnx_clt_rif, ""), ;
                    STR(NVL(curNubeBajada.cnx_clt_edo_codigo, 1), 2), ;
                    STR(NVL(curNubeBajada.cnx_clt_mpo_codigo, 1), 2), ;
                    NVL(curNubeBajada.cnx_clt_direccion1, ""), ;
                    NVL(curNubeBajada.cnx_clt_telefono1, ""), ;
                    lcNubeCodigo)

        * Marcar en la nube como sincronizado devolviendo el nuevo ID local (galexo)
        * Forzar CNX_CLT_MODIFICADO = 0 para evitar que el trigger de BD active el Radar en el próximo ciclo
        LOCAL lnResUpdateNube
        lnResUpdateNube = SQLEXEC(tnH, "UPDATE conex_clientes SET cnx_clt_galexo = ?lcNewCid, cnx_clt_check = 1, CNX_CLT_MODIFICADO = 0 WHERE cnx_clt_codigo = ?curNubeBajada.cnx_clt_codigo")
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
* 1.2 RADAR DE EDICIONES: Actualizar clientes modificados en la nube
* ==============================================================================
LOCAL lnResRadar, lnEditados, lcLogRadar
lnEditados = 0
lcLogRadar = lcDirData + "sync_radar_audit.txt"

STRTOFILE("===========================================" + CHR(13)+CHR(10), lcLogRadar, 1)
STRTOFILE(TTOC(DATETIME()) + " - [RADAR] Iniciando extracción de clientes editados..." + CHR(13)+CHR(10), lcLogRadar, 1)

lnResRadar = SQLEXEC(tnH, ;
    "SELECT cnx_clt_codigo, cnx_clt_galexo, cnx_clt_nombre, cnx_clt_direccion1, cnx_clt_rif, cnx_clt_telefono1 " + ;
    "FROM conex_clientes " + ;
    "WHERE CNX_CLT_MODIFICADO = 1 AND cnx_clt_galexo IS NOT NULL AND TRIM(cnx_clt_galexo) != ''", ;
    "curRadarEdiciones")

IF lnResRadar < 0
    LOCAL ARRAY laErrRadar[1]
    AERROR(laErrRadar)
    STRTOFILE("  -> [ERROR SQL] Extracción fallida: " + ALLTRIM(TRANSFORM(laErrRadar[2])) + CHR(13)+CHR(10), lcLogRadar, 1)
    
    IF TYPE("PCESTADORECIBE") = "C"
        PCESTADORECIBE = PCESTADORECIBE + "[Clientes-Radar] ERROR SQL: " + ;
            ALLTRIM(TRANSFORM(laErrRadar[2])) + " " + TTOC(DATETIME()) + CHR(13)
    ENDIF
ELSE
    STRTOFILE("  -> [OK] Consulta exitosa. Registros extraídos: " + TRANSFORM(RECCOUNT("curRadarEdiciones")) + CHR(13)+CHR(10), lcLogRadar, 1)
ENDIF

IF lnResRadar > 0 AND RECCOUNT("curRadarEdiciones") > 0
    SELECT curRadarEdiciones
    SCAN
        LOCAL lcGalexo, lcCodigoNube, lcNombre, lcDir, lcRif, lcTel
        lcCodigoNube = ALLTRIM(curRadarEdiciones.cnx_clt_codigo)
        lcGalexo     = ALLTRIM(STRTRAN(curRadarEdiciones.cnx_clt_galexo, " ", "")) && Limpieza agresiva del Galexo
        
        * Sanitización de NULLs (evita crash "Field does not accept null values" en REPLACE)
        lcNombre     = NVL(curRadarEdiciones.cnx_clt_nombre, "")
        lcDir        = NVL(curRadarEdiciones.cnx_clt_direccion1, "")
        lcRif        = NVL(curRadarEdiciones.cnx_clt_rif, "")
        lcTel        = NVL(curRadarEdiciones.cnx_clt_telefono1, "")

        STRTOFILE("    > Procesando Nube ID: [" + lcCodigoNube + "] - Buscando Galexo ID local: [" + lcGalexo + "]" + CHR(13)+CHR(10), lcLogRadar, 1)

        * Buscar el cliente local por su cid_clien
        * Uso STRTRAN también local por si acaso había espacios intermedios
        SELECT tclientes
        LOCATE FOR ALLTRIM(STRTRAN(cid_clien, " ", "")) == lcGalexo

        IF FOUND()
            STRTOFILE("      -> [MATCH ENCONTRADO] Registro cid_clien coincide. Procediendo a REPLACE..." + CHR(13)+CHR(10), lcLogRadar, 1)
            
            * Actualizar datos comerciales
            REPLACE cnombre_cl WITH lcNombre, ;
                    cdir_cli1 WITH lcDir, ;
                    crif_cli WITH lcRif, ;
                    ctele_cli WITH lcTel IN tclientes
            
            * Acuse de recibo en la nube (Reset flag)
            LOCAL lnResReset
            lnResReset = SQLEXEC(tnH, "UPDATE conex_clientes SET CNX_CLT_MODIFICADO = 0 WHERE cnx_clt_codigo = ?lcCodigoNube")
            
            IF lnResReset > 0
                lnEditados = lnEditados + 1
                STRTOFILE("      -> [OK NUBE] Flag CNX_CLT_MODIFICADO = 0 reseteado." + CHR(13)+CHR(10), lcLogRadar, 1)
            ELSE
                LOCAL ARRAY laErrReset[1]
                AERROR(laErrReset)
                STRTOFILE("      -> [ERROR NUBE] Fallo reset del flag: " + ALLTRIM(TRANSFORM(laErrReset[2])) + CHR(13)+CHR(10), lcLogRadar, 1)
                
                IF TYPE("PCESTADORECIBE") = "C"
                    PCESTADORECIBE = PCESTADORECIBE + "[Clientes-Radar] ERROR Reset Nube: " + ;
                        ALLTRIM(TRANSFORM(laErrReset[2])) + CHR(13)
                ENDIF
            ENDIF
        ELSE
            STRTOFILE("      -> [NO ENCONTRADO] El LOCATE falló. El código galexo de la nube no coincide con ningún cid_clien local." + CHR(13)+CHR(10), lcLogRadar, 1)
        ENDIF
    ENDSCAN
ENDIF

IF USED("curRadarEdiciones")
    USE IN curRadarEdiciones
ENDIF

* Guardar cambios del Radar de Ediciones
IF lnEditados > 0
    LOCAL llUpdateExito
    llUpdateExito = TABLEUPDATE(.T., .T., "tclientes")
    
    IF llUpdateExito
        STRTOFILE("  -> [OK LOCAL] TABLEUPDATE(tclientes) exitoso. Cambios confirmados." + CHR(13)+CHR(10), lcLogRadar, 1)
    ELSE
        LOCAL ARRAY laErrUpdate[1]
        AERROR(laErrUpdate)
        STRTOFILE("  -> [ERROR LOCAL] TABLEUPDATE fallido: " + ALLTRIM(TRANSFORM(laErrUpdate[2])) + CHR(13)+CHR(10), lcLogRadar, 1)
    ENDIF
ENDIF

IF TYPE("PCESTADORECIBE") = "C"
    PCESTADORECIBE = PCESTADORECIBE + "[Clientes-Radar] Clientes editados descargados: " + ;
        TRANSFORM(lnEditados) + " " + TTOC(DATETIME()) + CHR(13)
ENDIF

IF TYPE("contarecibe") = "N"
    contarecibe = contarecibe + lnEditados
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
* Obtener snapshot de la nube para evitar N+1 queries y actualizaciones redundantes
LOCAL lnResSnapshot
lnResSnapshot = SQLEXEC(tnH, ;
    "SELECT cnx_clt_codigo, cnx_clt_galexo, cnx_clt_nombre, cnx_clt_rif, cnx_clt_edo_codigo, cnx_clt_mpo_codigo, cnx_clt_direccion1, cnx_clt_telefono1, cnx_clt_ven_codigo FROM conex_clientes", ;
    "curCloudSnapshot")

IF lnResSnapshot < 0
    LOCAL ARRAY laErrSnap[1]
    AERROR(laErrSnap)
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + " | ERROR SQL NUBE (Snapshot): " + TRANSFORM(laErrSnap[2])
    ENDIF
    RETURN .F.
ENDIF

* Indexar snapshot para búsquedas rápidas (por Galexo y por Codigo)
SELECT curCloudSnapshot
INDEX ON ALLTRIM(cnx_clt_galexo) TAG idx_galexo
INDEX ON ALLTRIM(cnx_clt_codigo) TAG idx_codigo
SET ORDER TO 0

* Extraer TODOS los clientes locales para evaluar cambios contra el snapshot
SELECT VAL(cid_clien) AS cnx_clt_galexo_val, ;
       cnombre_cl AS cnx_clt_nombre, ;
       crif_cli AS cnx_clt_rif, ;
       cid_estadc AS cnx_clt_edo_codigo, ;
       cid_ciudac AS cnx_clt_mpo_codigo, ;
       cdir_cli1, ;
       ctele_cli, ;
       cid_vende, ;
       cid_clien, ;
       cnit_cli ;
FROM tclientes ;
INTO CURSOR curSubidaLocal

IF TYPE("PCESTADOENVIA") = "C"
    PCESTADOENVIA = PCESTADOENVIA + " / Clientes locales a procesar (Subida): " + TRANSFORM(RECCOUNT("curSubidaLocal"))
ENDIF

LOCAL lnActualizados, lnInsertados
lnActualizados = 0
lnInsertados = 0

IF RECCOUNT("curSubidaLocal") > 0
    SELECT curSubidaLocal
    SCAN
        LOCAL lcNombre, lcRif, lnEdoCodigo, lnMpoCodigo, lcCidClien, lcDir1, lcTel1, lcVenCod
        
        * Sanitización estricta del código
        lcCidClien  = ALLTRIM(STRTRAN(curSubidaLocal.cid_clien, " ", ""))
        
        * Sanitización con protección de NULLs
        lcNombre    = STRTRAN(ALLTRIM(NVL(curSubidaLocal.cnx_clt_nombre, "")), "'", "")
        lcRif       = ALLTRIM(NVL(curSubidaLocal.cnx_clt_rif, ""))
        lnEdoCodigo = VAL(NVL(curSubidaLocal.cnx_clt_edo_codigo, "0"))
        lnMpoCodigo = VAL(NVL(curSubidaLocal.cnx_clt_mpo_codigo, "0"))
        lcDir1      = STRTRAN(ALLTRIM(NVL(curSubidaLocal.cdir_cli1, "")), "'", "")
        lcTel1      = STRTRAN(ALLTRIM(NVL(curSubidaLocal.ctele_cli, "")), "'", "")
        lcVenCod    = ALLTRIM(STRTRAN(NVL(curSubidaLocal.cid_vende, ""), " ", ""))
        
        * 1. Identificar si existe en la nube usando el Snapshot
        LOCAL lcCloudPK, llFound, llNeedsUpdate
        lcCloudPK = ""
        llFound = .F.
        llNeedsUpdate = .F.
        
        * A) Buscar por la llave original de la nube (cnit_cli) si existe
        IF !EMPTY(curSubidaLocal.cnit_cli)
            LOCAL lcSearchNube
            lcSearchNube = ALLTRIM(curSubidaLocal.cnit_cli)
            SELECT curCloudSnapshot
            SET ORDER TO idx_codigo
            IF SEEK(lcSearchNube)
                lcCloudPK = ALLTRIM(curCloudSnapshot.cnx_clt_codigo)
                llFound = .T.
            ENDIF
        ENDIF
        
        * B) Si no se encontró, buscar por el ancla galexo (cid_clien)
        IF !llFound
            SELECT curCloudSnapshot
            SET ORDER TO idx_galexo
            IF SEEK(lcCidClien)
                lcCloudPK = ALLTRIM(curCloudSnapshot.cnx_clt_codigo)
                llFound = .T.
            ENDIF
        ENDIF
        
        LOCAL lcSqlExecute, lnResExecute
        IF llFound
            * 2. Comparar campos para evitar UPDATE innecesario (ahorro de N+1 queries al servidor)
            IF ALLTRIM(NVL(curCloudSnapshot.cnx_clt_nombre, "")) <> lcNombre OR ;
               ALLTRIM(NVL(curCloudSnapshot.cnx_clt_rif, "")) <> lcRif OR ;
               VAL(TRANSFORM(NVL(curCloudSnapshot.cnx_clt_edo_codigo, 0))) <> lnEdoCodigo OR ;
               VAL(TRANSFORM(NVL(curCloudSnapshot.cnx_clt_mpo_codigo, 0))) <> lnMpoCodigo OR ;
               ALLTRIM(NVL(curCloudSnapshot.cnx_clt_direccion1, "")) <> lcDir1 OR ;
               ALLTRIM(NVL(curCloudSnapshot.cnx_clt_telefono1, "")) <> lcTel1 OR ;
               ALLTRIM(NVL(curCloudSnapshot.cnx_clt_ven_codigo, "")) <> lcVenCod OR ;
               ALLTRIM(NVL(curCloudSnapshot.cnx_clt_galexo, "")) <> lcCidClien
               
                llNeedsUpdate = .T.
            ENDIF

            IF llNeedsUpdate
                * Telemetría: Registro de diferencia detectada Local -> Nube
                STRTOFILE("    > [SUBIDA] Diferencia detectada Local->Nube. Galexo: [" + lcCidClien + "] - Nube PK: [" + lcCloudPK + "]" + CHR(13)+CHR(10), lcLogRadar, 1)

                * 3. Flujo UPDATE (Si existe y hubo cambios locales): Actualiza el registro
                * NO sobreescribimos cnx_clt_codigo para respetar cambios en ADN
                * SI forzamos CNX_CLT_MODIFICADO = 0 para evitar efecto boomerang por triggers
                lcSqlExecute = "UPDATE conex_clientes SET " + ;
                               "cnx_clt_galexo = ?lcCidClien, " + ;
                               "cnx_clt_nombre = ?lcNombre, " + ;
                               "cnx_clt_rif = ?lcRif, " + ;
                               "cnx_clt_edo_codigo = ?lnEdoCodigo, " + ;
                               "cnx_clt_mpo_codigo = ?lnMpoCodigo, " + ;
                               "cnx_clt_direccion1 = ?lcDir1, " + ;
                               "cnx_clt_telefono1 = ?lcTel1, " + ;
                               "cnx_clt_ven_codigo = ?lcVenCod, " + ;
                               "CNX_CLT_MODIFICADO = 0 " + ;
                               "WHERE cnx_clt_codigo = ?lcCloudPK"
                               
                lnResExecute = SQLEXEC(tnH, lcSqlExecute)
                IF lnResExecute > 0
                    lnActualizados = lnActualizados + 1
                    STRTOFILE("      -> [OK SUBIDA] UPDATE exitoso en MariaDB." + CHR(13)+CHR(10), lcLogRadar, 1)
                    
                    IF ALLTRIM(curSubidaLocal.cnit_cli) <> lcCloudPK
                        UPDATE tclientes SET cnit_cli = lcCloudPK WHERE cid_clien = curSubidaLocal.cid_clien
                    ENDIF
                ELSE
                    LOCAL ARRAY laErrorU[1]
                    AERROR(laErrorU)
                    STRTOFILE("      -> [ERROR SUBIDA] Fallo UPDATE: " + ALLTRIM(TRANSFORM(laErrorU[2])) + CHR(13)+CHR(10), lcLogRadar, 1)
                    
                    IF TYPE("PCESTADOENVIA") = "C"
                        PCESTADOENVIA = PCESTADOENVIA + " | ERROR SQL NUBE (UPDATE): " + TRANSFORM(laErrorU[2])
                    ENDIF
                ENDIF
            ENDIF
        ELSE
            * 4. Flujo INSERT (Si no existe): Inserción nativa
            lcCloudPK = lcCidClien
            lcSqlExecute = "INSERT INTO conex_clientes (cnx_clt_codigo, cnx_clt_galexo, cnx_clt_nombre, cnx_clt_rif, cnx_clt_edo_codigo, cnx_clt_mpo_codigo, cnx_clt_direccion1, cnx_clt_telefono1, cnx_clt_ven_codigo, CNX_CLT_MODIFICADO) " + ;
                           "VALUES (?lcCloudPK, ?lcCidClien, ?lcNombre, ?lcRif, ?lnEdoCodigo, ?lnMpoCodigo, ?lcDir1, ?lcTel1, ?lcVenCod, 0)"
                           
            lnResExecute = SQLEXEC(tnH, lcSqlExecute)
            IF lnResExecute > 0
                lnInsertados = lnInsertados + 1
                STRTOFILE("      -> [OK SUBIDA] INSERT exitoso en MariaDB. Galexo: [" + lcCidClien + "]" + CHR(13)+CHR(10), lcLogRadar, 1)
                UPDATE tclientes SET cnit_cli = lcCloudPK WHERE cid_clien = curSubidaLocal.cid_clien
            ELSE
                LOCAL ARRAY laErrorI[1]
                AERROR(laErrorI)
                STRTOFILE("      -> [ERROR SUBIDA] Fallo INSERT: " + ALLTRIM(TRANSFORM(laErrorI[2])) + CHR(13)+CHR(10), lcLogRadar, 1)
                IF TYPE("PCESTADOENVIA") = "C"
                    PCESTADOENVIA = PCESTADOENVIA + " | ERROR SQL NUBE (INSERT): " + TRANSFORM(laErrorI[2])
                ENDIF
            ENDIF
        ENDIF
        
        * Importante: Regresar al cursor de trabajo para continuar el SCAN
        SELECT curSubidaLocal
    ENDSCAN
ENDIF

IF USED("curCloudSnapshot")
    USE IN curCloudSnapshot
ENDIF
IF USED("curSubidaLocal")
    USE IN curSubidaLocal
ENDIF

* Guardar cambios de la Subida
TABLEUPDATE(.T., .T., "tclientes")

* Control de Estado de Envío
IF TYPE("PCESTADOENVIA") = "C"
    PCESTADOENVIA = PCESTADOENVIA + "Sincronización de Clientes (Subida) - Insertados: " + TRANSFORM(lnInsertados) + " | Actualizados: " + TRANSFORM(lnActualizados) + CHR(13)
    PCESTADOENVIA = PCESTADOENVIA + "Sincronización de Clientes completada con éxito " + TTOC(DATETIME()) + CHR(13)
ENDIF

IF TYPE("contaenviar") = "N"
    contaenviar = contaenviar + lnInsertados + lnActualizados
ENDIF

RETURN .T.
