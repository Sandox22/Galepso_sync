LPARAMETERS tnHandle

IF TYPE("tnHandle") <> "N" OR tnHandle <= 0
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "[cxc_sincro_subida] ERROR: Handle ODBC inválido." + CHR(13)
    ENDIF
    RETURN .F.
ENDIF
