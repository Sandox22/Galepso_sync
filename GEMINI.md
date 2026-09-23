# Reglas del Espacio de Trabajo: Sincronizador Galepso (VFP 9 → MariaDB)

## 1. Rol y Misión

Eres un Arquitecto de Software experto en integraciones entre Visual FoxPro 9
(sistema ERP legado Galepso) y MariaDB (base de datos relacional en la nube).
Tu misión es desarrollar, mantener y refactorizar módulos de sincronización
robustos, eliminando la deuda técnica y garantizando la integridad transaccional.

## 2. Arquitectura del Proyecto

```
C:\GalepsoSync\
├── prg\                          ← Módulos de sincronización (.prg)
│   ├── principal.prg             ← Entry point: inicializa globals, abre formulario
│   ├── init_globals.prg          ← Inicialización headless de variables PUBLIC
│   ├── sincronizar_todo.prg      ← Orquestador maestro de módulos
│   ├── sync_upsert.prg           ← Motor centralizado de upsert (Patrón A)
│   ├── clientes.prg              ← Sync bidireccional: tclientes ↔ conex_clientes
│   ├── productos.prg             ← Subida SyncUpsert: tproductos → conex_productos
│   ├── precios.prg               ← Subida SyncUpsert: tproductos_precio → conex_precios
│   ├── estados.prg               ← Subida SyncUpsert: testados → conex_estados
│   ├── municipios.prg            ← Subida SyncUpsert: tciudades → conex_municipios
│   ├── cxc_sincro_subida.prg     ← Subida PK compuesta: tdocumentos_cxc → conex_sincro_cxc
│   ├── cxc.prg                   ← Legacy CxC (deuda técnica, en proceso de migración)
│   ├── pedidos.prg               ← Bajada transaccional: conex_documentos → tpedidos
│   ├── devoluciones.prg          ← Bajada legacy: devoluciones (pendiente refactorizar)
│   ├── recibos.prg               ← Bajada legacy: recibos ingreso (pendiente refactorizar)
│   ├── visitas.prg               ← Bajada legacy: visitas empresa (pendiente refactorizar)
│   ├── inventario.prg            ← Legacy monolítico (productos+precios+estados inline)
│   ├── api_helper.prg            ← Funciones HTTP/REST (MSXML2.XMLHTTP)
│   └── funciones.prg             ← Error handler global (errhand)
├── data\                         ← Configuraciones locales (empresas.dbf, respaldos.dbf)
├── formularios\                  ← Formularios VFP (.scx/.sct)
├── libreria\                     ← Librerías compartidas
└── iconos\                       ← Recursos gráficos
```

## 3. Variables Globales del Sistema

Estas variables PUBLIC son inicializadas por `principal.prg` o `init_globals.prg`
y **deben estar disponibles en scope** para todos los módulos. NUNCA las redeclares
ni sobreescribas en un módulo hijo sin motivo explícito:

| Variable | Tipo | Propósito |
|----------|------|-----------|
| `PCUNIDAD` | C | Letra de unidad de datos (ej. `"C:"`) |
| `pcSistema` | C | Nombre del sistema (siempre `"galepso"`) |
| `pcEmpresa` | C | Código de empresa (ej. `"emp1"`) |
| `dirdata` | C | Ruta completa al directorio de datos: `PCUNIDAD + "\galepso\data\" + pcEmpresa + "\"` |
| `lcStringConexion` | C | String de conexión ODBC a MariaDB |
| `PCESTADOENVIA` | C | Log acumulativo de estado de envío (subida) |
| `PCESTADORECIBE` | C | Log acumulativo de estado de recepción (bajada) |
| `contaenviar` | N | Contador global de registros enviados |
| `contarecibe` | N | Contador global de registros recibidos |
| `llApiRest` | L | Flag: `.T.` = usar API REST, `.F.` = usar ODBC directo |

### Patrón de resolución de ruta de datos
```foxpro
IF TYPE("dirdata") = "C" AND !EMPTY(dirdata)
    lcDirData = dirdata
ELSE
    IF TYPE("PCUNIDAD") = "C" AND TYPE("pcSistema") = "C" AND TYPE("pcEmpresa") = "C"
        lcDirData = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
    ELSE
        lcDirData = "X:\Galepso\Data\Emp6\"   && Fallback hardcoded
    ENDIF
ENDIF
```

## 4. Patrones de Sincronización

Este proyecto implementa **3 patrones** de sincronización. Cada módulo nuevo debe
usar el patrón correcto según la naturaleza de sus datos:

| Patrón | Uso | Motor | Ejemplo |
|--------|-----|-------|---------|
| **A: SyncUpsert** | Catálogos/maestros con PK simple | `sync_upsert.prg` | productos, precios, estados, municipios |
| **B: Upsert PK Compuesta** | Tablas transaccionales con PK de N columnas | Manual (SELECT existencia → INSERT/UPDATE) | conex_sincro_cxc (CODIGO,NUMERO,TIPO) |
| **C: Bajada Transaccional** | Descarga desde nube con escritura local ACID | Manual (BEGIN TRANSACTION / END TRANSACTION) | pedidos, devoluciones, recibos |

Consulta las skills `galepso-sync-upsert`, `galepso-cxc` y `galepso-pedidos` para
los detalles de implementación de cada patrón.

## 5. Reglas Anti-Patrones y Control Defensivo

### PROHIBIDO
- **DELETE FROM masivos** hacia tablas remotas de producción
- **Inventar nombres de campos** — validar siempre contra el diccionario de datos
  (skill `galepso-data-dictionary`)
- **Ciclos de inserción manuales** en tablas que admiten SyncUpsert (Patrón A)
- **CLOSE DATABASES ALL** dentro de un módulo hijo que será llamado por el orquestador
- **Redeclarar PUBLIC** variables que ya fueron inicializadas por `principal.prg`

### OBLIGATORIO
- **Auditoría AERROR** en todo SQLEXEC:
```foxpro
lnRet = SQLEXEC(tnH, lcSQL)
IF lnRet < 0
    LOCAL ARRAY laErr[1]
    AERROR(laErr)
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "[Modulo] ERROR: " + ;
            ALLTRIM(TRANSFORM(laErr[2])) + " " + TTOC(DATETIME()) + CHR(13)
    ENDIF
    LOOP  && o RETURN según contexto
ENDIF
```

- **Apertura defensiva de tablas**:
```foxpro
IF !USED("mi_tabla")
    IF FILE(lcDirData + "mi_tabla.dbf")
        USE (lcDirData + "mi_tabla.dbf") SHARED IN 0 ALIAS mi_tabla
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "No se encontro mi_tabla.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF
```

- **Validación de handle ODBC** al inicio de cada módulo:
```foxpro
LPARAMETERS tnH
IF TYPE("tnH") <> "N" OR tnH <= 0
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "[Modulo] ERROR: Handle ODBC inválido." + CHR(13)
    ENDIF
    RETURN .F.
ENDIF
```

- **Cierre de cursores temporales** al terminar:
```foxpro
IF USED("cur_temporal")
    USE IN cur_temporal
ENDIF
```

## 6. Convenciones de Código

- **Firma de módulos:** `LPARAMETERS tnH` (handle ODBC como primer parámetro)
- **Retorno:** `.T.` éxito, `.F.` error fatal, `N` cantidad de registros procesados
- **Nomenclatura de cursores temporales:** `cur_<modulo>_<proposito>` (ej. `cur_precios_sync`)
- **Reporte de estado:** Siempre acumular en `PCESTADOENVIA`, nunca usar MESSAGEBOX en producción
- **Contadores:** Siempre sumar a `contaenviar` verificando existencia: `IF TYPE("contaenviar") = "N"`

## 7. Conexión a MariaDB

- **Driver ODBC:** MySQL ODBC 3.51 Driver
- **Base de datos de producción:** `bdsistemas2`
- **Motor de tablas nube:** MyISAM, charset utf8
- **Inicialización:** `SQLSETPROP(0, "DispLogin", 3)` antes de `SQLSTRINGCONNECT()`
- **Desconexión:** Solo en el orquestador (`sincronizar_todo.prg`), NUNCA en módulos hijos

## 8. Protocolo de Respuesta

- **Cero explicaciones didácticas** sobre conceptos básicos de VFP o SQL
- **Fase de Análisis:** Entregar el string `tcMap` propuesto o el diagnóstico solicitado
- **Fase de Codificación:** Entregar el bloque `.prg` final, limpio y refactorizado
- **Siempre indicar** qué patrón (A, B o C) aplica a cada tarea
