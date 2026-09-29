# Spec Delta

## ADDED Requirements

### Requirement: El cromo de la interfaz depende de la sesión

El sistema SHALL ofrecer un cromo distinto según haya sesión o no. Sin sesión, la interfaz SHALL NOT mostrar la navegación a las secciones del portal ni ningún control que presuponga un usuario autenticado. Con sesión, la interfaz SHALL mostrar la navegación a las secciones y la identidad del usuario con su cierre de sesión.

#### Scenario: Sin sesión no se ofrece navegación

- **WHEN** un visitante sin sesión abre la pantalla de acceso
- **THEN** la interfaz no muestra enlaces a las secciones del portal ni el control de cierre de sesión

#### Scenario: Con sesión se ofrece el cromo completo

- **WHEN** un usuario con sesión activa abre cualquier pantalla del portal
- **THEN** la interfaz muestra la navegación a las secciones y la identidad del usuario con su cierre de sesión

#### Scenario: El cromo cambia al iniciar y cerrar sesión

- **WHEN** un usuario inicia sesión desde la pantalla de acceso
- **THEN** la navegación pasa a estar disponible, y deja de estarlo cuando cierra la sesión

### Requirement: La pantalla de acceso no anuncia contenido protegido

La pantalla de acceso SHALL presentarse como una pantalla pública: SHALL NOT enumerar ni enlazar las secciones reservadas a la sesión, y SHALL exponer únicamente lo necesario para acreditarse. La pantalla SHALL mantener la identidad del portal (al menos su nombre) sin ofrecer navegación a contenido protegido.

#### Scenario: La pantalla de acceso no enumera secciones

- **WHEN** se inspecciona la pantalla de acceso sin sesión
- **THEN** no aparece ningún enlace ni rótulo que anuncie las secciones Catálogo, Empleados o Buscador

#### Scenario: La pantalla de acceso conserva la identidad

- **WHEN** un visitante abre la pantalla de acceso
- **THEN** la pantalla identifica el portal por su nombre y ofrece los campos de acceso

### Requirement: El salto al contenido tiene destino en toda pantalla

El sistema SHALL ofrecer un enlace de salto al contenido cuyo destino exista en todas las pantallas donde el enlace se presenta. El destino SHALL ser el contenido principal de la pantalla, con independencia de que haya sesión o no.

#### Scenario: El salto funciona sin sesión

- **WHEN** un visitante sin sesión activa el enlace de salto al contenido
- **THEN** el foco se desplaza al contenido principal de la pantalla de acceso, que existe

#### Scenario: El salto funciona con sesión

- **WHEN** un usuario con sesión activa el enlace de salto al contenido
- **THEN** el foco se desplaza al contenido principal de la pantalla que está viendo

#### Scenario: El enlace no se ofrece sin destino

- **WHEN** una pantalla no dispone de contenido principal al que saltar
- **THEN** el sistema no presenta ese enlace en esa pantalla
