* pedidos.prg
* Módulo de bajada transaccional para pedidos desde MariaDB a VFP
* Patrón C: Bajada Transaccional ACID

LPARAMETERS tnH

IF TYPE("tnH") <> "N" OR tnH <= 0
    IF TYPE("PCESTADORECIBE") = "C"
        PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: Handle ODBC invalido." + CHR(13)
    ENDIF
    RETURN .F.
ENDIF

LOCAL lcDirData, lnRet, lcSQL, laErr[1], lnCount
lnCount = 0

* Resolucion de ruta de datos
IF TYPE("dirdata") = "C" AND !EMPTY(dirdata)
    lcDirData = dirdata
ELSE
    IF TYPE("PCUNIDAD") = "C" AND TYPE("pcSistema") = "C" AND TYPE("pcEmpresa") = "C"
        lcDirData = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
    ELSE
        lcDirData = "X:\Galepso\Data\Emp6\"   && Fallback hardcoded
    ENDIF
ENDIF

* Saneamiento preventivo de transacciones huerfanas
DO WHILE TXNLEVEL() > 0
    ROLLBACK
ENDDO

SET MULTILOCKS ON

* Apertura defensiva de tcontroles
IF !USED("tcontroles")
    IF FILE(lcDirData + "tcontroles.dbf")
        USE (lcDirData + "tcontroles.dbf") SHARED IN 0 ALIAS tcontroles
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se encontro tcontroles.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Apertura defensiva de tpedidos
IF !USED("tpedidos")
    IF FILE(lcDirData + "tpedidos.dbf")
        USE (lcDirData + "tpedidos.dbf") SHARED IN 0 ALIAS tpedidos
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se encontro tpedidos.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Apertura defensiva de tdetalles_pedido
IF !USED("tdetalles_pedido")
    IF FILE(lcDirData + "tdetalles_pedido.dbf")
        USE (lcDirData + "tdetalles_pedido.dbf") SHARED IN 0 ALIAS tdetalles_pedido
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se encontro tdetalles_pedido.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Apertura defensiva de tclientes
IF !USED("tclientes")
    IF FILE(lcDirData + "tclientes.dbf")
        USE (lcDirData + "tclientes.dbf") SHARED IN 0 ALIAS tclientes
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se encontro tclientes.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Apertura defensiva de tvendedores
IF !USED("tvendedores")
    IF FILE(lcDirData + "tvendedores.dbf")
        USE (lcDirData + "tvendedores.dbf") SHARED IN 0 ALIAS tvendedores
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se encontro tvendedores.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

CURSORSETPROP("Buffering", 5, "tpedidos")
CURSORSETPROP("Buffering", 5, "tdetalles_pedido")

* 1. Extraccion desde la Nube (MariaDB) - Cabeceras
LOCAL lcLogMsg
lcLogMsg = DTOC(DATE()) + " " + TIME() + " - [Radar] Buscando pedidos pendientes..." + CHR(13) + CHR(10)
STRTOFILE(lcLogMsg, lcDirData + "sync_log.txt", 1)

lcSQL = "SELECT * FROM conex_documentos WHERE CNX_CHECK = 0 AND CNX_DCL_TDT_CODIGO = 'PED'"
lnRet = SQLEXEC(tnH, lcSQL, "cur_conex_doc")
IF lnRet < 0
    LOCAL ARRAY laErr[1]
    AERROR(laErr)
    LOCAL lcErrSql
    lcErrSql = DTOC(DATE()) + " " + TIME() + " - [Radar] ERROR SQL leyendo pedidos: " + ALLTRIM(TRANSFORM(laErr[2])) + CHR(13) + CHR(10)
    STRTOFILE(lcErrSql, lcDirData + "error_sync.txt", 1)
    
    IF TYPE("PCESTADORECIBE") = "C"
        PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR MariaDB (Cabeceras): " + ALLTRIM(TRANSFORM(laErr[2])) + " " + TTOC(DATETIME()) + CHR(13)
    ENDIF
    RETURN .F.
ENDIF

lcLogMsg = DTOC(DATE()) + " " + TIME() + " - [Radar] Pedidos pendientes detectados: " + TRANSFORM(RECCOUNT("cur_conex_doc")) + CHR(13) + CHR(10)
STRTOFILE(lcLogMsg, lcDirData + "sync_log.txt", 1)

SELECT cur_conex_doc
IF RECCOUNT() = 0
    USE IN cur_conex_doc
    RETURN 0
ENDIF

* Extraccion de detalles de la nube
lcSQL = "SELECT d.* FROM conex_movimientos d INNER JOIN conex_documentos c ON d.CNX_MCL_DCL_NUMERO = c.CNX_DCL_NUMERO WHERE c.CNX_CHECK = 0 AND c.CNX_DCL_TDT_CODIGO = 'PED'"
lnRet = SQLEXEC(tnH, lcSQL, "cur_conex_mov")
IF lnRet < 0
    AERROR(laErr)
    IF TYPE("PCESTADORECIBE") = "C"
        PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR MariaDB (Detalles): " + ALLTRIM(TRANSFORM(laErr[2])) + " " + TTOC(DATETIME()) + CHR(13)
    ENDIF
    USE IN cur_conex_doc
    RETURN .F.
ENDIF

SELECT cur_conex_doc
GO TOP

DO WHILE !EOF()
    LOCAL llError, lcNumeroNube, lcNewPedidoID, lnNextPedido, lcCidCliente, lcCidVende, lnMontoT
    llError = .F.
    
    lcNumeroNube = ALLTRIM(TRANSFORM(cur_conex_doc.CNX_DCL_NUMERO))
    
    * Verificacion preventiva de duplicados (ya procesado pero fallo el acuse en MariaDB)
    SELECT tpedidos
    LOCATE FOR ALLTRIM(creferenci) == lcNumeroNube
    IF FOUND()
        * Existe, hacer el UPDATE en MariaDB para sacarlo de la cola y continuar
        LOCAL lcSqlUpdateDupe, lnRetDupe
        lcNewPedidoID = tpedidos.cid_pedido
        lcSqlUpdateDupe = "UPDATE conex_documentos SET CNX_CHECK = 1, CNX_PED_GALEXO = ?lcNewPedidoID WHERE CNX_DCL_NUMERO = ?lcNumeroNube"
        lnRetDupe = SQLEXEC(tnH, lcSqlUpdateDupe)
        IF lnRetDupe < 0
            AERROR(laErr)
            IF TYPE("PCESTADORECIBE") = "C"
                PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR Update MariaDB (Duplicado) " + lcNumeroNube + ": " + ALLTRIM(TRANSFORM(laErr[2])) + CHR(13)
            ENDIF
        ENDIF
        SELECT cur_conex_doc
        SKIP
        LOOP
    ENDIF
    
    * Variables de la cabecera
    LOCAL lcCloudCli, lcCloudVen
    lcCloudCli = ALLTRIM(TRANSFORM(cur_conex_doc.cnx_dcl_clt_codigo))
    lcCloudVen = ALLTRIM(TRANSFORM(cur_conex_doc.cnx_dcl_ven_codigo))
    
    * Por defecto, el ID del cliente y vendedor asumen ser el de la nube
    lcCidCliente = lcCloudCli
    lcCidVende   = lcCloudVen
    lnMontoT     = cur_conex_doc.CNX_DCL_NETO
    
    * Validacion de Cliente Local
    SELECT tclientes
    * Buscamos por la clave primaria directa o por la marca de sincronizacion cruzada
    LOCATE FOR ALLTRIM(cid_clien) == ALLTRIM(lcCloudCli) OR ALLTRIM(cnit_cli) == ALLTRIM(lcCloudCli)
    IF FOUND()
        * Si existe, tomamos su ID local real para armar el pedido
        lcCidCliente = tclientes.cid_clien
    ELSE
        LOCAL lcSqlCli, lnRetCli
        TEXT TO lcSqlCli NOSHOW TEXTMERGE
            SELECT * FROM conex_clientes WHERE CNX_CLT_CODIGO = '<<lcCloudCli>>'
        ENDTEXT
        lnRetCli = SQLEXEC(tnH, lcSqlCli, "cur_clt_nube")
        
        IF lnRetCli > 0 AND USED("cur_clt_nube") AND RECCOUNT("cur_clt_nube") > 0
            SELECT cur_clt_nube
            
            * Comprobar si existe mapeo de Galepso ID en la nube
            LOCAL lcGalexoID
            lcGalexoID = ALLTRIM(TRANSFORM(NVL(cur_clt_nube.CNX_CLT_GALEXO, "")))
            IF !EMPTY(lcGalexoID) AND lcGalexoID <> "0"
                lcCidCliente = PADL(lcGalexoID, 5, '0')
            ELSE
                * 1. Autogeneracion Segura: Calcular proximo correlativo local (5 caracteres)
                LOCAL lnMaxCli
                SELECT MAX(VAL(cid_clien)) AS max_id FROM tclientes INTO CURSOR cur_max_cli
                lnMaxCli = NVL(cur_max_cli.max_id, 0)
                USE IN cur_max_cli
                lcCidCliente = PADL(ALLTRIM(STR(lnMaxCli + 1)), 5, '0')
            ENDIF
            
            * Extraccion segura a variables locales
            LOCAL lcNom, lcRif, lcDir, lcTele, lcVen, lnEdo, lnMpo
            lcNom  = LEFT(TRANSFORM(NVL(cur_clt_nube.CNX_CLT_NOMBRE, "")), 100)
            lcRif  = LEFT(TRANSFORM(NVL(cur_clt_nube.CNX_CLT_RIF, "")), 12)
            lcDir  = LEFT(TRANSFORM(NVL(cur_clt_nube.CNX_CLT_DIRECCION1, "")), 60)
            lcTele = LEFT(TRANSFORM(NVL(cur_clt_nube.CNX_CLT_TELEFONO1, "")), 25)
            lcVen  = STR(VAL(TRANSFORM(NVL(cur_clt_nube.CNX_CLT_VEN_CODIGO, "0"))), 5)
            lnEdo  = STR(VAL(TRANSFORM(NVL(cur_clt_nube.CNX_CLT_EDO_CODIGO, "0"))), 2)
            lnMpo  = STR(VAL(TRANSFORM(NVL(cur_clt_nube.CNX_CLT_MPO_CODIGO, "0"))), 2)
            
            USE IN cur_clt_nube
            
            * Insertar con TRY...CATCH para evitar fallos silenciosos por esquemas
            TRY
                SELECT tclientes
                * 2. Mapeo Cruzado: Usamos correlativo local y guardamos el ID nube en cnit_cli
                INSERT INTO tclientes ;
                    (cid_clien, cnit_cli, cnombre_cl, crif_cli, cdir_cli1, ctele_cli, cid_vende, cid_estadc, cid_ciudac, lactivo) ;
                    VALUES ;
                    (lcCidCliente, lcCloudCli, lcNom, lcRif, lcDir, lcTele, lcVen, lnEdo, lnMpo, .T.)
                STRTOFILE(DTOC(DATE()) + " " + TIME() + " - [Rescate] Cliente insertado: " + lcCidCliente + " (Nube: " + lcCloudCli + ")" + CHR(13) + CHR(10), lcDirData + "sync_log.txt", 1)
            CATCH TO oErrCli
                LOCAL lcErrInsCli
                lcErrInsCli = DTOC(DATE()) + " " + TIME() + " - [Pedido " + lcNumeroNube + "] ERROR Insertando Cliente " + lcCidCliente + ": " + oErrCli.Message + CHR(13) + CHR(10)
                STRTOFILE(lcErrInsCli, lcDirData + "error_sync.txt", 1)
                llError = .T.
            ENDTRY
                
            SELECT cur_conex_doc
        ELSE
            LOCAL lcErrCli
            lcErrCli = DTOC(DATE()) + " " + TIME() + " - [Pedido " + lcNumeroNube + "] Omitido: El cliente nube " + lcCloudCli + " no existe ni local ni en la nube." + CHR(13) + CHR(10)
            STRTOFILE(lcErrCli, lcDirData + "error_sync.txt", 1)
            IF TYPE("PCESTADORECIBE") = "C"
                PCESTADORECIBE = PCESTADORECIBE + lcErrCli
            ENDIF
            IF USED("cur_clt_nube")
                USE IN cur_clt_nube
            ENDIF
            SELECT cur_conex_doc
            SKIP
            LOOP
        ENDIF
    ENDIF
    
    * Validacion de Vendedor Local
    IF llError
        SKIP
        LOOP
    ENDIF

    SELECT tvendedores
    LOCATE FOR ALLTRIM(cid_vende) == ALLTRIM(lcCloudVen)
    IF FOUND()
        lcCidVende = tvendedores.cid_vende
    ELSE
        LOCAL lcSqlVen, lnRetVen
        TEXT TO lcSqlVen NOSHOW TEXTMERGE
            SELECT * FROM conex_vendedores WHERE CNX_VEN_CODIGO = '<<lcCloudVen>>'
        ENDTEXT
        lnRetVen = SQLEXEC(tnH, lcSqlVen, "cur_ven_nube")
        
        IF lnRetVen > 0 AND USED("cur_ven_nube") AND RECCOUNT("cur_ven_nube") > 0
            SELECT cur_ven_nube
            
            * Comprobar si existe mapeo de Galepso ID en la nube
            LOCAL lcGalexoVen
            lcGalexoVen = ALLTRIM(TRANSFORM(NVL(cur_ven_nube.CNX_VEN_GALEXO, "")))
            IF !EMPTY(lcGalexoVen) AND lcGalexoVen <> "0"
                lcCidVende = PADL(lcGalexoVen, 5, '0')
            ELSE
                * 1. Autogeneracion Segura: Calcular proximo correlativo local (5 caracteres)
                LOCAL lnMaxVen
                SELECT MAX(VAL(cid_vende)) AS max_id FROM tvendedores INTO CURSOR cur_max_ven
                lnMaxVen = NVL(cur_max_ven.max_id, 0)
                USE IN cur_max_ven
                lcCidVende = PADL(ALLTRIM(STR(lnMaxVen + 1)), 5, '0')
            ENDIF
            
            * Extraccion segura a variables locales
            LOCAL lcNomVen
            lcNomVen = LEFT(TRANSFORM(NVL(cur_ven_nube.CNX_VEN_NOMBRE, "")), 40)
            
            USE IN cur_ven_nube
            
            TRY
                SELECT tvendedores
                * En tvendedores no nos pidieron mapeo cruzado (cnit_vende), pero aseguramos el ID a 5 digitos
                INSERT INTO tvendedores ;
                    (cid_vende, cnombrev, ctipo_v, lactivo) ;
                    VALUES ;
                    (lcCidVende, lcNomVen, "2", .T.)
                STRTOFILE(DTOC(DATE()) + " " + TIME() + " - [Rescate] Vendedor insertado: " + lcCidVende + " (Nube: " + lcCloudVen + ")" + CHR(13) + CHR(10), lcDirData + "sync_log.txt", 1)
            CATCH TO oErrVen
                LOCAL lcErrInsVen
                lcErrInsVen = DTOC(DATE()) + " " + TIME() + " - [Pedido " + lcNumeroNube + "] ERROR Insertando Vendedor " + lcCidVende + ": " + oErrVen.Message + CHR(13) + CHR(10)
                STRTOFILE(lcErrInsVen, lcDirData + "error_sync.txt", 1)
                llError = .T.
            ENDTRY
                
            SELECT cur_conex_doc
        ELSE
            LOCAL lcErrVen
            lcErrVen = DTOC(DATE()) + " " + TIME() + " - [Pedido " + lcNumeroNube + "] Omitido: El vendedor nube " + lcCloudVen + " no existe ni local ni en la nube." + CHR(13) + CHR(10)
            STRTOFILE(lcErrVen, lcDirData + "error_sync.txt", 1)
            IF TYPE("PCESTADORECIBE") = "C"
                PCESTADORECIBE = PCESTADORECIBE + lcErrVen
            ENDIF
            IF USED("cur_ven_nube")
                USE IN cur_ven_nube
            ENDIF
            SELECT cur_conex_doc
            SKIP
            LOOP
        ENDIF
    ENDIF
    
    IF llError
        SKIP
        LOOP
    ENDIF
    
    * 2. Generacion del Correlativo Local (tcontroles.dbf)
    SELECT tcontroles
    IF RLOCK()
        lnNextPedido  = tcontroles.npedidos_c
        lcNewPedidoID = STR(lnNextPedido, 8)
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se pudo bloquear tcontroles.dbf" + CHR(13)
        ENDIF
        llError = .T.
    ENDIF
    
    IF !llError
        BEGIN TRANSACTION
        
        TRY
            * 3. Mapeo Estricto de Cabecera (tpedidos)
            INSERT INTO tpedidos ;
                (cid_pedido, creferenci, cid_clien, cid_vende, nmonto_t, cid_status, cid_usuari, ctipo_pre) ;
                VALUES ;
                (lcNewPedidoID, lcNumeroNube, lcCidCliente, lcCidVende, lnMontoT, "  1", "SYNC", " 1")
            
            * 4. Mapeo Estricto de Renglones (tdetalles_pedido)
            SELECT cur_conex_mov
            SET FILTER TO ALLTRIM(TRANSFORM(CNX_MCL_DCL_NUMERO)) == lcNumeroNube
            GO TOP
            
            DO WHILE !EOF()
                LOCAL lcProducto, lnCantidad, lnPrecio, lnMonto
                lcProducto = ALLTRIM(TRANSFORM(cur_conex_mov.CNX_MCL_UPP_PDT_CODIGO))
                lnCantidad = cur_conex_mov.CNX_MCL_CANTIDAD
                lnPrecio   = cur_conex_mov.CNX_MCL_BASE
                lnMonto    = lnCantidad * lnPrecio
                
                INSERT INTO tdetalles_pedido ;
                    (cid_pedido, cid_produc, ncantidad, nprecio, nmonto, nentregado) ;
                    VALUES ;
                    (lcNewPedidoID, lcProducto, lnCantidad, lnPrecio, lnMonto, 0)
                
                SELECT cur_conex_mov
                SKIP
            ENDDO
            SET FILTER TO
            
            * Escritura en disco (Flush)
            IF !TABLEUPDATE(1, .T., "tpedidos") OR !TABLEUPDATE(1, .T., "tdetalles_pedido")
                llError = .T.
                LOCAL ARRAY laErrTable[1]
                AERROR(laErrTable)
                LOCAL lcErrTbl
                lcErrTbl = DTOC(DATE()) + " " + TIME() + " - [Pedido " + lcNumeroNube + "] ERROR TABLEUPDATE nativo: " + ALLTRIM(TRANSFORM(laErrTable[2])) + CHR(13) + CHR(10)
                STRTOFILE(lcErrTbl, lcDirData + "error_sync.txt", 1)
                
                IF TYPE("PCESTADORECIBE") = "C"
                    PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR TABLEUPDATE: " + ALLTRIM(TRANSFORM(laErrTable[2])) + CHR(13)
                ENDIF
            ENDIF
            
        CATCH TO oErr
            llError = .T.
            LOCAL lcErrCatch
            lcErrCatch = DTOC(DATE()) + " " + TIME() + " - [Pedido " + lcNumeroNube + "] CATCH ERROR transaccion: " + oErr.Message + " (Lin: " + TRANSFORM(oErr.LineNo) + ")" + CHR(13) + CHR(10)
            STRTOFILE(lcErrCatch, lcDirData + "error_sync.txt", 1)
            
            IF TYPE("PCESTADORECIBE") = "C"
                PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] CATCH ERROR: " + oErr.Message + CHR(13)
            ENDIF
        ENDTRY
        
        IF llError
            ROLLBACK
            SELECT tcontroles
            UNLOCK
            
            * Limpieza mandatoria de buffers sucios para evitar bloqueos iterativos
            IF USED("tpedidos")
                TABLEREVERT(.T., "tpedidos")
            ENDIF
            IF USED("tdetalles_pedido")
                TABLEREVERT(.T., "tdetalles_pedido")
            ENDIF
        ELSE
            END TRANSACTION
            FLUSH FORCE
            
            * 5. Acuse de Recibo y Concurrencia (Nube y Local)
            LOCAL lcSqlUpdate, lnRetUpdate
            lcSqlUpdate = "UPDATE conex_documentos SET CNX_CHECK = 1, CNX_PED_GALEXO = ?lcNewPedidoID WHERE CNX_DCL_NUMERO = ?lcNumeroNube"
            lnRetUpdate = SQLEXEC(tnH, lcSqlUpdate)
            
            IF lnRetUpdate < 0
                AERROR(laErr)
                IF TYPE("PCESTADORECIBE") = "C"
                    PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR Update MariaDB " + lcNumeroNube + ": " + ALLTRIM(TRANSFORM(laErr[2])) + CHR(13)
                ENDIF
            ENDIF
            
            * Consolidar incremento en tcontroles y liberar
            SELECT tcontroles
            REPLACE npedidos_c WITH (lnNextPedido + 1)
            UNLOCK
            
            * Estadisticas globales
            lnCount = lnCount + 1
            IF TYPE("contarecibe") = "N"
                contarecibe = contarecibe + 1
            ENDIF
        ENDIF
    ENDIF
    
    SELECT cur_conex_doc
    SKIP
ENDDO

* Limpieza de cursores temporales
IF USED("cur_conex_doc")
    USE IN cur_conex_doc
ENDIF
IF USED("cur_conex_mov")
    USE IN cur_conex_mov
ENDIF

RETURN lnCount