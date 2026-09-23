PARAMETERS lcbdempresa,lcnegocio

SET SAFETY OFF
SET EXCLUSIVE OFF
SET EXACT ON
CLEAR
SET EXCLUSIVE OFF
SET DELETED ON
SET DEBUGOUT TO c:\resultado.txt
SET CENTURY on
SET DATE TO BRITISH
 
CLOSE DATABASES ALL
LOCAL dirdata
LOCAL cod_empre
cod_empre=lcnegocio
**cod_empre="4"
dirdata = "c:\galepso\data\emp"+lcbdempresa+"\"
**dirdata = "c:\galepso\data\emp1\"


USE SHARED (dirdata +  ;
	"tfacturas.dbf") IN 0
USE SHARED (dirdata +  ;
	"tcompras.dbf") IN 0
USE SHARED (dirdata +  ;
	"tdevoluciones_venta.dbf") IN 0
USE SHARED (dirdata +  ;
	"tdevoluciones_compra.dbf") IN 0
USE SHARED (dirdata +  ;
	"tproductos.dbf") IN 0
USE SHARED (dirdata +  ;
	"tdetalles_factura.dbf") IN 0
USE SHARED (dirdata +  ;
	"tdetalles_devolucion_venta") IN 0		
USE SHARED (dirdata +  ;
	"tdetalles_devolucion_compra") IN 0	
USE SHARED (dirdata +  ;
	"tdetalles_compra") IN 0	
	
	
LOCAL nTotalRegistros
nTotalRegistros=0

LOCAL lBandera AS Boolean
	lBanderas=.f.
LOCAL lFacturas,lCompras,lDevVen,lDevcom as Boolean
lFacturas=.f.
lCompras=.f.
lDevVen=.f.
lDevCom	=.f.



LOCAL lcSQLcommand AS STRING

LOCAL lcSQLcommandglobal AS STRING

LOCAL lcstringcnxlocal AS STRING
lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=200.74.207.9;Database=bdferreperiquitos;User=ferreperiquitos; Password=101084pedro;Option=3"
SQLSETPROP(0, "DispLogin", 3)
lnhandle = SQLSTRINGCONNECT(lcstringcnxlocal)
IF lnhandle > 0

	SELECT tfacturas.cid_factu,tfacturas.cid_clien,tproductos.cid_produc,tdetalles_factura.ncantidad,tdetalles_factura.nprecio,tdetalles_factura.nmonto,tfacturas.dfecha ;
		FROM tfacturas INNER JOIN tdetalles_factura ON tfacturas.cid_factu=tdetalles_factura.cid_factu ;
		INNER JOIN tproductos ON tdetalles_factura.cid_produc=tproductos.cid_produc;
		WHERE DATE()-tfacturas.dfecha<=90 and cid_clien IN('99990','99991','99992','99993','99994') INTO CURSOR ttfacturas


	SELECT tdevoluciones_venta.cid_dev_v,tdevoluciones_venta.cid_clien,tproductos.cid_produc,tdetalles_devolucion_venta.ncantidad,tdetalles_devolucion_venta.nprecio,tdetalles_devolucion_venta.nmonto,tdevoluciones_venta.dfecha ;
		FROM tdevoluciones_venta INNER JOIN tdetalles_devolucion_venta ON tdevoluciones_venta.cid_dev_v=tdetalles_devolucion_venta.cid_dev_v ;
		INNER JOIN tproductos ON tdetalles_devolucion_venta.cid_produc=tproductos.cid_produc;
		WHERE DATE()-tdevoluciones_venta.dfecha<=90 AND cid_clien IN('99990','99991','99992','99993','99994') INTO CURSOR ttdevoluciones_venta

	SELECT tdevoluciones_compra.cid_dev_c,tdevoluciones_compra.cid_provee,tproductos.cid_produc,tdetalles_devolucion_compra.ncantidad,tdetalles_devolucion_compra.nprecio,tdetalles_devolucion_compra.nmonto,tdevoluciones_compra.dfecha ;
		FROM tdevoluciones_compra INNER JOIN tdetalles_devolucion_compra ON tdevoluciones_compra.cid_dev_c=tdetalles_devolucion_compra.cid_dev_c ;
		INNER JOIN tproductos ON tdetalles_devolucion_compra.cid_produc=tproductos.cid_produc;
		WHERE DATE()-tdevoluciones_compra.dfecha<=90 AND cid_provee IN('99990','99991','99992','99993','99994') INTO CURSOR ttdevoluciones_compras

	SELECT tcompras.cid_compra,tcompras.cid_provee,tproductos.cid_produc,tdetalles_compra.ncantidad,tdetalles_compra.nprecio,tdetalles_compra.nmonto,tcompras.dfecha ;
		FROM tcompras INNER JOIN tdetalles_compra ON tcompras.cid_compra=tdetalles_compra.cid_compra ;
		INNER JOIN tproductos ON tdetalles_compra.cid_produc=tproductos.cid_produc;
		WHERE DATE()-tcompras.dfecha<=90 AND cid_provee IN('99990','99991','99992','99993','99994') INTO CURSOR ttcompras
   
	lcSQLcommand = "INSERT INTO tmovimientos(cid_empre,cid_mov,cid_clipro,cid_tipomo,cid_produc,ncantidad,nprecio,nmonto,dfecha) VALUES"
	lcSQLcommandglobal = ""
	SELECT ttfacturas
	GO bottom
		nTotalRegistros=RECNO()			
	GO TOP
	DO WHILE !EOF()
		lFacturas=.t.
		
		TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
	    ('<<cod_empre>>','<<ttfacturas.cid_factu>>','<<ttfacturas.cid_clien>>','<<"SVEN">>','<<ALLTRIM(ttfacturas.cid_produc)>>',<<ttfacturas.ncantidad>>,<<ttfacturas.nprecio>>,<<ttfacturas.nmonto>>,'<<ttfacturas.dfecha>>')
		ENDTEXT
		
		IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		ELSE
		 lcSQLcommand=lcSQLcommand+","
		ENDIF	
		 	
		SELECT ttfacturas
		SKIP
	ENDDO

	nTotalRegistros=0
	lBandera=.f.
	
	SELECT ttdevoluciones_venta
	GO bottom
		nTotalRegistros=RECNO()	
	GO TOP
	DO WHILE !EOF()
		lDevVen=.t.
		
		IF !lBandera AND lFacturas
		lcSQLcommand=lcSQLcommand+","		
		lBandera=.t.
		ENDIF		
	

		TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
	    ('<<cod_empre>>','<<ttdevoluciones_venta.cid_dev_v>>','<<ttdevoluciones_venta.cid_clien>>','<<"EDEV">>','<<ALLTRIM(ttdevoluciones_venta.cid_produc)>>',<<ttdevoluciones_venta.ncantidad>>,<<ttdevoluciones_venta.nprecio>>,<<ttdevoluciones_venta.nmonto>>,'<<ttdevoluciones_venta.dfecha>>')
		ENDTEXT
				
		IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		 ELSE
		 lcSQLcommand=lcSQLcommand+","
		 ENDIF		
		 		
		SELECT ttdevoluciones_venta
		SKIP
	ENDDO

	nTotalRegistros=0
	lBandera=.f.

	SELECT ttdevoluciones_compras
	GO bottom
		nTotalRegistros=RECNO()	
	GO TOP
	DO WHILE !EOF()
	
	lDevCom=.t.
	
		IF !lBandera AND (lDevVen OR lFacturas)
			lcSQLcommand=lcSQLcommand+","		
			lBandera=.t.
		ENDIF	

		TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
	    ('<<cod_empre>>','<<ttdevoluciones_compras.cid_dev_c>>','<<ttdevoluciones_compras.cid_provee>>','<<"SDEC">>','<<ALLTRIM(ttdevoluciones_compras.cid_produc)>>',<<ttdevoluciones_compras.ncantidad>>,<<ttdevoluciones_compras.nprecio>>,<<ttdevoluciones_compras.nmonto>>,'<<ttdevoluciones_compras.dfecha>>')
		ENDTEXT
		
		 IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		 ELSE
		 lcSQLcommand=lcSQLcommand+","
		 ENDIF			
		SELECT ttdevoluciones_compras
		SKIP
	ENDDO

	nTotalRegistros=0
	lBandera=.f.
	
	SELECT ttcompras
	GO bottom
		nTotalRegistros=RECNO()
	GO TOP
	DO WHILE !EOF()	
	
		IF !lBandera AND (lDevCom OR lDevVen OR lFacturas)
			lcSQLcommand=lcSQLcommand+","		
			lBandera=.t.
		ENDIF	

		TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
        ('<<cod_empre>>','<<ttcompras.cid_compra>>','<<ttcompras.cid_provee>>','<<"ECOM">>','<<ALLTRIM(ttcompras.cid_produc)>>',<<ttcompras.ncantidad>>,<<ttcompras.nprecio>>,<<ttcompras.nmonto>>,'<<ttcompras.dfecha>>')
        ENDTEXT
         
		  IF RECNO()=nTotalRegistros then
		  **lcSQLcommand=lcSQLcommand+";"
		  ELSE
		  lcSQLcommand=lcSQLcommand+","
		  ENDIF
	SELECT ttcompras
	SKIP
	ENDDO
	
	nTotalRegistros=0
	lBandera=.f.
	
	
	lcSQLcommand=lcSQLcommand+";"

	**CREATE CURSOR temporal( consulta M)
	**SELECT temporal
	**APPEND BLANK
	**replace consulta WITH lcSQLcommand


	CLOSE DATABASES ALL
	
	SQLEXEC(lnhandle, "DELETE FROM tmovimientos where cid_empre='"+cod_empre+"'")
	SQLEXEC(lnhandle, lcSQLcommand )
	SQLEXEC(lnhandle, "UPDATE tsincronizacion set dact_inventario=CONVERT_TZ(NOW(),'-4:30','-8:00') where cid_empre='"+cod_empre+"'")


    SQLDISCONNECT(lnhandle)
    
    PCESTADOENVIA = PCESTADOENVIA+CHR(13)+"Transferencia de Movimientos de Inventario realizada en forma Exitosa " + TTOC(DATETIME())
ELSE
     PCESTADOENVIA = PCESTADOENVIA+CHR(13)+ "No se encontro conexion a internet " + TTOC(DATETIME())
ENDIF


	
		
FUNCTION FECHAGUION
LPARAMETERS fecha
LOCAL valor
valor = ALLTRIM(STR(YEAR(fecha))) +  ;
        "-" +  ;
        ALLTRIM(STR(MONTH(fecha))) +  ;
        "-" +  ;
        ALLTRIM(STR(DAY(fecha)))
RETURN valor
ENDFUNC
**
***

