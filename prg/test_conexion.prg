* test_conexion.prg - Verificacion rapida de conectividad MySQL remota
LOCAL lnH, laErr(1)
lnH = SQLSTRINGCONNECT("Driver={MySQL ODBC 3.51 Driver};Server=159.195.66.171;Port=3459;Database=bdsistemas2;User=galexo_kw; Password=PGXz&161WW0d;Option=3")
IF lnH > 0
    MESSAGEBOX("CONEXION EXITOSA. Handle: " + LTRIM(STR(lnH)), 64, "Test MySQL")
    SQLDISCONNECT(lnH)
ELSE
    AERROR(laErr)
    MESSAGEBOX("ERROR: " + ALLTRIM(laErr[2]), 16, "Fallo ODBC")
ENDIF
