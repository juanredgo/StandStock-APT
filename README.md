# StandStock

**Sistema Integral de Gestión de Inventarios y Ventas en Tiempo Real para Stands de Puntos de Venta (Micro-Retail)**

---

## 📖 Descripción del Proyecto

StandStock es una solución multiplataforma diseñada para resolver los desafíos de control de inventario y arqueo de caja en el retail de micro-formato, específicamente en stands o islas ubicadas dentro de centros comerciales.

El sistema permite a vendedores y administradores gestionar el stock de forma reactiva en tiempo real mediante una aplicación móvil, registrando movimientos de entrada y salida, generando alertas de stock bajo y facilitando la conciliación de caja al cierre de turno. Asimismo, cuenta con un panel web centralizado para la administración y supervisión global del negocio.

---

## 🎓 Contexto Académico

Este proyecto corresponde al **Portafolio de Título (APT)** de la carrera de **Analista Programador Computacional**.

*   **Autor:** Juan Ignacio Redondo González
*   **Institución:** Duoc UC
*   **Fecha de desarrollo:** Abril – Junio 2026
*   **Estado:** **Fase 2 Completada con Éxito** / Preparación de Fase 3 (Cierre Final)

---

## 🚀 Logros y Entregables de la Fase 2

Durante la Fase 2, el proyecto experimentó una consolidación técnica y funcional muy importante, logrando los siguientes hitos:

1.  **Migración Arquitectónica Reactiva:** Migración completa del backend desde Supabase hacia **Firebase (Cloud Firestore + Authentication)**, logrando una sincronización de datos en tiempo real extremadamente veloz y menor latencia en dispositivos móviles.
2.  **Seguridad y Control de Acceso (RBAC):** Implementación de un modelo robusto de control de accesos basado en roles (`vendedor`, `administrador`, `super_administrador`) con pantallas y vistas protegidas tanto en móvil como en web.
3.  **Módulo de Cierre de Caja Auditado:** Desarrollo de la pantalla de Cierre de Caja en la app móvil. Permite el arqueo de efectivo, tarjeta y transferencia, calculando diferencias de forma automática frente a los registros del sistema. Además, genera y exporta reportes de cuadre locales en formato **CSV**.
4.  **Consistencia Estética y UX:** Implementación de soporte persistente de temas Claro/Oscuro mediante SharedPreferences y optimización de layouts para evitar desbordamientos (*overflows*) en el dispositivo físico de pruebas (Nubia Neo 3).
5.  **Panel de Administración Web Inicializado y Desplegado:** Creación del panel administrativo en React (Vite + TypeScript + Zustand + Tailwind CSS + Shadcn/ui) integrado a Firestore en tiempo real y desplegado en **Firebase Hosting**:
    *   👉 **Acceso al Panel Web:** [https://standstockdb.web.app/](https://standstockdb.web.app/)
6.  **Distribución del Instalador Móvil:** Reubicación de la descarga del binario `.apk` hacia **GitHub Releases** para optimizar el almacenamiento de Firebase Hosting y evadir las restricciones de carga en el plan Spark.

---

## 🛠️ Arquitectura y Tecnologías

El sistema cuenta con una arquitectura moderna de 3 capas (Clientes Frontend, Nube/Backend Serverless y Distribución CDN):

*   **Frontend Móvil:** Flutter (Dart) + shared_preferences + mobile_scanner.
*   **Frontend Web:** React (Vite, TypeScript, Zustand, Tailwind CSS, Shadcn/ui, Recharts).
*   **Backend Serverless (BaaS):** Firebase (Authentication, Cloud Firestore, Storage, Hosting).
*   **Repositorio y Releases:** Git, GitHub y GitHub Releases (para distribución de binarios).

### Modelo de Datos en Firestore (NoSQL)
Los datos se organizan en las siguientes colecciones reactivas principales:
*   `usuarios`: Almacena el perfil del usuario, su email, fecha de creación, rol asignado (`vendedor` | `administrador` | `super_administrador`) y el identificador del stand donde opera.
*   `stands`: Define los puntos de venta físicos de la empresa (nombre, ubicación y estado activo/inactivo).
*   `productos`: Catálogo de artículos asociados a cada stand con su SKU, precio de venta, stock actual y stock mínimo para alertas.
*   `movimientos_stock`: Registro histórico de entradas (reposiciones) y salidas (ventas) con su cantidad, precio, método de pago e identificador de usuario.
*   `cierres_dia`: Documentos de auditoría de arqueo de caja generados diariamente por stand, con el desglose de montos del sistema versus montos contados físicamente y su respectiva diferencia.

---

## 👥 Roles y Funcionalidades del Sistema

### 1. Rol Vendedor (App Móvil)
*   Inicio de sesión seguro y validación de stand asignado.
*   Dashboard interactivo con KPIs en tiempo real (Stock Total, Alertas de Stock Bajo, Ventas del Día).
*   Búsqueda de productos rápida mediante lectura de código de barras (cámara) o buscador de texto.
*   Registro instantáneo de ventas (salidas de stock por efectivo, tarjeta o transferencia) y reposiciones (entradas).
*   Pantalla de **Cierre del Día** con cuadre de caja guiado y generación de reporte CSV local.

### 2. Rol Administrador (App Móvil / Panel Web)
*   Supervisión en tiempo real del stock de todos los stands a su cargo.
*   Gestión de catálogo de productos (CRUD de productos, SKU y asignación de precios).
*   Monitoreo continuo de movimientos de inventario e historial de cierres de caja.
*   Asignación y desasignación rápida de vendedores a stands.

### 3. Rol Super Administrador (Panel Web Principal)
*   Visualización de analíticas y KPIs consolidados a nivel global de la empresa.
*   Gestión del maestro de stands (creación, edición y suspensión de puntos de venta).
*   Administración total de cuentas de usuario y asignación de roles jerárquicos (RBAC).
*   Gráficos dinámicos de ventas comparativas por stands y días (vía Recharts).

---

## 📂 Estructura del Repositorio Académico

La carpeta raíz está organizada siguiendo los estándares de entrega del portafolio del título de Duoc UC:

*   📁 **Fase 1/**: Contiene el documento de definición del proyecto, levantamiento de requerimientos iniciales e historias de usuario.
*   📁 **Fase 2/**: Contiene todo el material correspondiente al desarrollo e incrementos de la segunda etapa:
    *   📁 **Evidencias Grupales/**: Documento formal del informe de avance (`PTY4478 APT2.0 FASE 2.docx`).
    *   📁 **Evidencias Individuales/**: Pauta de reflexión y autoevaluaciones del desarrollador.
    *   📁 **Evidencias Proyecto/**:
        *   📁 **Diagramas/**: Diagramas de ingeniería en alta resolución JPG y código fuente Mermaid (`Diagramas_StandStock.md`):
            1.  *Arquitectura del Sistema* (Capa física y nube).
            2.  *Base de Datos* (Esquema NoSQL).
            3.  *Casos de Uso* (Límites del sistema y RBAC).
            4.  *Secuencia de Cierre de Caja* (Procesamiento del arqueo).
        *   📊 **Defensa Fase 2 - StandStock.pptx**: Presentación de 10 minutos para la comisión con el guion completo del discurso incorporado en las notas del orador de cada diapositiva.
        *   🎥 **Evidencias Base de datos y colecciones.mp4**: Video demostrativo del funcionamiento.
        *   📄 Documentación técnica adicional de soporte.

---

## 👤 Autor

*   **Juan Ignacio Redondo González**
*   Analista Programador Computacional
*   Duoc UC – 2026