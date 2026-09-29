# Tasks

## 1. Separación del armazón

- [x] 1.1 Extraer a un componente de armazón el contenedor y el enlace de salto al contenido, de modo que el destino `#main` lo provea el propio armazón y no un componente que solo vive bajo la guardia, y verificar que existe exactamente un `#main` por pantalla
- [x] 1.2 Componer el armazón público (contenedor y salto, sin navegación) y verificar que no monta el componente de navegación
- [x] 1.3 Componer el armazón autenticado (contenedor, salto y navegación) y verificar que mantiene la navegación, la identidad del usuario y su cierre de sesión
- [x] 1.4 Montar la ruta de acceso bajo el armazón público y las rutas protegidas bajo el autenticado dentro de la guardia, y verificar que cada ruta se resuelve en su armazón

## 2. Pantalla de acceso

- [x] 2.1 Retirar de la pantalla de acceso cualquier anuncio o enlace a las secciones del portal y verificar que no aparece ningún enlace ni rótulo con Catálogo, Empleados o Buscador
- [x] 2.2 Añadir la identidad del portal a la pantalla de acceso (nombre del portal como encabezado, además del rótulo del formulario) y verificar visualmente que la pantalla se identifica sin ofrecer navegación
- [x] 2.3 Ajustar lo necesario para que la pantalla de acceso se vea centrada y con las medidas del contenedor, usando solo los tokens del contrato de diseño, y verificar que no se introduce ningún color, tamaño o espaciado fuera de tokens

## 3. Verificación

- [x] 3.1 Reconstruir el cliente y verificar que compila sin errores de tipos y que el build se emite
- [x] 3.2 Verificar en navegador real sin sesión: la pantalla de acceso no muestra la navegación ni el cierre de sesión, y el enlace de salto lleva el foco a un destino existente
- [x] 3.3 Verificar en navegador real con sesión: las cinco pantallas del portal siguen mostrando la navegación y la identidad, y el enlace de salto sigue funcionando en cada una
- [x] 3.4 Ampliar el arnés de extremo a extremo con esta distinción (sin sesión no hay navegación; con sesión sí) y verificar que todas las comprobaciones del arnés pasan, incluidas las de acceso, guardia y flujos funcionales existentes
- [x] 3.5 Verificar que el cambio no altera comportamiento: ejecutar la suite de backend y confirmar que sigue pasando sin cambios, y que el acceso y el cierre de sesión funcionan igual que antes
