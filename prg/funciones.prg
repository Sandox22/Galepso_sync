Procedure errhand
	Parameter m.machine, m.messgnum, m.messg, m.linecode, ;
		m.callprog, m.inline, m.OPENTABL, m.errdate, ;
		m.errtime
	m.errspace=Select()      && Store current work area.
	m.errorder=Order()       && Store current order.
	If Len(Alltrim(m.callprog))=0
		m.callprog="Command Line"
		Store Space(0) To m.linecode
	Endif
	outmsgline="Error ; "+m.messg+Chr(13)+"Line "+Str(m.inline)+ ;
		CHR(13)+ ;
		"program name = "+m.callprog+Chr(13)+"Syntax is  :"+m.linecode
	* Visual FoxPro users use =MESSAGEBOX(outmsgline,32+0)
	* MAC uUse the FXALERT() Function in Foxtools.mlb
	* FoxPro For Windows users use the MsgBox() Function in Foxtools.fll
	Wait Window outmsgline Timeout 5 && All versions can use this syntax.
	If !Used("ERRORLOG")
		If File("ERRORLOG.DBF")
			Select 0
			Use errorlog
		Else
			Select 0
			thisversion=Version()
			If Left(Alltrim(thisversion),6)="Visual"
				* Create Free table for Visual FoxPro Versions
				Create Table errorlog Free (machine c(20), messgnum N(4,0), ;
					messg c(70), linecode c(70), callprog c(40), ;
					inline N(6,0), OpenTabl c(25), errdate d, errtime c(8))
			Else
				Create Table errorlog (machine c(20), messgnum N(4,0), ;
					messg c(70), linecode c(70), callprog c(40), ;
					inline N(6,0), OpenTabl c(25), errdate d, errtime c(8))
			Endif
		Endif
	Endif
	Insert Into errorlog From Memvar
	Select errorlog                  && Select errorlog table.
	Use                              && Close errorlog table.
	Select (m.errspace)              && Return to stored work area.
	If !Empty(Alias())
		Set Order To (m.errorder)
	Endif
	Release All Like m.messgnum, m.messg, m.linecode, m.callprog, ;
		m.inline
	Return
ENDPROC
