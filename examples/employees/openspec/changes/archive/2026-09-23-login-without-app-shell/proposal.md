# Proposal

## Why

La pantalla de acceso muestra el menú de navegación del portal —Inicio, Catálogo, Empleados, Buscador—, que solo tiene sentido una vez dentro. Un visitante sin sesión ve anunciadas cuatro secciones a las que todavía no puede entrar, y la pantalla de acceso parece la de alguien que ya está dentro. Además, el enlace de "saltar al contenido" que aparece en esa pantalla apunta a un destino que solo existe cuando hay sesión, así que está roto justo ahí.

## What Changes

- **La navegación deja de mostrarse sin sesión**: el menú del portal pasa a formar parte del cromo de la aplicación autenticada, no del contenedor común. En la pantalla de acceso no hay menú.
- **Se separa el armazón público del autenticado**: la pantalla de acceso deja de compartir contenedor con el resto del portal, de modo que el contenido público no hereda elementos de la aplicación interna.
- **El enlace de salto al contenido deja de estar roto sin sesión**: o bien el destino de contenido existe en toda pantalla, o bien el enlace solo se ofrece donde hay destino. Se elige una de las dos y se aplica de forma coherente.
- **La marca del portal sigue presente sin sesión**: retirar el menú no significa dejar la pantalla sin identidad; la pantalla de acceso conserva el nombre del portal, sin ofrecer navegación a secciones protegidas.
- **Sin cambios de comportamiento**: el acceso, la sesión, la guardia de rutas, la API y la capa de datos no se tocan. Es un cambio de composición de la interfaz.

## Capabilities

### New Capabilities
<!-- Ninguna: el comportamiento ya está cubierto por capacidades existentes. -->

### Modified Capabilities
<!-- Los requisitos viven en los deltas de changes anteriores que aún no se han archivado.
     El destino de este delta es la capacidad `portal-ui`, que este change extiende. -->
- `portal-ui`: se añade a la capacidad del contrato visual el comportamiento de la interfaz según haya sesión o no (qué cromo se ofrece en cada caso).

## Impact

- **Código afectado**: `web/src/App.tsx` (separación del armazón público y el autenticado), `web/src/components/Nav.tsx` (la navegación pasa a depender de un armazón autenticado), `web/src/pages/LoginPage.tsx` y `web/src/styles/app.css` (identidad y contenedor de la pantalla de acceso). Sin cambios en `app.py`, `db.py`, `auth.py` ni en la API.
- **Sin dependencias nuevas.**
- **Sin cambios de contrato observable** para la API: es un cambio de presentación en el cliente.
- **Riesgo**: separar el armazón puede duplicar contenedores o dejar el salto al contenido sin destino; se mitiga verificando ambas pantallas en navegador real.
- **Fuera de alcance**: añadir marca gráfica o logotipo, página pública de inicio, registro de usuarios, recuperación de contraseña, y cualquier cambio en el comportamiento de la sesión.
