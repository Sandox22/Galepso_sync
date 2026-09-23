SET SAFETY OFF
SET EXCLUSIVE OFF
SET EXACT ON
CLEAR
SET EXCLUSIVE OFF
SET DELETED ON
SET DEBUGOUT TO c:\resultado.txt
SET DATE TO british
CLOSE DATABASES ALL
_CALCVALUE=6023
LOCAL dirdata
dirdata = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
USE SHARED (dirdata + "tdevoluciones_venta.dbf") IN 0
USE SHARED (dirdata + "tdetalles_devolucion_venta.dbf") IN 0
USE SHARED (dirdata + "tclientes.dbf") IN 0


LOCAL lcSQLcommand
	lcSQLcommand=""
	
	LOCAL lBandera AS Boolean
	lBanderas=.f.
	
	LOCAL nTotalRegistros
	nTotalRegistros=0
	
SELECT tdevoluciones_venta
SET ORDER TO IX_DEV_VEN	
**PUBLIC lcStringConexion
**lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=108.179.194.12;Database=felcason_demoliderplus;User=felcason_demo; Password=DeMoLiDeR;Option=3"
LOCAL cmdDevoluciones
LOCAL cmdDetalles

**LOCAL lcstringcnxlocal AS STRING
**lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=204.12.208.38;Database=autorepu_f1;User=autor_f1; Password=auto@123;Option=3"
*lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=bdfelcas;User=root; Password=;Option=3"

PUBLIC lcStringConexion
**lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=40.160.61.158;Database=chocola2_liderplus;User=chocola2_liderplus; Password=Liderplus2026*;Option=3"
lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=liderplus_sandbox;User=root; Password=;Option=3"
LOCAL lcQuery
lcQuery=''

SQLSETPROP(0, "DispLogin", 3)
lnHandle = SQLSTRINGCONNECT(lcStringConexion)
IF lnHandle > 0

	cmdDevoluciones=SQLExec(lnHandle,"SELECT cid_dev_v,tclientes.cid_clien,tclientes.cnombre_cl,tclientes.crif_cli,dfecha,cid_status,tdevoluciones_venta.cid_vende from tdevoluciones_venta inner join tclientes on tdevoluciones_venta.cid_clien=tclientes.cid_clien where trim(cid_status)='1' ","ttdevoluciones")
	
	lcQuery=""
	TEXT TO lcQuery NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
	SELECT tdevoluciones_venta.cid_dev_v,tdetalles_devolucion_venta.cid_produc,tproductos.cdescripci,ncantidad,nprecio,nmonto,tdetalles_devolucion_venta.mobservaci from tdevoluciones_venta inner join tdetalles_devolucion_venta on tdevoluciones_venta.cid_dev_v=tdetalles_devolucion_venta.cid_dev_v inner join tproductos on tdetalles_devolucion_venta.cid_produc=tproductos.cid_produc WHERE trim(cid_status)='1'
	ENDTEXT	
		
	cmdDetalles=SQLExec(lnHandle,lcQuery,"ttdetalles_devolucion_venta")
	
	
	
	
	LOCAL lcSqlUpdate,lcDevoluciones
	lcDevoluciones=""
	lcSqlUpdate="UPDATE tdevoluciones_venta SET cid_status=case cid_dev_v "
	
	SELECT ttdevoluciones
	GO bottom
	nTotalRegistros=RECNO() 
	GO top
	DO WHILE !EOF()
		SELECT tdevoluciones_venta
		SEEK(PADL(ALLTRIM(ttdevoluciones.cid_dev_v),8))
		IF FOUND()
			SELECT ttdevoluciones
			SKIP
			loop
		ENDIF
		
			lcDevoluciones=lcDevoluciones+ALLTRIM(ttdevoluciones.cid_dev_v)+","
		
*!*			    append blank
*!*			    replace cid_reci_i with str(ttrecibos.cid_reci_i,8)
*!*			    replace cid_clien with str(val(ttpedidos.cid_clien),5)
*!*			 	replace dfecha with ttpedidos.dfecha		            
*!*			    replace cid_status with "  1"
*!*			    replace ctipo_pre with " 1"
*!*			    replace cid_vende with str(val(ttpedidos.cid_vende),5)
*!*			    replace cnombre_cl with ttpedidos.cnombre_cl
*!*			    replace crif_cli WITH ttpedidos.crif_cli
*!*			    replace nmonto_f with ttpedidos.nmonto_t
*!*			    replace nmontoti with ttpedidos.nmontoiva
*!*			    replace nmonto_t WITH ttpedidos.nmonto_t+ttpedidos.nmontoiva
*!*			           
*!*				    select ttdetalles_pedido
*!*				    set filter to ttdetalles_pedido.cid_pedido == ttpedidos.cid_pedido
*!*				    goto top
*!*				    do while !eof()
*!*				      select tdetalles_pedido
*!*				      append blank
*!*				      replace cid_pedido with str(ttpedidos.cid_pedido,8)
*!*				      replace cid_produc with ttdetalles_pedido.cid_produc
*!*				      replace ncantidad with ttdetalles_pedido.ncantidad
*!*				      replace nprecio with ttdetalles_pedido.nprecio
*!*				      replace nmonto with ttdetalles_pedido.nmonto
*!*				     ** replace ndescuento with ttdetalles_pedido.ndescuento
*!*				      
*!*				    SELECT ttdetalles_pedido
*!*				    SKIP
*!*				    enddo  
		
		
	
	SELECT ttdevoluciones
	lcSqlUpdate=lcSqlUpdate+ " WHEN "+ALLTRIM(ttdevoluciones.cid_dev_v)+" then '3'"
	
		IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		ELSE
		 lcSqlUpdate=lcSqlUpdate+""
		ENDIF	
		
	SKIP
	ENDDO 
	
	lcDevoluciones=SUBSTR(ALLTRIM(lcDevoluciones),1,LEN(ALLTRIM(lcDevoluciones))-1)
	
	lcSqlUpdate=lcSqlUpdate+" END WHERE cid_dev_v in("+lcDevoluciones+")"	
	
	CREATE CURSOR temporal(Comando M)
	SELECT temporal
	APPEND BLANK
	replace Comando WITH lcSqlUpdate
	
	SQLEXEC(lnHandle,lcSqlUpdate)
	
	
	
	SELECT ttdevoluciones
	GO top
	
	IF !EMPTY(ttdevoluciones.cid_dev_v)
	correo()
	endif
	**return
	
	
	
	
	 CLOSE DATABASES all
     SQLDISCONNECT(lnhandle)
     PCESTADOENVIA = "Devoluciones Recibidas con exito " + TTOC(DATETIME())
ELSE
    PCESTADOENVIA = "No se logro establecer conexion a internet recibiendo devoluciones" + TTOC(DATETIME())		
ENDIF


FUNCTION Correo()
	LOCAL lcTextoCorreo,strHTML
	lcTextoCorreo=""
	strHTML=""

	loCfg = CREATEOBJECT("CDO.Configuration")
	WITH loCfg.Fields
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com"
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "ventasypedidoselite@gmail.com"
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "lbyuvxtvqdqtesek"
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = .T.
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = .T.
	  .Update
	ENDWITH

	loMsg = CREATEOBJECT ("CDO.Message")
	WITH loMsg
	  .Configuration = loCfg
	  .From = "ventasypedidoselite@gmail.com"
	  .To = "ventasypedidoselite@gmail.com"
	  .Subject = "Notificacion de Devoluciones recibidas en oficina"
	 
	  
	  strHTML = "<HTML>"
	  strHTML = strHTML + "<HEAD>"
	  strHTML = strHTML + "<BODY>"
	  strHTML = strHTML + "<b> Se han recibido las siguientes Devoluciones</b><br>"
	  
	  	 
	  
	  SELECT ttdevoluciones
	  GO top
	  DO while !EOF()
	  	strHTML = strHTML + "<table border=2>"
	   	strHTML = strHTML + "<tr>"
	  	strHTML = strHTML + "<td width=200>Devolucion Nro: "+ALLTRIM(ttdevoluciones.cid_dev_v)+"</td><td width=1000> Cliente: "+ttdevoluciones.cid_clien+" - "+ALLTRIM(ttdevoluciones.cnombre_cl)+"</td>"
	  	strHTML = strHTML + "</tr>"
	  	strHTML = strHTML + "</table>"
	  	
	  	strHTML = strHTML + "<table border=2>"
	  	SELECT ttdetalles_devolucion_venta
	  	SET FILTER TO cid_dev_v=ttdevoluciones.cid_dev_v
	  	GO TOP 
	  	DO while !EOF()
	  		
	  		strHTML = strHTML + "<tr>"
	  		strHTML = strHTML + "<td width=200> Codigo </td><td width=400> Descripcion </td><td width=200> Cantidad </td> <td width=200> Precio </td> </td> <td width=200> Monto </td>"
	  		strHTML = strHTML + "</tr>"
	   		strHTML = strHTML + "<tr>"
	   		strHTML = strHTML + "<td width=200>"+ALLTRIM(ttdetalles_devolucion_venta.cid_produc)+"</td><td width=200>"+ttdetalles_devolucion_venta.cdescripci+"</td><td width=200>"+ALLTRIM(STR(ttdetalles_devolucion_venta.ncantidad,12,2))+"</td><td width=200>"+ALLTRIM(STR(ttdetalles_devolucion_venta.nprecio,12,2))+"</td> <td width=200>"+ALLTRIM(STR(ttdetalles_devolucion_venta.nmonto,8,2))+"</td>"
	
	  		strHTML = strHTML + "</tr>"
	  		
	  	
	  	SELECT ttdetalles_devolucion_venta
	  	SKIP
	  	ENDDO
	  	strHTML = strHTML + "</table>"
	  SELECT ttdevoluciones
	  SKIP
	  ENDDO
	  
	  
	  
	 ** strHTML = strHTML + lcTextoCorreo
	  
	  
	 
	  
	  strHTML = strHTML + "</BODY>"
	  strHTML = strHTML + "</HTML>"
	  .HTMLBody = strHTML
	  .Send()
	ENDWITH
endfunc