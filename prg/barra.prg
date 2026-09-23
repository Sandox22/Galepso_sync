*--------------------------------------
* Definición de la clase barra de progreso
*--------------------------------------
DEFINE CLASS ProgressBar AS FORM
  DOCREATE = .T.
  HEIGHT = 72
  WIDTH = 375
  BORDERSTYLE = 2
  TITLEBAR = 0
  WINDOWTYPE = 0
  AUTOCENTER = .T.
  NAME = "ProgressBar"
  AnchoAux = 0
  *--
  PROCEDURE INIT
    LPARAMETERS tcTitulo
    SYS(2002)
    THIS.CrearObjetos(tcTitulo)
    THIS.AnchoAux = THIS.CNT.CNT.WIDTH
    THIS.Actualizar(0)
  ENDPROC
  *--
  PROCEDURE DESTROY
    SYS(2002,1)
  ENDPROC
  *--
  PROCEDURE actualizar
    LPARAMETERS tnPorc
    tnPorc = MAX(MIN(tnPorc,100),0)
    THIS.CNT.CNT.WIDTH = THIS.AnchoAux * tnPorc /100
    STORE TRANSFORM(tnPorc,"999")+"%" TO ;
      THIS.CNT.lbl.CAPTION, ;
      THIS.CNT.CNT.lbl.CAPTION
      THIS.DRAW 
  ENDPROC
  *--
  PROCEDURE CrearObjetos
    LPARAMETERS tcTitulo
    THIS.ADDOBJECT("lblTitulo","label")
    WITH THIS.lblTitulo
      .FONTBOLD = .T.
      .ALIGNMENT = 2
      .CAPTION = IIF(EMPTY(tcTitulo),;
        "En progreso ...",tcTitulo)
      .LEFT = 0
      .TOP = 10
      .WIDTH = 375
      .VISIBLE = .T.
    ENDWITH
    THIS.ADDOBJECT("cnt","container")
    WITH THIS.CNT
      .TOP = 36
      .LEFT = 9
      .WIDTH = 360
      .HEIGHT = 26
      .SPECIALEFFECT = 1
      .BACKCOLOR = RGB(255,255,255)
      .VISIBLE = .T.
      .ADDOBJECT("lbl","label")
      WITH .lbl
        .FONTBOLD = .T.
        .ALIGNMENT = 2
        .BACKSTYLE = 0
        .CAPTION = "100%"
        .HEIGHT = 20
        .LEFT = 0
        .TOP = 6
        .WIDTH = 360
        .VISIBLE = .T.
      ENDWITH
      .ADDOBJECT("cnt","container")
      WITH .CNT
        .TOP = 2
        .LEFT = 2
        .WIDTH = 356
        .HEIGHT = 22
        .BORDERWIDTH = 0
        .BACKCOLOR = RGB(0,0,255)
        .ADDOBJECT("lbl","label")
        .VISIBLE = .T.
        WITH .lbl
          .FONTBOLD = .T.
          .ALIGNMENT = 2
          .BACKSTYLE = 0
          .CAPTION = "100%"
          .HEIGHT = 20
          .LEFT = 0
          .TOP = 4
          .WIDTH = 356
          .FORECOLOR = RGB(255,255,255)
          .VISIBLE = .T.
        ENDWITH
      ENDWITH
    ENDWITH
  ENDPROC
ENDDEFINE
*--------------------------------------