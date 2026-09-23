import customtkinter as ctk
import ctypes
import ctypes.wintypes
import json
import os
import threading
import time
import subprocess
import tkinter.messagebox as messagebox

ctk.set_appearance_mode("System")
ctk.set_default_color_theme("blue")

CONFIG_FILE = "config.json"
LOG_FILE = "log.txt"

class GalepsoSyncApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("Sincronizador de Datos Galepso")
        self.geometry("620x380")
        self.minsize(600, 360)

        # Ruta absoluta al icono (relativa al directorio del script)
        _base_dir = os.path.dirname(os.path.abspath(__file__))
        self.icono_path = os.path.join(_base_dir, "iconos", "prueba-icono-2 - copia.ico")
        self._aplicar_icono()

        # Variables de estado
        self.sincronizacion_activa = False
        self.sync_thread = None

        # Variables de configuración por defecto
        self.config_data = {
            "database": {
                "server": "",
                "user": "",
                "password": "",
                "database": "",
                "port": "3306"
            },
            "settings": {
                "save_credentials": True,
                "local_path": "X:\\Galepso\\Data\\Emp6\\",
                "id_enterprise": "1",
                "interval_min": "10"
            },
            "modules": {
                "clientes": True,
                "productos": True,
                "pedidos": False,
                "cxc": False,
                "vendedores": True
            }
        }

        # Inicialización
        self.crear_interfaz()
        self.cargar_configuracion()
        
        # Interceptar el cierre de la ventana
        self.protocol("WM_DELETE_WINDOW", self.al_cerrar)

    def crear_interfaz(self):
        """Estructura la interfaz gráfica principal."""
        # Frame principal para contener pestañas y controles
        self.main_frame = ctk.CTkFrame(self)
        self.main_frame.pack(fill="both", expand=True, padx=10, pady=10)

        # --- 1. Diseño por Pestañas (CTkTabview) ---
        self.tabview = ctk.CTkTabview(self.main_frame)
        self.tabview.pack(fill="both", expand=True, padx=10, pady=(10, 0))

        self.tab_conexion = self.tabview.add("Conexión Remota")
        self.tab_empresas = self.tabview.add("Empresas y Rutas")
        self.tab_parametros = self.tabview.add("Parámetros")
        self.tab_eventos = self.tabview.add("Eventos (Log)")

        self.construir_tab_conexion()
        self.construir_tab_empresas()
        self.construir_tab_parametros()
        self.construir_tab_eventos()

        # --- 2. Controles Globales (Pie de ventana) ---
        self.footer_frame = ctk.CTkFrame(self)
        self.footer_frame.pack(side="bottom", fill="x", padx=10, pady=(0, 10))

        # Indicador visual de estado
        self.lbl_estado = ctk.CTkLabel(
            self.footer_frame, 
            text="Estado: Pausado", 
            text_color="red", 
            font=ctk.CTkFont(weight="bold")
        )
        self.lbl_estado.pack(side="left", padx=(20, 0), pady=10)

        # Botones globales
        self.btn_salir = ctk.CTkButton(
            self.footer_frame, 
            text="Salir", 
            command=self.al_cerrar, 
            width=90,
            height=36
        )
        self.btn_salir.pack(side="right", padx=(5, 15), pady=10)

        self.btn_sync_ahora = ctk.CTkButton(
            self.footer_frame, 
            text="Sincronizar Ahora", 
            command=self.sincronizar_ahora, 
            width=130,
            height=36
        )
        self.btn_sync_ahora.pack(side="right", padx=5, pady=10)

        self.btn_iniciar_auto = ctk.CTkButton(
            self.footer_frame, 
            text="Iniciar Automático", 
            command=self.toggle_auto_sync, 
            width=130,
            height=36
        )
        self.btn_iniciar_auto.pack(side="right", padx=5, pady=10)
        
        # Guardar colores originales
        self._btn_iniciar_fg_color = self.btn_iniciar_auto.cget("fg_color")
        self._btn_iniciar_hover_color = self.btn_iniciar_auto.cget("hover_color")

    # --- Construcción de Pestañas ---

    def construir_tab_conexion(self):
        """
        Pestaña Conexión Remota — Todos los controles viven dentro de un
        CTkFrame centrado (vertical y horizontalmente) para eliminar el
        espacio muerto cuando el TabView es alto por otras pestañas.

        Layout interno del frame_conexion: grid de 6 columnas proporcionales:
          col 0 = label izq  (fijo)   col 1 = campo izq (weight=3)
          col 2 = separador  (8px)    col 3 = label der (fijo)
          col 4 = campo der  (weight=3, mismo ancho que col 1)
          col 5 = campo fijo Puerto / botón ojo
        """
        # ── Centrar la tarjeta contenedora dentro de la pestaña ──────────────────
        # Pesos en filas y columnas de la pestaña madre → la tarjeta flota al centro
        self.tab_conexion.grid_rowconfigure(0, weight=1)
        self.tab_conexion.grid_rowconfigure(2, weight=1)
        self.tab_conexion.grid_columnconfigure(0, weight=1)
        self.tab_conexion.grid_columnconfigure(2, weight=1)

        # Frame-tarjeta centrado
        self.frame_conexion = ctk.CTkFrame(
            self.tab_conexion,
            fg_color=("#F2F2F2", "#2D2D2D"),
            corner_radius=12,
        )
        self.frame_conexion.grid(row=1, column=1, sticky="ew", padx=25, pady=25)

        # ── Sistema de 6 columnas con pesos simétricos dentro de la tarjeta ──────
        self.frame_conexion.grid_columnconfigure(0, weight=0, minsize=105)  # labels izq
        self.frame_conexion.grid_columnconfigure(1, weight=1)               # campo izq (server/user/db)
        self.frame_conexion.grid_columnconfigure(2, weight=0, minsize=8)    # separador visual
        self.frame_conexion.grid_columnconfigure(3, weight=0, minsize=90)   # labels der
        self.frame_conexion.grid_columnconfigure(4, weight=1)               # campo der (password)
        self.frame_conexion.grid_columnconfigure(5, weight=0, minsize=40)   # campo corto (puerto/ojo)

        PX, PY = 8, 6  # padding horizontal y vertical compacto
        PADX_DER = 20  # margen derecho de seguridad para responsividad

        # ── Fila 0: Servidor / DSN  ·  Puerto ────────────────────────────────────
        ctk.CTkLabel(self.frame_conexion, text="Servidor / DSN:", anchor="e").grid(
            row=0, column=0, sticky="e", padx=(PX, 4), pady=PY)
        self.ent_server = ctk.CTkEntry(self.frame_conexion, placeholder_text="hostname o nombre DSN", width=100)
        self.ent_server.grid(row=0, column=1, sticky="ew", padx=(0, 4), pady=PY)

        ctk.CTkLabel(self.frame_conexion, text="Puerto:", anchor="e").grid(
            row=0, column=3, sticky="e", padx=(4, 4), pady=PY)
        self.ent_port = ctk.CTkEntry(self.frame_conexion, width=50)
        self.ent_port.grid(row=0, column=4, columnspan=2, sticky="w", padx=(0, PADX_DER), pady=PY)

        # ── Fila 1: Usuario  ·  Contraseña + botón ojo ───────────────────────────
        ctk.CTkLabel(self.frame_conexion, text="Usuario:", anchor="e").grid(
            row=1, column=0, sticky="e", padx=(PX, 4), pady=PY)
        self.ent_user = ctk.CTkEntry(self.frame_conexion, placeholder_text="usuario BD", width=100)
        self.ent_user.grid(row=1, column=1, sticky="ew", padx=(0, 4), pady=PY)

        ctk.CTkLabel(self.frame_conexion, text="Contraseña:", anchor="e").grid(
            row=1, column=3, sticky="e", padx=(4, 4), pady=PY)

        # Sub-frame: password entry + botón ojo alineados dentro del mismo peso
        frame_pwd = ctk.CTkFrame(self.frame_conexion, fg_color="transparent")
        frame_pwd.grid(row=1, column=4, columnspan=2, sticky="ew", padx=(0, PADX_DER), pady=PY)
        frame_pwd.grid_columnconfigure(0, weight=1)
        frame_pwd.grid_columnconfigure(1, weight=0)

        self.ent_password = ctk.CTkEntry(frame_pwd, show="*", width=100)
        self.ent_password.grid(row=0, column=0, sticky="ew")

        self._pwd_visible = False
        self.btn_toggle_pwd = ctk.CTkButton(
            frame_pwd, text="👁", width=32, height=28,
            fg_color="transparent", hover_color=("gray85", "gray30"),
            command=self._toggle_password_visibility
        )
        self.btn_toggle_pwd.grid(row=0, column=1, padx=(4, 0), sticky="e")

        # ── Fila 2: Base de Datos y Checkbox ─────────────
        ctk.CTkLabel(self.frame_conexion, text="Base de Datos:", anchor="e").grid(
            row=2, column=0, sticky="e", padx=(PX, 4), pady=PY)
        self.ent_db = ctk.CTkEntry(self.frame_conexion, placeholder_text="nombre de la base de datos", width=100)
        self.ent_db.grid(row=2, column=1, sticky="ew", padx=(0, 4), pady=PY)

        self.chk_save_creds_var = ctk.BooleanVar(value=True)
        self.chk_save_creds = ctk.CTkCheckBox(
            self.frame_conexion, text="Guardar Credenciales", variable=self.chk_save_creds_var)
        self.chk_save_creds.grid(row=2, column=4, columnspan=2, sticky="w", padx=(0, PADX_DER), pady=PY)

        # ── Fila 3: Botón + Badge ──────────────
        self.btn_probar_conexion = ctk.CTkButton(
            self.frame_conexion, text="Probar Conexión", command=self.probar_conexion, width=140)
        self.btn_probar_conexion.grid(row=3, column=1, sticky="w", padx=(0, 4), pady=(10, PY))

        # Badge de estado permanente
        self.lbl_conn_badge = ctk.CTkLabel(
            self.frame_conexion,
            text="● Sin verificar",
            text_color="#888888",
            font=ctk.CTkFont(size=13, weight="bold"),
            anchor="w"
        )
        self.lbl_conn_badge.grid(row=3, column=2, columnspan=4, sticky="w", padx=(8, PADX_DER), pady=(10, PY))

        # ── Callbacks de invalidación del badge ───────────────────────────────────
        for entry in (self.ent_server, self.ent_user, self.ent_password, self.ent_db, self.ent_port):
            entry.bind("<Key>", self._invalidar_badge_conexion)

    def _toggle_password_visibility(self):
        """Alterna la visibilidad de la contraseña y actualiza el texto del botón ojo."""
        self._pwd_visible = not self._pwd_visible
        self.ent_password.configure(show="" if self._pwd_visible else "*")
        self.btn_toggle_pwd.configure(text="🔒" if self._pwd_visible else "👁")

    def _invalidar_badge_conexion(self, _event=None):
        """Regresa el badge al estado 'Sin verificar' cuando el usuario edita un campo."""
        self.lbl_conn_badge.configure(text="● Sin verificar", text_color="#888888")

    def _set_badge_conectado(self, nombre_bd: str):
        """Pone el badge en estado Conectado (verde)."""
        label = f"● Conectado a {nombre_bd}" if nombre_bd else "● En línea"
        self.lbl_conn_badge.configure(text=label, text_color="#2CC985")

    def _set_badge_error(self):
        """Pone el badge en estado Error (rojo)."""
        self.lbl_conn_badge.configure(text="● Error de conexión", text_color="#E05656")

    def construir_tab_empresas(self):
        """Elementos de la pestaña de Empresas y Rutas"""
        self.tab_empresas.grid_columnconfigure(1, weight=1)
        
        ctk.CTkLabel(self.tab_empresas, text="Ruta Directorio Local (Data):").grid(row=0, column=0, padx=10, pady=20, sticky="e")
        
        frame_ruta = ctk.CTkFrame(self.tab_empresas, fg_color="transparent")
        frame_ruta.grid(row=0, column=1, padx=10, pady=20, sticky="ew")
        frame_ruta.grid_columnconfigure(0, weight=1)
        frame_ruta.grid_columnconfigure(1, weight=0)
        
        self.ent_local_path = ctk.CTkEntry(frame_ruta)
        self.ent_local_path.grid(row=0, column=0, sticky="ew")
        
        btn_examinar = ctk.CTkButton(frame_ruta, text="Examinar...", width=90, command=self.seleccionar_carpeta)
        btn_examinar.grid(row=0, column=1, padx=(5, 0), sticky="w")

        ctk.CTkLabel(self.tab_empresas, text="Código de Empresa (ID):").grid(row=1, column=0, padx=10, pady=10, sticky="e")
        self.ent_id_enterprise = ctk.CTkEntry(self.tab_empresas, width=100)
        self.ent_id_enterprise.grid(row=1, column=1, padx=10, pady=10, sticky="w")

    def seleccionar_carpeta(self):
        from tkinter import filedialog
        carpeta = filedialog.askdirectory(title="Seleccionar Carpeta de Datos")
        if carpeta:
            self.ent_local_path.delete(0, "end")
            self.ent_local_path.insert(0, carpeta)

    def construir_tab_parametros(self):
        """Elementos de la pestaña de Parámetros configurados con estructura de tarjeta"""
        
        # ── Centrar la tarjeta contenedora dentro de la pestaña ──────────────────
        self.tab_parametros.grid_rowconfigure(0, weight=1)
        self.tab_parametros.grid_rowconfigure(2, weight=1)
        self.tab_parametros.grid_columnconfigure(0, weight=1)
        self.tab_parametros.grid_columnconfigure(2, weight=1)

        # Frame-tarjeta centrado
        self.frame_params = ctk.CTkFrame(
            self.tab_parametros,
            fg_color=("#F2F2F2", "#2D2D2D"),
            corner_radius=12,
        )
        self.frame_params.grid(row=1, column=1, sticky="ew", padx=25, pady=(10, 10))
        self.frame_params.grid_columnconfigure(0, weight=1)
        
        # ── Sección de Módulos (Checkboxes) ──────────────────────────────────────
        self.frame_modulos = ctk.CTkFrame(self.frame_params, fg_color="transparent")
        self.frame_modulos.grid(row=0, column=0, padx=20, pady=(10, 5), sticky="ew")
        self.frame_modulos.grid_columnconfigure(0, weight=1)
        self.frame_modulos.grid_columnconfigure(1, weight=1)

        ctk.CTkLabel(
            self.frame_modulos, 
            text="Módulos a Sincronizar", 
            font=ctk.CTkFont(size=14, weight="bold")
        ).grid(row=0, column=0, columnspan=2, pady=(0, 10), sticky="w")

        self.var_chk_clientes = ctk.BooleanVar(value=True)
        self.chk_clientes = ctk.CTkCheckBox(self.frame_modulos, text="Clientes y Zonas", variable=self.var_chk_clientes)
        self.chk_clientes.grid(row=1, column=0, padx=(0, 15), pady=(0, 8), sticky="w")

        self.var_chk_productos = ctk.BooleanVar(value=True)
        self.chk_productos = ctk.CTkCheckBox(self.frame_modulos, text="Productos e Inventario", variable=self.var_chk_productos)
        self.chk_productos.grid(row=1, column=1, padx=(15, 0), pady=(0, 8), sticky="w")

        self.var_chk_pedidos = ctk.BooleanVar(value=False)
        self.chk_pedidos = ctk.CTkCheckBox(self.frame_modulos, text="Pedidos y Rutas", variable=self.var_chk_pedidos)
        self.chk_pedidos.grid(row=2, column=0, padx=(0, 15), pady=(0, 5), sticky="w")

        self.var_chk_cxc = ctk.BooleanVar(value=False)
        self.chk_cxc = ctk.CTkCheckBox(self.frame_modulos, text="Cuentas por Cobrar (CxC)", variable=self.var_chk_cxc)
        self.chk_cxc.grid(row=2, column=1, padx=(15, 0), pady=(0, 5), sticky="w")

        self.var_chk_vendedores = ctk.BooleanVar(value=True)
        self.chk_vendedores = ctk.CTkCheckBox(self.frame_modulos, text="Vendedores y Metas", variable=self.var_chk_vendedores)
        self.chk_vendedores.grid(row=3, column=0, columnspan=2, padx=(0, 15), pady=(0, 5), sticky="w")

        # Separador visual
        separador = ctk.CTkFrame(self.frame_params, height=2, fg_color=("gray85", "gray30"))
        separador.grid(row=1, column=0, sticky="ew", padx=20, pady=5)

        # ── Sección de Intervalo ─────────────────────────────────────────────────
        frame_intervalo = ctk.CTkFrame(self.frame_params, fg_color="transparent")
        frame_intervalo.grid(row=2, column=0, padx=20, pady=(5, 10), sticky="ew")
        
        ctk.CTkLabel(
            frame_intervalo, 
            text="Intervalo de Sincronización (Minutos):"
        ).pack(side="left", padx=(0, 10))
        
        self.ent_intervalo = ctk.CTkEntry(frame_intervalo, width=80)
        self.ent_intervalo.insert(0, "10")
        self.ent_intervalo.pack(side="left")

    def construir_tab_eventos(self):
        """Elementos de la pestaña de Eventos (Log)"""
        self.txt_log = ctk.CTkTextbox(
            self.tab_eventos, 
            state="disabled", 
            wrap="word",
            fg_color="#1E1E1E",
            text_color="#00FF66",
            font=("Consolas", 12)
        )
        self.txt_log.pack(fill="both", expand=True, padx=5, pady=5)

    # --- Tema Visual ---

    def _aplicar_icono(self):
        """Asigna el icono de la ventana. Silencia el error si el archivo no existe."""
        try:
            self.iconbitmap(self.icono_path)
        except Exception:
            pass  # El .ico es opcional; la app sigue funcionando sin él

    def _refrescar_icono_win32(self):
        """
        Re-envía WM_SETICON al HWND nativo SIN destruir el HICON existente.
        Esto preserva el icono en la barra de tareas después de que
        ctk.set_appearance_mode() llame internamente a DwmSetWindowAttribute
        y recree la barra de título, sin causar el parpadeo que produce
        una nueva llamada a self.iconbitmap().
        """
        try:
            WM_SETICON  = 0x0080
            ICON_SMALL  = 0          # Icono 16x16 (barra de tareas)
            ICON_BIG    = 1          # Icono 32x32 (Alt-Tab / cabecera)
            IMAGE_ICON  = 1
            LR_LOADFROMFILE = 0x0010
            LR_DEFAULTSIZE  = 0x0040

            hicon_big = ctypes.windll.user32.LoadImageW(
                None,
                self.icono_path,
                IMAGE_ICON,
                0, 0,
                LR_LOADFROMFILE | LR_DEFAULTSIZE
            )
            hicon_small = ctypes.windll.user32.LoadImageW(
                None,
                self.icono_path,
                IMAGE_ICON,
                16, 16,
                LR_LOADFROMFILE
            )

            hwnd = self.winfo_id()
            if hicon_big:
                ctypes.windll.user32.SendMessageW(hwnd, WM_SETICON, ICON_BIG,  hicon_big)
            if hicon_small:
                ctypes.windll.user32.SendMessageW(hwnd, WM_SETICON, ICON_SMALL, hicon_small)
        except Exception:
            pass  # No-op en entornos sin Win32 (Linux/macOS)

    # --- Lógica de la Aplicación ---

    def log_evento(self, mensaje):
        """Agrega un mensaje al Textbox de log de forma segura desde otros hilos (Thread-safe)."""
        def append_text():
            self.txt_log.configure(state="normal")
            hora_actual = time.strftime("%Y-%m-%d %H:%M:%S")
            self.txt_log.insert("end", f"[{hora_actual}] {mensaje}\n")
            self.txt_log.see("end")
            self.txt_log.configure(state="disabled")
        
        # after(0, ...) delega la actualización de la UI al hilo principal (mainloop)
        self.after(0, append_text)

    def generar_archivo_config(self):
        """Genera el archivo config.json con la estructura requerida."""
        self.config_data = {
            "database": {
                "server": self.ent_server.get(),
                "port": self.ent_port.get() or "3306",
                "user": self.ent_user.get(),
                "password": self.ent_password.get() if self.chk_save_creds_var.get() else "",
                "database": self.ent_db.get()
            },
            "settings": {
                "save_credentials": self.chk_save_creds_var.get(),
                "local_path": self.ent_local_path.get(),
                "id_enterprise": self.ent_id_enterprise.get(),
                "interval_min": self.ent_intervalo.get()
            },
            "modules": {
                "clientes": self.var_chk_clientes.get(),
                "productos": self.var_chk_productos.get(),
                "pedidos": self.var_chk_pedidos.get(),
                "cxc": self.var_chk_cxc.get(),
                "vendedores": self.var_chk_vendedores.get()
            }
        }
        
        try:
            with open(CONFIG_FILE, "w", encoding="utf-8") as f:
                json.dump(self.config_data, f, indent=4)
            self.log_evento("Archivo config.json generado correctamente para el motor de sincronización.")
        except Exception as e:
            self.log_evento(f"Error generando config.json: {e}")

    def guardar_configuracion(self):
        """Guarda los valores actuales de la interfaz en config.json"""
        self.generar_archivo_config()

    def cargar_configuracion(self):
        """Carga los valores de config.json en la interfaz al iniciar"""
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    
                    if not isinstance(data, dict):
                        data = {}
                        
                    # Soporte para la nueva estructura anidada o la vieja plana
                    if "database" in data:
                        self.config_data.update(data)
                    else:
                        self.config_data["database"]["server"] = data.get("server", "")
                        self.config_data["database"]["user"] = data.get("user", "")
                        self.config_data["database"]["password"] = data.get("password", "")
                        self.config_data["database"]["database"] = data.get("database", "")
                        self.config_data["database"]["port"] = data.get("port", "3306")
                        
                        self.config_data["settings"]["save_credentials"] = data.get("save_credentials", True)
                        self.config_data["settings"]["local_path"] = data.get("local_path", "")
                        self.config_data["settings"]["id_enterprise"] = data.get("id_enterprise", "1")
                        self.config_data["settings"]["interval_min"] = data.get("interval_min", "10")
                        
                self.log_evento("Configuración cargada correctamente.")
            except Exception as e:
                self.log_evento(f"Error cargando configuración: {e}")

        # Aplicar valores a los controles UI
        db_conf = self.config_data.get("database", {})
        if not isinstance(db_conf, dict):
            db_conf = {}
        self.ent_server.insert(0, str(db_conf.get("server", "")))
        self.ent_user.insert(0, str(db_conf.get("user", "")))
        self.ent_password.insert(0, str(db_conf.get("password", "")))
        self.ent_db.insert(0, str(db_conf.get("database", "")))
        self.ent_port.insert(0, str(db_conf.get("port", "3306")))
        
        settings = self.config_data.get("settings", {})
        if not isinstance(settings, dict):
            settings = {}
        self.chk_save_creds_var.set(bool(settings.get("save_credentials", True)))
        self.ent_local_path.insert(0, str(settings.get("local_path", "")))
        self.ent_id_enterprise.insert(0, str(settings.get("id_enterprise", "1")))
        self.ent_intervalo.delete(0, "end")
        self.ent_intervalo.insert(0, str(settings.get("interval_min", "10")))

        modules = self.config_data.get("modules", {})
        if not isinstance(modules, dict):
            modules = {}
        if hasattr(self, 'var_chk_clientes'):
            self.var_chk_clientes.set(bool(modules.get("clientes", True)))
            self.var_chk_productos.set(bool(modules.get("productos", True)))
            self.var_chk_pedidos.set(bool(modules.get("pedidos", False)))
            self.var_chk_cxc.set(bool(modules.get("cxc", False)))
            self.var_chk_vendedores.set(bool(modules.get("vendedores", True)))

    def probar_conexion(self):
        """Inicia la prueba de conexión en un hilo separado para no congelar la UI."""
        # Feedback visual inmediato
        self.btn_probar_conexion.configure(text="Probando...", state="disabled")
        self.lbl_conn_badge.configure(text="● Verificando...", text_color="#F0A500")
        self.log_evento("Iniciando prueba de conexión...")

        hilo = threading.Thread(target=self._ejecutar_prueba_conexion, daemon=True)
        hilo.start()

    def _ejecutar_prueba_conexion(self):
        """
        Hilo de trabajo: intenta abrir conexión ODBC/MySQL y reporta el resultado.

        Lógica de detección:
          - Si el campo Servidor NO contiene '.' ni ':' (ej. 'Galepso_Nube'),
            se trata como DSN ODBC → DSN={server};UID=...;PWD=...
          - En caso contrario, se arma un connection string con driver MySQL ODBC 3.51,
            SERVER, PORT, DATABASE, UID y PWD.
        Intenta con pyodbc; si no está instalado, cae a pymysql.
        """
        servidor  = self.ent_server.get().strip()
        usuario   = self.ent_user.get().strip()
        password  = self.ent_password.get()
        base_datos = self.ent_db.get().strip()
        puerto    = self.ent_port.get().strip() or "3306"

        conn = None
        try:
            # ── Determinar si es DSN o parámetros directos ──────────────────────
            es_dsn = servidor and ('.' not in servidor) and (':' not in servidor)

            try:
                import pyodbc  # noqa: F401  (importación local para detectar disponibilidad)

                if es_dsn:
                    conn_str = (
                        f"DSN={servidor};"
                        f"UID={usuario};"
                        f"PWD={password};"
                    )
                    if base_datos:
                        conn_str += f"DATABASE={base_datos};"
                else:
                    conn_str = (
                        f"DRIVER={{MySQL ODBC 3.51 Driver}};"
                        f"SERVER={servidor};"
                        f"PORT={puerto};"
                        f"DATABASE={base_datos};"
                        f"UID={usuario};"
                        f"PWD={password};"
                        f"OPTION=3;"
                    )

                conn = pyodbc.connect(conn_str, timeout=10)

            except ImportError:
                # pyodbc no disponible → intentar con pymysql
                import pymysql
                conn = pymysql.connect(
                    host=servidor,
                    port=int(puerto),
                    user=usuario,
                    password=password,
                    database=base_datos or None,
                    connect_timeout=10,
                )

            # ── Conexión exitosa — badge verde + log, sin diálogo modal ──────────
            self.log_evento(
                f"✔ Conexión exitosa — Servidor: '{servidor}' | BD: '{base_datos}'"
            )
            self.after(0, lambda bd=base_datos: self._set_badge_conectado(bd))

        except Exception as exc:
            # ── Error de conexión ────────────────────────────────────────────────
            detalle = str(exc).splitlines()[0]  # Primera línea del mensaje de error
            self.log_evento(f"✘ Error de conexión: {detalle}")
            self.after(0, self._set_badge_error)
            self.after(
                0,
                lambda d=detalle: messagebox.showerror(
                    "Error de Conexión",
                    f"No se pudo conectar al servidor.\n\n{d}",
                ),
            )

        finally:
            # ── Cerrar conexión si se abrió ──────────────────────────────────────
            if conn is not None:
                try:
                    conn.close()
                except Exception:
                    pass

            # ── Restaurar botón desde el hilo principal ──────────────────────────
            self.after(
                0,
                lambda: self.btn_probar_conexion.configure(
                    text="Probar Conexión", state="normal"
                ),
            )

    def al_cerrar(self):
        """Manejador del evento de cierre de ventana (X)"""
        if self.sincronizacion_activa:
            respuesta = messagebox.askyesno(
                "Sincronizador Activo", 
                "La sincronización automática está corriendo. ¿Desea salir y detenerla?"
            )
            if not respuesta:
                return
                
        self.sincronizacion_activa = False # Cambia flag para detener hilos en background
        self.guardar_configuracion()
        self.destroy()

    # --- Lógica de Hilos (Threading) y Ejecución Backend ---

    def set_estado_corriendo(self):
        """Actualiza la interfaz visual al estado Corriendo"""
        self.lbl_estado.configure(text="Estado: Ejecutando", text_color="#2CC985")
        self.btn_iniciar_auto.configure(text="Detener Automático", fg_color="#E05656", hover_color="#C0392B")
        self.btn_sync_ahora.configure(state="disabled")

    def set_estado_pausado(self):
        """Actualiza la interfaz visual al estado Pausado"""
        self.lbl_estado.configure(text="Estado: Pausado", text_color="red")
        self.btn_iniciar_auto.configure(
            text="Iniciar Automático", 
            fg_color=self._btn_iniciar_fg_color, 
            hover_color=self._btn_iniciar_hover_color
        )
        self.btn_sync_ahora.configure(state="normal")

    def toggle_auto_sync(self):
        """Alterna el inicio y detención del timer automático"""
        if not self.sincronizacion_activa:
            try:
                minutos = int(self.ent_intervalo.get())
                if minutos <= 0:
                    raise ValueError
            except ValueError:
                messagebox.showerror("Error", "El intervalo de sincronización debe ser un número entero mayor a 0.")
                return

            self.sincronizacion_activa = True
            self.set_estado_corriendo()
            
            self.generar_archivo_config()
            
            # Iniciar hilo de sincronización continua (daemon=True para que muera al cerrar la app)
            self.sync_thread = threading.Thread(target=self._bucle_sincronizacion, args=(minutos,), daemon=True)
            self.sync_thread.start()
        else:
            self.sincronizacion_activa = False
            self.set_estado_pausado()

    def sincronizar_ahora(self):
        """Dispara una sincronización manual sin congelar la UI."""
        self.btn_sync_ahora.configure(state="disabled")
        self.lbl_estado.configure(text="Estado: Sincronizando...", text_color="orange")

        self.generar_archivo_config()

        hilo = threading.Thread(target=self._hilo_sincronizacion, daemon=True)
        hilo.start()

    def _hilo_sincronizacion(self):
        """Hilo de trabajo para sincronización manual: invoca el backend VFP y reporta resultado."""
        hora_inicio = time.strftime("%Y-%m-%d %H:%M:%S")
        self.log_evento(f"▶ Iniciando sincronización manual...")
        self.ejecutar_backend_vfp()
        self.log_evento("✔ Proceso de sincronización finalizado.")

        # Restaurar estado UI en el hilo principal
        self.after(0, self.set_estado_pausado)

    def _bucle_sincronizacion(self, minutos):
        """Bucle infinito para el timer automático, ejecutado en un hilo separado."""
        segundos_totales = minutos * 60
        
        while self.sincronizacion_activa:
            # 1. Ejecutar la sincronización (reutiliza el método del botón manual)
            self.log_evento(f"▶ Iniciando ciclo automático (Intervalo: {minutos} min)...")
            self.ejecutar_backend_vfp() 
            self.log_evento("✔ Ciclo finalizado. Esperando próximo turno...")
            
            # 2. Espera interrumpible (revisando la bandera cada segundo)
            for _ in range(segundos_totales):
                if not self.sincronizacion_activa:
                    self.log_evento("⏹ Sincronización automática detenida.")
                    return # Sale del hilo si el usuario presionó "Detener"
                time.sleep(1)

    def ejecutar_backend_vfp(self):
        """
        Puente Backend — Arquitectura de Integración.
        Lanza el ejecutable de Visual FoxPro (o el .exe compilado) como subproceso
        y espera su finalización con process.wait() sin bloquear la UI (se corre en hilo).

        Ajustar 'comando' con la ruta real al intérprete VFP o al .exe compilado:
          - Intérprete: ["C:\\Archivos de programa\\Microsoft Visual FoxPro 9\\vfp9.exe",
                         "-c", "C:\\GalepsoSync\\prg\\principal.prg"]
          - EXE compilado: ["C:\\GalepsoSync\\galepso_sync.exe"]
        """
        ruta_base = os.path.dirname(os.path.abspath(__file__))
        comando_exe = os.path.join(ruta_base, "dist", "sincronizar.exe")
        
        if not os.path.exists(comando_exe):
            self.log_evento(
                f"⚠ No se encontró el ejecutable VFP en la ruta esperada:\n"
                f"{comando_exe}\n"
                f"Por favor, verifica que la compilación de FoxPro exista."
            )
            return

        comando = [comando_exe]

        self.log_evento(f">> Llamando al backend VFP: {comando_exe}")

        try:
            proceso = subprocess.Popen(
                comando,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                creationflags=subprocess.CREATE_NO_WINDOW  # Sin ventana negra de consola
            )

            # Bloquea ESTE hilo hasta que VFP termine; la UI sigue respondiendo
            proceso.wait()

            # Leer stderr si el proceso ya terminó
            stderr_bytes = proceso.stderr.read() if proceso.stderr else b""
            if stderr_bytes:
                self.log_evento(
                    f"Advertencia del proceso VFP: "
                    f"{stderr_bytes.decode('latin-1', errors='replace').strip()}"
                )

            # Leer el log.txt que VFP haya generado
            self.leer_log_backend()

        except FileNotFoundError:
            self.log_evento(
                f"⚠ No se encontró el ejecutable VFP. Ruta buscada:\n{comando_exe}"
            )
        except Exception as e:
            self.log_evento(f"Error crítico al invocar VFP: {e}")

    def leer_log_backend(self):
        """Lee el archivo log.txt generado por el backend VFP y lo vuelca en el Textbox."""
        if os.path.exists(LOG_FILE):
            try:
                with open(LOG_FILE, 'r', encoding='utf-8', errors='ignore') as f:
                    contenido = f.read().strip()
                    if contenido:
                        self.log_evento(f"--- LOG VFP ---\n{contenido}")
                
                # Opcional: Vaciar el archivo tras leerlo para no volver a imprimir lo mismo
                # open(LOG_FILE, 'w').close() 
            except Exception as e:
                self.log_evento(f"No se pudo leer {LOG_FILE}: {e}")


if __name__ == "__main__":
    # Indicar a Windows que esta es una app independiente para la barra de tareas
    try:
        import ctypes
        myappid = 'galepso.sincronizador.cxc.1'  # ID arbitrario para separar el proceso
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)
    except Exception:
        pass

    app = GalepsoSyncApp()
    app.mainloop()
