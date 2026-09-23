*------------------------------------------------------------------------------
* Funciones auxiliares para consumo de API REST desde VFP
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* Function ApiCall(lcUrl, lcMethod, lcBody)
*   Realiza peticion HTTP y devuelve el response body como string
*------------------------------------------------------------------------------
FUNCTION ApiCall(lcUrl, lcMethod, lcBody)
    LOCAL loHttp, lcResp
    loHttp = CreateObject("MSXML2.XMLHTTP")
    loHttp.Open(lcMethod, lcUrl, .F.)
    loHttp.SetRequestHeader("X-API-Key", "lp2024-a1b2c3d4e5f6")
    loHttp.SetRequestHeader("Content-Type", "application/json")
    IF !Empty(lcBody)
        loHttp.Send(lcBody)
    ELSE
        loHttp.Send()
    ENDIF
    lcResp = loHttp.ResponseText
    RETURN lcResp
ENDFUNC

*------------------------------------------------------------------------------
* Function ApiSuccess(lcResp)
*   Devuelve .T. si la respuesta contiene "success":true
*------------------------------------------------------------------------------
FUNCTION ApiSuccess(lcResp)
    RETURN At('"success":true', lcResp) > 0
ENDFUNC

*------------------------------------------------------------------------------
* Function ApiErrorMsg(lcResp)
*   Extrae mensaje de error del JSON
*------------------------------------------------------------------------------
FUNCTION ApiErrorMsg(lcResp)
    RETURN StRextract(lcResp, '"error":"', '"')
ENDFUNC

*------------------------------------------------------------------------------
* Function JsonArrayToCursor(lcJson, lcCursor)
*   Parsea un array JSON a un cursor VFP
*   Usa STREXTRACT para evitar problemas con comillas en los valores
*   Todos los campos se crean como C(254) para evitar errores de tipo
*   El PRG que llama debe convertir los valores al tipo VFP correcto
*------------------------------------------------------------------------------
FUNCTION JsonArrayToCursor(lcJson, lcCursor)
    LOCAL lnIni, lnFin, lcArray, laItems, lnItems, i
    LOCAL lcItem, lcCreate, lnOldArea, lcKey, lcVal
    LOCAL laKeys, lnKeys, j, k

    lnOldArea = SELECT()
    lnIni = At('[', lcJson)
    lnFin = Rat(']', lcJson)
    IF lnIni = 0 OR lnFin = 0
        SELECT (lnOldArea)
        RETURN 0
    ENDIF
    lcArray = SubStr(lcJson, lnIni + 1, lnFin - lnIni - 1)

    * Dividir por },{ para obtener cada objeto
    lcArray = StrTran(lcArray, '},{', '|;|')
    lnItems = Alines(laItems, lcArray, 4, '|;|')

    IF lnItems = 0
        SELECT (lnOldArea)
        RETURN 0
    ENDIF

    * Extraer claves del primer objeto usando STREXTRACT
    lcItem = laItems[1]
    DIMENSION laKeys[1]
    lnKeys = 0
    lcKey = StRextract(lcItem, '"', '"')
    DO WHILE !Empty(lcKey)
        lnKeys = lnKeys + 1
        DIMENSION laKeys[lnKeys]
        laKeys[lnKeys] = lcKey
        * Saltar al siguiente par key:value
        lcItem = SubStr(lcItem, At('"' + lcKey + '"', lcItem) + Len(lcKey) + 2)
        * Buscar la siguiente key
        lcKey = StRextract(lcItem, '"', '"')
    ENDDO

    * Crear cursor con todos los campos C(254)
    lcCreate = "CREATE CURSOR " + lcCursor + " ("
    FOR j = 1 TO lnKeys
        IF j > 1
            lcCreate = lcCreate + ", "
        ENDIF
        lcCreate = lcCreate + laKeys[j] + " C(254)"
    NEXT
    lcCreate = lcCreate + ")"
    &lcCreate

    * Insertar datos extrayendo cada valor con STREXTRACT
    FOR i = 1 TO lnItems
        lcItem = laItems[i]
        APPEND BLANK IN (lcCursor)
        SELECT (lcCursor)
        FOR j = 1 TO lnKeys
            * Extraer valor string entre comillas: "clave":"valor"
            lcVal = StRextract(lcItem, '"' + laKeys[j] + '":"', '"')
            * Si no se encontro, probar con valor numerico/bool: "clave":123
            IF Empty(lcVal)
                lcVal = StRextract(lcItem, '"' + laKeys[j] + '":', ',')
                * Si sigue vacio, probar hasta }
                IF Empty(lcVal)
                    lcVal = StRextract(lcItem, '"' + laKeys[j] + '":', '}')
                ENDIF
            ENDIF
            REPLACE (laKeys[j]) WITH lcVal
        NEXT
    NEXT
    GO TOP IN (lcCursor)
    SELECT (lnOldArea)
    RETURN lnItems
ENDFUNC

*------------------------------------------------------------------------------
* Function JsonVal(lcVal)
*   Convierte string JSON a valor numerico VFP (null → 0)
*------------------------------------------------------------------------------
FUNCTION JsonVal(lcVal)
    IF lcVal == "null" OR Empty(lcVal)
        RETURN 0
    ENDIF
    RETURN Val(lcVal)
ENDFUNC

*------------------------------------------------------------------------------
* Function JsonDate(lcVal)
*   Convierte fecha ISO "YYYY-MM-DD" a VFP Date (null → CTOD(""))
*------------------------------------------------------------------------------
FUNCTION JsonDate(lcVal)
    IF lcVal == "null" OR Empty(lcVal)
        RETURN CTOD("")
    ENDIF
    LOCAL lnY, lnM, lnD
    lnY = Val(Left(lcVal, 4))
    lnM = Val(SubStr(lcVal, 6, 2))
    lnD = Val(SubStr(lcVal, 9, 2))
    IF lnY > 0 AND lnM > 0 AND lnD > 0
        RETURN Date(lnY, lnM, lnD)
    ENDIF
    RETURN CTOD("")
ENDFUNC

*------------------------------------------------------------------------------
* Function JsonBool(lcVal)
*   Convierte "1","true",".T." a .T., cualquier otra cosa a .F.
*------------------------------------------------------------------------------
FUNCTION JsonBool(lcVal)
    lcVal = Upper(AllTrim(lcVal))
    RETURN lcVal == "1" OR lcVal == "TRUE" OR lcVal == ".T."
ENDFUNC

*------------------------------------------------------------------------------
* Function JsonStr(lcVal)
*   Convierte string JSON a VFP string (null → "")
*------------------------------------------------------------------------------
FUNCTION JsonStr(lcVal)
    IF lcVal == "null"
        RETURN ""
    ENDIF
    RETURN lcVal
ENDFUNC
