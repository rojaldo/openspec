# Design

## Context

Ver `proposal.md` para la motivación. Estado que condiciona el diseño:

- `web/src/App.tsx` compone un único `Shell` que renderiza `<Nav />` y `<Routes>` como hermanos. El `Nav` se monta siempre, así que aparece también en `/login`.
- El destino del salto al contenido (`id="main"`) lo provee `RouteOutlet`, que **solo existe dentro de `RequireAuth`**. En `/login` no hay `#main`, de modo que el enlace "Saltar al contenido" que se renderiza en el `Shell` apunta a un destino inexistente.
- `Nav` ya distingue el estado de sesión para la identidad y el cierre de sesión (`user ? ... : null`), pero los cuatro enlaces se renderizan sin condición.
- `LoginPage` ya se centra a sí misma con `.login` y `.login__card`, y muestra el título "Acceso al portal".
- El contrato de diseño (`web/DESIGN.md`) gobierna las primitivas; `.nav` es una de ellas y no cambia su definición, solo dónde se monta.
- Los changes anteriores están completos pero sin archivar, así que la spec durable de `portal-ui` aún no existe: este delta se escribe como adición.

## Goals / Non-Goals

**Goals:**

- Que la pantalla de acceso no ofrezca navegación a contenido protegido.
- Que el cromo se derive del estado de sesión, no de la ruta concreta (así una ruta pública futura no hereda el cromo interno).
- Que el salto al contenido tenga destino en todas las pantallas donde se ofrece.

**Non-Goals:**

- Cambiar el aspecto del formulario de acceso más allá de su contenedor y su identidad.
- Añadir logotipo, imágenes o una página pública de inicio.
- Tocar la sesión, la guardia de rutas, la API o la capa de datos.
- Introducir un concepto de "layout por ruta" con configuración declarativa: la separación en dos armazones es suficiente.

## Decisions

### 1. Dos armazones: uno público y uno autenticado

Se separa el `Shell` único en dos composiciones. El armazón **público** contiene el salto al contenido y el contenedor, pero **no** el `Nav`; el armazón **autenticado** contiene el salto, el contenedor y el `Nav`. La ruta de acceso se monta bajo el público y las rutas protegidas bajo el autenticado.

*Alternativa:* condicionar el `Nav` a la existencia de sesión dentro de un único armazón (`user ? <Nav/> : null`). Se descarta porque ata el cromo a un detalle de sesión en lugar de a la naturaleza de la pantalla: una ruta pública futura (registro, recuperación) heredaría el contenedor interno y habría que volver a condicionar. La separación por armazón deja la regla en la estructura.

*Alternativa:* mover el `Nav` dentro de `RequireAuth`. Se descarta como ubicación: `RequireAuth` responde a "¿puedo pasar?", no a "¿qué cromo me toca?", y mezclar ambas responsabilidades complica el guardia.

### 2. El armazón público conserva contenedor y salto

El armazón público mantiene el `skip-link` y el contenedor `.app-shell` para que la pantalla de acceso no cambie de medidas ni pierda accesibilidad; lo único que se retira es la navegación.

*Alternativa:* dejar la pantalla de acceso sin armazón. Se descarta: perdería el contenedor con medidas y el salto al contenido, y la pantalla quedaría con un tratamiento distinto al del resto sin motivo.

### 3. El destino del salto existe en ambos armazones

El `id="main"` pasa a proveerlo cada armazón, no un componente que solo vive bajo el guardia. Así el enlace y su destino siempre coexisten: donde se ofrece el salto, existe `#main`.

*Alternativa:* retirar el salto en la pantalla pública. Se descarta porque el formulario de acceso es contenido al que también conviene poder saltar con teclado, y la regla del contrato de diseño es que la accesibilidad no se negocia por pantalla.

*Alternativa:* duplicar el salto dentro de cada pantalla. Se descarta: repetiría el enlace en cada página en lugar de dejarlo en el armazón, que es donde corresponde.

### 4. La identidad del portal no depende de la sesión

La pantalla de acceso conserva el nombre del portal como encabezado. Retirar la navegación no significa dejar la pantalla anónima: un visitante debe saber en qué portal está entrando.

*Alternativa:* dejar la pantalla sin ningún rótulo del portal. Se descarta por lo mismo: la identidad no es navegación y no presupone sesión.

### 5. Foco por cambio de ruta se mantiene

El armazón que envuelve las rutas conserva el comportamiento de llevar el foco al contenido al cambiar de ruta, que es parte de lo ya especificado en `portal-ui`. La separación no debe perderlo en ninguna de las dos ramas.

## Risks / Trade-offs

- **[Duplicar el salto y el contenedor entre los dos armazones]** → Se factoriza en un componente común y cada armazón decide si añade el `Nav`; así el contenedor y el salto se declaran una sola vez.
- **[El foco programático puede perderse al dividir el armazón]** → Se verifica en navegador real que al cambiar de ruta el foco sigue yendo al contenido en ambas ramas.
- **[La pantalla de acceso puede quedar visualmente escasa sin el menú]** → Conserva contenedor, tarjeta y encabezado con el nombre del portal; se verifica visualmente antes y después.
- **[Cambio de presentación con el contrato de diseño en juego]** → Solo se mueven composiciones, no se introducen colores, tamaños ni espaciados fuera de los tokens; la verificación comprueba que el acceso sigue usando las primitivas del contrato.

## Migration Plan

1. Extraer el contenedor y el salto a un componente de armazón reutilizable.
2. Componer el armazón público (sin navegación) y el autenticado (con navegación).
3. Montar la ruta de acceso en el público y las protegidas en el autenticado.
4. Verificar en navegador real: sin sesión no hay menú ni `#main` roto; con sesión todo sigue igual.
5. Reconstruir el cliente y ejecutar el arnés de extremo a extremo.

*Rollback:* es un cambio de composición en un solo archivo y sus componentes; revertirlo restaura el armazón único sin afectar datos ni API.

## Open Questions

- Si la pantalla de acceso debe usar un contenedor de ancho distinto al del portal: se decide en implementación midiendo la pantalla; no altera el contrato ni las tareas.
