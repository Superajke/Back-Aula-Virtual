# Aula Virtual - Backend

Este es el backend del sistema **Aula Virtual**, una plataforma educativa que conecta estudiantes con tutores para sesiones de tutoría virtuales o presenciales, gestionadas por administradores. El sistema incluye funcionalidades como inscripción a sesiones, calificaciones, recursos educativos, mensajería interna, recompensas por gamificación y soporte técnico.

## 🧱 Tecnologías utilizadas

- **MySQL 8+** – Sistema de gestión de base de datos relacional
- **Workbench** – Modelado y gestión visual de la base de datos
- **Node.js + Express (opcional para backend)** – Para construir una API REST
- **Git** – Control de versiones

## 🧾 Estructura de la base de datos

El modelo sigue un diseño orientado a herencia con una tabla `Usuario` como supertipo y tres subtipos:

- `Estudiante`
- `Tutor`
- `Administrador`

Además, el sistema incluye tablas como:

- `Tutoria`, `Sesion`, `Materia`
- `InscripcionSesion`, `Calificacion`, `Mensaje`
- `RecursoEducativo`, `Recompensa`, `PuntosUsuario`
- `DisponibilidadTutor`, `SoporteTecnico`, `LogActividad`, `Notificacion`

### 🗃 Diagrama ER

Puedes visualizar el diagrama en **MySQL Workbench**:
1. Abre tu archivo `.mwb`
2. Ve a **Database > Reverse Engineer**
3. Selecciona tu conexión, escoge las tablas y finaliza para ver el modelo

---

## ⚙️ Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/Superajke/Back-Aula-Virtual.git
cd Back-Aula-Virtual
```

### 2. Configurar entorno

Crea un archivo `.env` en la raíz con las variables necesarias:

```env
DB_HOST=localhost
DB_USER=tu_usuario
DB_PASSWORD=tu_contraseña
DB_NAME=aula_virtual
PORT=3000
```

### 3. Instalar dependencias (si hay backend en Node)

```bash
npm install
```

### 4. Crear base de datos

Importa el script `aula_virtual.sql` en tu Workbench o por consola:

```bash
mysql -u tu_usuario -p aula_virtual < database/aula_virtual.sql
```

---

## 🚀 Uso

Si usas backend en Node.js:

```bash
npm run dev
```

Accede a la API en: `http://localhost:3000`

---

## 🧪 Ejemplo de usuario de prueba

```sql
INSERT INTO Usuario (email, password, nombre, apellido, tipo)
VALUES ('test@student.com', 'hashedpassword', 'Test', 'Student', 'estudiante');

SET @usuario_id = LAST_INSERT_ID();

INSERT INTO Estudiante (usuario_id, universidad, carrera)
VALUES (@usuario_id, 'Universidad de Prueba', 'Ingeniería de Software');
```

---

## 📁 Estructura de carpetas (si es un proyecto completo)

```
Back-Aula-Virtual/
│
├── database/
│   └── aula_virtual.sql
│
├── controllers/
├── models/
├── routes/
├── .env
├── .gitignore
├── package.json
└── README.md
```

---

## 👨‍💻 Contribución

¡Pull requests son bienvenidas! Por favor abre un issue antes de hacer cambios importantes.

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT.