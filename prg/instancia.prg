loPsServer   			= Createobject("clsPsSmtpServer")
loPsServer.lNeedCreds	= .T.
loPsServer.lUseSSL 		= .F.
loPsServer.cServer		= Lower(Alltrim(FIRMA.TX_SMTPSRV))
loPsServer.cUser		= Lower(Alltrim(FIRMA.TX_SMTPUSR))
loPsServer.cPass		= Alltrim(FIRMA.TX_SMTPPWD)
loPsServer.nPort		= FIRMA.NU_SMTPPT

* Creo Mensaje
loMessage = Createobject("clsPsMessage")
loMessage.lIsHtml		= .T.
loMessage.cFrom 		= OL_MAIL.P_SENDERNAME  + "<" + lcSenderPs + ">"
loMessage.cPriority		= "High"		&& Or Normal or Low
loMessage.cDNO			= "OnFailure"	&& Or None,OnSuccess,Delay,None
* -- Agrego destinatarios (normal, CC and BCC)
For lnCorreo=1 To Getwordcount(OL_MAIL.P_ADDRECIPIENT,';')
	loMessage.colRecipients.Add(Createobject("clsRecipient", "", Getwordnum(OL_MAIL.P_ADDRECIPIENT,lnCorreo,';')))
Next lnCorreo
For lnCorreo=1 To Getwordcount(OL_MAIL.P_ADDRECIPIENTCC,';')
	loMessage.colCC.Add(Createobject("clsRecipient", "", Getwordnum(OL_MAIL.P_ADDRECIPIENTCC,lnCorreo,';')))
Next lnCorreo
For lnCorreo=1 To Getwordcount(OL_MAIL.P_ADDRECIPIENTBCC,';')
	loMessage.colBCC.Add(Createobject("clsRecipient", "", Getwordnum(OL_MAIL.P_ADDRECIPIENTBCC,lnCorreo,';')))
Next lnCorreo
* -- Agrego Adjuntos
lnEnviados=0
OL_ADJUNTOS = OP.M_SPLIT(OL_MAIL.P_ADDATTACHMENT)
For VL_I = 1 To OL_ADJUNTOS.P_LINEAS
	If File(OL_ADJUNTOS.P_ITEMS(VL_I))
		lnEnviados=lnEnviados+1
		loMessage.colAttach.Add(OL_ADJUNTOS.P_ITEMS(VL_I))
	Endif
Next
* -- Asunto y cuerpo del correo
loMessage.cSubject = Alltrim(OL_MAIL.P_SUBJECT)
If Empty(OL_MAIL.P_HTMLBODY)
	loMessage.cBody = Chr(34)+Alltrim(OL_MAIL.P_BODY)+Chr(34)
Else
	loMessage.cBody = Chr(34)+Alltrim(OL_MAIL.P_HTMLBODY)+Chr(34)
Endif
* -- Preparo y envio
loPsServer.oMessages.Add(loMessage)
loPsServer.SendMessages()
