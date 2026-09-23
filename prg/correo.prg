FUNCTION Correo()
	LOCAL lcTextoCorreo
	lcTextoCorreo=""

	loCfg = CREATEOBJECT("CDO.Configuration")
	WITH loCfg.Fields
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com"
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "pedrolopez@felcas.com.ve"
	  .Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "101084pedro"
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = .T.
	  .Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = .T.
	  .Update
	ENDWITH

	loMsg = CREATEOBJECT ("CDO.Message")
	WITH loMsg
	  .Configuration = loCfg
	  .From = "pedrolopez@felcas.com.ve"
	  .To = "pedrolopez@felcas.com.ve"
	  .Subject = "Notificacion de Recepcion de Pedidos<br>"
	  lcTextoCorreo="Se han recibido los siguientes pedidos<br>"
	  
	  SELECT ttPedidos
	  GO top
	  DO while !EOF()
	  	lcTextoCorreo=lcTextoCorreo+"Pedido Nro: "+ttpedidos.cid_pedido+" Cliente: "+ttpedidos.cid_clien+" - "+ttpedidos.cnombre_cl+"<br>"
	  SKIP
	  ENDDO
	  
	  
	  .TextBody = lcTextoCorreo
	  .Send()
	ENDWITH
endfunc