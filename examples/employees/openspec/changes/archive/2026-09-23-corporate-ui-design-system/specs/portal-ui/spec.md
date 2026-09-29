# Spec Delta

## Purpose

Define el contrato visual y de componentes del portal de empleados: los tokens de diseño, la jerarquía tipográfica, las primitivas con sus estados y los patrones de interacción que todas las pantallas deben cumplir de forma observable. Es la fuente de verdad frente a la que se verifica cualquier cambio de interfaz.

## ADDED Requirements

### Requirement: Contrato de diseño único

El proyecto SHALL declarar un contrato de diseño versionado en el repositorio (`web/DESIGN.md`) que nombre los tokens de color, tipografía, espaciado, forma, foco y movimiento, y las primitivas con sus estados. Todo valor visual de la interfaz SHALL derivar de un token del contrato; ningún componente SHALL declarar colores, tamaños o espaciados literales fuera de él.

#### Scenario: Un valor visual nuevo traza a un token

- **WHEN** se revisa cualquier declaración de estilo de la interfaz
- **THEN** su color, tamaño o espaciado corresponde a un token nombrado en el contrato de diseño

#### Scenario: El contrato precede a las primitivas

- **WHEN** se introduce una primitiva, estado o patrón de interacción nuevo
- **THEN** el token o la regla que lo gobierna existe ya en el contrato de diseño

### Requirement: Jerarquía tipográfica

La interfaz SHALL definir una escala tipográfica con al menos cinco niveles diferenciados (título de página, encabezado de sección, cuerpo, etiqueta y metadato), SHALL usar una sola familia para toda la interfaz, y SHALL limitar los pesos empleados. El nivel superior de la escala SHALL ser visualmente distinguible del cuerpo, no un incremento marginal.

#### Scenario: Título de página distinguible

- **WHEN** se compara el título de página con el texto de cuerpo
- **THEN** el título se distingue por tamaño y peso, no solo por posición

#### Scenario: Una sola familia

- **WHEN** se inspeccionan los estilos tipográficos de cualquier pantalla
- **THEN** todos usan la misma familia declarada en el contrato

### Requirement: Filas de listado interactivas

En los listados, la superficie interactiva SHALL ser la fila completa, no solo una etiqueta de texto. El texto del registro SHALL presentarse con el color de texto del contrato — no con el color de acento reservado a la acción — y la fila SHALL exponer una affordance explícita de navegación. La fila SHALL ofrecer estados de hover y foco visibles y SHALL ser activable por teclado.

#### Scenario: La fila entera navega

- **WHEN** el usuario activa cualquier punto de la fila de un registro
- **THEN** se abre el detalle de ese registro

#### Scenario: Activación por teclado

- **WHEN** la fila recibe el foco y el usuario pulsa Enter
- **THEN** se abre el detalle del registro

#### Scenario: El nombre no aparenta ser un enlace

- **WHEN** se inspecciona el estilo del texto del registro
- **THEN** usa el color de texto del contrato y no el color de acento

### Requirement: Controles de formulario dimensionados y alineados

Los controles SHALL dimensionarse según su contenido esperado — un campo de nombre corto no SHALL ocupar todo el ancho disponible, y un campo de dominio acotado SHALL ser más estrecho que uno abierto. Dentro de una fila de formulario, el botón de envío SHALL quedar alineado con la caja del control (mismos bordes superior e inferior) y SHALL compartir su altura. Los controles SHALL exponer estados de reposo, hover, foco, deshabilitado y error.

#### Scenario: Botón alineado con el control

- **WHEN** se mide un formulario con un campo y un botón de envío en la misma fila
- **THEN** los bordes superior e inferior del botón coinciden con los del control

#### Scenario: Ancho acorde al contenido

- **WHEN** un formulario pide un nombre corto frente a un campo abierto
- **THEN** el campo de nombre no ocupa el ancho del campo abierto

#### Scenario: Estado de error visible

- **WHEN** el servidor rechaza un valor de formulario
- **THEN** el control muestra un estado de error y el motivo devuelto por el servidor junto al campo

### Requirement: Tablas con superficie y alineación correcta

Las tablas SHALL presentarse en una superficie contenida con filas de altura consistente y separación equilibrada. La alineación de la última columna SHALL aplicarse solo cuando esa columna contiene acciones, y SHALL mantenerse la alineación natural de lectura en columnas de datos. Las cabeceras SHALL distinguirse visualmente de las celdas de datos. Toda tabla SHALL exponer un nombre accesible.

#### Scenario: Columna de datos no se desalinea

- **WHEN** una tabla tiene una sola columna de datos sin columna de acciones
- **THEN** sus celdas y su cabecera se alinean al inicio del texto, no al borde final

#### Scenario: Columna de acciones al final

- **WHEN** una tabla incluye una columna de acciones como última columna
- **THEN** solo esa columna se alinea al final

### Requirement: Estados de carga, vacío y error diseñados

Cada listado y cada resultado de búsqueda SHALL presentar los tres estados de forma diseñada y distinguible: carga, vacío y error. El estado vacío SHALL ser una composición con contexto y una acción sugerida, no una frase suelta en gris. El estado de error SHALL mostrar el motivo y ofrecer la recuperación. La carga SHALL preservar la forma del contenido que sustituye.

#### Scenario: Vacío con acción

- **WHEN** un listado no tiene datos
- **THEN** muestra una composición que explica la situación y propone cómo crear el primer registro

#### Scenario: Error recuperable

- **WHEN** falla la carga de un listado
- **THEN** se muestra el motivo y existe una acción para reintentar

#### Scenario: Carga sin saltos de diseño

- **WHEN** un listado está cargando
- **THEN** el espacio reservado corresponde a la forma del contenido que va a mostrarse

### Requirement: Medidor de nivel como componente del dominio

El nivel de dominio de una capacidad SHALL representarse con un componente visual de cinco posiciones que comunique el valor de forma inmediata, no como un número suelto. El componente SHALL exponer el valor de forma comprensible para tecnología de asistencia y SHALL ser coherente en todas las pantallas donde aparezca el nivel.

#### Scenario: Nivel legible de un vistazo

- **WHEN** se muestran varias asignaciones con niveles distintos
- **THEN** cada nivel se distingue visualmente de los demás por su representación en cinco posiciones

#### Scenario: Nivel comprensible sin verlo

- **WHEN** una persona usa un lector de pantalla sobre un nivel
- **THEN** obtiene el valor numérico y su capacidad asociada

### Requirement: Foco y límites de control visibles

Todo elemento interactivo SHALL mostrar un indicador de foco visible y consistente al navegar por teclado. Los bordes de controles y superficies interactivas SHALL mantener un contraste suficiente para distinguirse del fondo que los rodea, y los objetivos interactivos SHALL mantener un tamaño mínimo cómodo de activar. El foco SHALL respetarse también en los elementos que reciben foco programáticamente al cambiar de pantalla.

#### Scenario: Foco visible en todo interactivo

- **WHEN** el usuario tabula por una pantalla
- **THEN** cada elemento interactivo que recibe foco lo indica de forma visible

#### Scenario: Borde de control distinguible

- **WHEN** se mide el borde de un campo frente al fondo del lienzo
- **THEN** su contraste permite distinguir el límite del control

#### Scenario: Preferencia de movimiento reducido

- **WHEN** el sistema operativo declara preferencia por movimiento reducido
- **THEN** las transiciones no esenciales de la interfaz se desactivan
