# StandStock

**Sistema Integral de Gestión de Inventarios en Tiempo Real para Stands de Centros Comerciales**

---

## Descripción del Proyecto

StandStock es un sistema diseñado para resolver problemas de control de inventario en el retail de micro-formato, específicamente en stands ubicados dentro de centros comerciales.

La solución permite a vendedores y administradores gestionar el stock en tiempo real mediante una aplicación móvil, registrando movimientos de entrada y salida, generando alertas de stock bajo y facilitando la operación diaria en entornos de alto tráfico.

---

## Contexto Académico

Este proyecto corresponde al **Portafolio de Título** de la carrera de **Analista Programador Computacional**.

- **Autor:** Juan Ignacio Redondo González
- **Institución:** Duoc UC
- **Fecha de desarrollo:** Abril – Junio 2026
- **Estado:** Fase 2 avanzada / Fase 3 (entrega final)

---

## Problema y Justificación

Los stands de venta en malls enfrentan frecuentemente quiebres de stock, errores en el registro manual de ventas y falta de visibilidad del inventario en tiempo real. Estas problemáticas generan pérdidas económicas y una experiencia deficiente tanto para vendedores como para clientes.

StandStock busca entregar una herramienta práctica que permita un control preciso del inventario, reduciendo errores operativos y mejorando la toma de decisiones.

---

## Estado Actual del Proyecto

El desarrollo del prototipo funcional se encuentra en una etapa avanzada. La aplicación móvil cuenta con las siguientes capacidades implementadas:

- Autenticación y control de acceso por roles (Vendedor y Administrador)
- Dashboard de vendedor con indicadores clave (stock total, stock bajo y ventas del día)
- Escaneo de códigos de barras y búsqueda manual de productos
- Registro de movimientos de stock (entradas y salidas)
- Gestión completa de productos, stands y usuarios desde el perfil administrador
- Alertas de stock bajo
- Reportes y estadísticas por stand

El desarrollo activo y el código fuente actual del prototipo se mantienen en un repositorio privado debido a acuerdos de confidencialidad con el cliente. Este repositorio público contiene la documentación, el historial de avance y las evidencias del proyecto de título.

---

## Evolución Tecnológica

Inicialmente, el proyecto fue diseñado utilizando **Supabase** (PostgreSQL + Row Level Security) como backend. Durante el desarrollo, se tomó la decisión de migrar completamente a **Firebase** (Authentication + Firestore), con el objetivo de simplificar la arquitectura, mejorar la velocidad de desarrollo y facilitar la escalabilidad del sistema en esta etapa del proyecto.

Esta migración fue documentada como parte de las decisiones técnicas del proyecto.

---

## Arquitectura y Tecnologías

- **Frontend Móvil:** Flutter 3.11+ (Dart)
- **Backend y Base de Datos:** Firebase (Authentication + Cloud Firestore)
- **Escaneo de códigos:** mobile_scanner
- **Estilo:** Diseño dark mode consistente

**Colecciones principales en Firestore:**
- `stands`
- `usuarios`
- `productos`
- `movimientos_stock`

El sistema sigue un modelo multi-tenant, donde cada producto y movimiento está asociado a un stand específico, permitiendo un control granular por ubicación.

---

## Funcionalidades Principales

### Rol Vendedor
- Inicio de sesión y visualización de su stand asignado
- Dashboard con KPIs en tiempo real
- Escaneo de productos mediante código de barras
- Búsqueda manual de productos
- Registro de ventas (salidas) y reposiciones (entradas)
- Visualización de alertas de stock bajo

### Rol Administrador
- Gestión de stands (crear, editar, activar/desactivar)
- Gestión de productos por stand
- Administración de usuarios y asignación de stands
- Supervisión de inventario
- Reportes y estadísticas por stand

---

## Próximos Pasos (Fase 3)

Para la fase final del proyecto se contempla:

- Estabilización y pulido del prototipo móvil actual
- Desarrollo de un panel de administración web (planificado en React)
- Pruebas de usabilidad con usuarios reales
- Documentación técnica y memoria del proyecto de título

---

## Autor

**Juan Ignacio Redondo González**
Analista Programador Computacional
Duoc UC – 2026

Proyecto de Portafolio de Título