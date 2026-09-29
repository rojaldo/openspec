# Tasks

## 1. Contrato de diseño

- [x] 1.1 Escribir `web/DESIGN.md` con las secciones de tokens (color, tipografía, espaciado, forma, foco, movimiento), primitivas con sus estados, superficies, responsive, accesibilidad y deuda aceptada, y verificar que cada decisión visual del rediseño (paleta de neutros fríos con borde de control ≥3:1, escala de siete pasos con display, una sola familia, medidor de nivel como firma, tres niveles de superficie) está nombrada en el documento antes de tocar código
- [x] 1.2 Reescribir `web/src/styles/tokens.css` a partir del contrato y verificar que todo token usado en `app.css` existe aquí y que no queda ninguna custom property heredada sin uso (búsqueda de `var(--` sin definición)

## 2. Primitivas base

- [x] 2.1 Rehacer los tokens de superficie y color en `tokens.css` (lienzo, superficie, superficie elevada, borde, borde fuerte, acento desaturado, pares semánticos éxito/peligro con fondo teñido) y verificar midiendo el contraste del borde de control contra el lienzo (objetivo ≥3:1)
- [x] 2.2 Cargar la familia tipográfica elegida (Lexend o IBM Plex Sans) autoalojada, subseteada y con `font-display: swap`, y verificar que `npm run build` la emite al bundle y que `tsc` compila sin errores
- [x] 2.3 Aplicar la escala tipográfica de siete pasos y los pesos del contrato a `app.css`, y verificar de forma observable que el título de página se distingue del cuerpo por tamaño y peso y que nivel y contadores usan `tabular-nums`
- [x] 2.4 Rehacer la primitiva `.btn` con sus cinco estados (reposo, hover, foco, deshabilitado, activo) y verificar los cinco estados en las variantes primaria, peligro y fantasma con captura por estado
- [x] 2.5 Rehacer la primitiva `.field` con control dimensionado por contenido (campo corto estrecho, campo abierto amplio, dominio acotado estrecho) y con estados de reposo, hover, foco, deshabilitado y error, y verificar de forma observable que un campo de nombre corto no ocupa el ancho del campo abierto
- [x] 2.6 Corregir la alineación de la fila de formulario en la primitiva y verificar midiendo en navegador real que los bordes superior e inferior del botón de envío coinciden con los del control en los cuatro formularios
- [x] 2.7 Rehacer la primitiva `.table` con superficie contenida, altura de fila consistente, cabecera diferenciada y alineación final condicionada a la existencia real de una columna de acciones, y verificar que una tabla de una sola columna de datos se alinea al inicio y que una con columna de acciones alinea solo esa columna
- [x] 2.8 Rehacer la primitiva `.alert` con las variantes y pares semánticos del contrato, y verificar que un aviso de éxito y uno de error se distinguen por color de texto, fondo y borde

## 3. Primitivas nuevas

- [x] 3.1 Implementar la cabecera de página (título + zona de acciones) como primitiva y verificar que las cinco pantallas pueden montarla sin estilos locales
- [x] 3.2 Implementar la fila de listado interactiva como primitiva (superficie clicable completa, affordance de navegación, hover y foco, activación por teclado con Enter y con enlace real para abrir en pestaña nueva) y verificar que el texto del registro usa el color de texto del contrato y que el área clicable cubre la fila
- [x] 3.3 Implementar el componente de nivel 1-5 como primitiva (cinco posiciones, valor comprensible para tecnología de asistencia) y verificar de forma observable que cinco niveles distintos se distinguen entre sí y que el valor numérico es accesible
- [x] 3.4 Implementar los estados de carga con forma (skeleton que preserva la forma del contenido), vacío como composición con acción sugerida, y error con motivo y acción de reintento, y verificar los tres estados en la pantalla de catálogo con y sin datos

## 4. Rediseño de pantallas

- [x] 4.1 Migrar la pantalla de inicio a las primitivas nuevas y verificar de forma observable que las tres secciones usan la fila interactiva y que no quedan listas ni enlaces azules crudos
- [x] 4.2 Migrar la pantalla de catálogo y verificar que alta, baja y los tres estados (carga, vacío, error) se presentan con las primitivas nuevas
- [x] 4.3 Migrar la pantalla de empleados y verificar que el registro usa la fila interactiva, que la columna de datos se alinea al inicio y que el área clicable cubre la fila completa
- [x] 4.4 Migrar la ficha de empleado y verificar que el formulario de asignación queda con el botón alineado al control y que las capacidades asignadas muestran el medidor de nivel
- [x] 4.5 Migrar el buscador y verificar que el campo de nivel mínimo es estrecho y acotado, que la ayuda es concisa y que los resultados muestran el medidor de nivel y su estado vacío diseñado
- [x] 4.6 Reemplazar el diálogo nativo de confirmación de borrado por el patrón de confirmación del contrato y verificar de forma observable que borrar una capacidad pide confirmación en la interfaz

## 5. Verificación de extremo a extremo

- [x] 5.1 Reconstruir con `npm run build` y verificar que `tsc` compila sin errores y que el bundle de fuentes y estilos se emite
- [x] 5.2 Ejecutar el arnés E2E existente (`web/e2e.mjs`) contra el build servido por Flask y verificar que los flujos funcionales siguen pasando (altas, asignaciones, búsqueda con y sin umbral, errores del servidor)
- [x] 5.3 Verificar de forma integrada los requisitos de la spec: alineación del botón medida a 0px, contraste del borde de control ≥3:1, fila completa activable por teclado, coherencia del medidor de nivel en las pantallas donde aparece, y `prefers-reduced-motion` respetado
- [x] 5.4 Ejecutar los tests de backend (`uv run python -m unittest discover`) y verificar que siguen pasando sin cambios, confirmando que ni `db.py` ni la API se alteraron
- [x] 5.5 Ejecutar el arnés de contraste sobre las cinco pantallas contra el contrato y verificar que ningún color, tamaño o espacio renderizado queda fuera de los tokens declarados
