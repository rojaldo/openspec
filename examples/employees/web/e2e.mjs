import { chromium } from "playwright";

const BASE = process.env.BASE_URL ?? "http://127.0.0.1:8000";
const results = [];

function check(name, condition, detail = "") {
  results.push({ name, ok: Boolean(condition), detail });
  console.log(`${condition ? "PASS" : "FAIL"}  ${name}${detail ? " :: " + detail : ""}`);
}

async function main() {
  const browser = await chromium.launch({
    executablePath: process.env.CHROMIUM_PATH ?? "/usr/bin/chromium",
    args: ["--no-sandbox"],
  });
  const page = await browser.newPage();

  const errors = [];
  page.on("console", (msg) => {
    if (msg.type() === "error") errors.push(msg.text());
  });
  page.on("pageerror", (err) => errors.push(String(err)));

  // 0. sin sesión no hay contenido: ruta protegida redirige al acceso
  await page.goto(`${BASE}/capacidades`, { waitUntil: "networkidle" });
  check(
    "sin sesión, una ruta protegida redirige al acceso",
    await page.locator("#login-username").isVisible(),
    page.url().replace(BASE, ""),
  );

  // 0a. la pantalla de acceso no ofrece el cromo de la aplicación interna
  check(
    "el acceso no muestra la navegación del portal",
    (await page.locator("nav.nav").count()) === 0,
  );
  const loginText = await page.locator("body").innerText();
  check(
    "el acceso no anuncia las secciones protegidas",
    !["Catálogo", "Empleados", "Buscador"].some((s) => loginText.includes(s)),
  );
  check("el acceso no ofrece cerrar sesión", !loginText.includes("Cerrar sesión"));
  check(
    "el acceso conserva la identidad del portal",
    loginText.includes("Portal de empleados"),
  );
  check(
    "el salto al contenido tiene destino en el acceso",
    (await page.locator(".skip-link").getAttribute("href")) === "#main" &&
      (await page.locator("#main").count()) === 1,
  );

  // 0b. acceso con credenciales incorrectas muestra el motivo
  await page.fill("#login-username", "admin");
  await page.fill("#login-password", "incorrecta");
  await page.click("button[type=submit]");
  await page.waitForSelector(".field .error", { timeout: 5000 });
  check(
    "acceso incorrecto muestra el motivo",
    /incorrectos/i.test(await page.locator(".field .error").innerText()),
  );

  // 0c. acceso correcto entra al portal
  await page.fill("#login-username", "admin");
  await page.fill("#login-password", "admin");
  await page.click("button[type=submit]");
  await page.waitForFunction(
    () => !document.querySelector("#login-username"),
    { timeout: 5000 },
  );
  check("acceso correcto entra al portal", await page.locator("nav.nav").isVisible());
  check(
    "con sesión la navegación está disponible",
    (await page.locator("nav.nav").count()) === 1,
  );

  // 1. deep route on direct load (con sesión)
  await page.goto(`${BASE}/empleados`, { waitUntil: "networkidle" });
  check("recarga directa de ruta profunda sirve el SPA", await page.locator("nav.nav").isVisible());

  // 2. create capabilities
  await page.goto(`${BASE}/capacidades`, { waitUntil: "networkidle" });
  for (const name of ["Java", "Liderazgo"]) {
    await page.fill("#capability-name", name);
    await page.click("button[type=submit]");
    await page.waitForFunction(
      (n) => document.body.textContent?.includes(n),
      name,
      { timeout: 5000 },
    );
  }
  check(
    "alta de capacidades se refleja en la lista",
    (await page.locator("table.table tbody tr").count()) === 2,
  );

  // 3. duplicate capability shows server error
  await page.fill("#capability-name", "Java");
  await page.click("button[type=submit]");
  await page.waitForSelector(".field .error", { timeout: 5000 });
  const dupText = await page.locator(".field .error").innerText();
  check("capacidad duplicada muestra el motivo del servidor", /ya existe/i.test(dupText), dupText);

  // 4. create employees
  await page.goto(`${BASE}/empleados`, { waitUntil: "networkidle" });
  for (const name of ["Ana", "Luis"]) {
    await page.fill("#employee-name", name);
    await page.click("button[type=submit]");
    await page.waitForFunction((n) => document.body.textContent?.includes(n), name, {
      timeout: 5000,
    });
  }
  check("alta de empleados se refleja en la lista", (await page.locator("table.table tbody tr").count()) === 2);

  // 5. assign two levels
  await page.click("table.table tbody tr:first-child a");
  await page.waitForSelector("#assignment-level");
  await page.selectOption("#assignment-capability", { label: "Java" });
  await page.selectOption("#assignment-level", "5");
  await page.click("button[type=submit]");
  await page.waitForFunction(() => document.body.textContent?.includes("Java"), { timeout: 5000 });

  await page.goto(`${BASE}/empleados`, { waitUntil: "networkidle" });
  await page.click("table.table tbody tr:nth-child(2) a");
  await page.waitForSelector("#assignment-level");
  await page.selectOption("#assignment-capability", { label: "Java" });
  await page.selectOption("#assignment-level", "3");
  await page.click("button[type=submit]");
  await page.waitForFunction(() => document.body.textContent?.includes("Java"), { timeout: 5000 });

  // 6. duplicate assignment shows error
  await page.selectOption("#assignment-capability", { label: "Java" });
  await page.selectOption("#assignment-level", "2");
  await page.click("button[type=submit]");
  await page.waitForSelector(".field .error", { timeout: 5000 });
  const assignErr = await page.locator(".field .error").innerText();
  check("capacidad ya asignada muestra el motivo", /ya tiene asignada/i.test(assignErr), assignErr);

  // 7. search without min level
  await page.goto(`${BASE}/buscar`, { waitUntil: "networkidle" });
  await page.selectOption("#search-capability", { label: "Java" });
  await page.click("button[type=submit]");
  await page.waitForSelector("table.table tbody tr", { timeout: 5000 });
  const allRows = await page.locator("table.table tbody tr").count();
  check("búsqueda sin nivel devuelve todos", allRows === 2, `${allRows} filas`);

  // 8. search with min level 4
  await page.fill("#search-min-level", "4");
  await page.click("button[type=submit]");
  await page.waitForTimeout(500);
  const filtered = await page.locator("table.table tbody tr").count();
  const filteredText = await page.locator("table.table").innerText();
  check("búsqueda con nivel mínimo filtra", filtered === 1 && /Ana/.test(filteredText), `${filtered} filas`);

  // 9. min level 6 -> empty, not error
  await page.fill("#search-min-level", "6");
  await page.click("button[type=submit]");
  await page.waitForSelector(".empty-state", { timeout: 5000 });
  const emptyText = await page.locator(".empty-state").last().innerText();
  check("nivel mínimo inalcanzable devuelve vacío sin error", /Sin resultados/i.test(emptyText), emptyText);

  // 10. focus management (accessibility)
  await page.goto(`${BASE}/capacidades`, { waitUntil: "networkidle" });
  const focusAfterRoute = await page.evaluate(() => {
    const active = document.activeElement;
    return active ? { tag: active.tagName, live: active.getAttribute("aria-live") } : null;
  });
  check(
    "al entrar en una ruta el foco va al contenedor anunciado",
    focusAfterRoute?.live === "polite",
    JSON.stringify(focusAfterRoute),
  );
  await page.keyboard.press("Tab");
  const afterFirstTab = await page.evaluate(() => document.activeElement?.tagName ?? "none");
  check(
    "tras el contenedor, Tab alcanza un control interactivo",
    ["A", "BUTTON", "INPUT", "SELECT"].includes(afterFirstTab),
    afterFirstTab,
  );

  // 11. token usage (no hardcoded colors in computed style of a button)
  const btnColor = await page.evaluate(() => {
    const button = document.querySelector(".btn--primary");
    return button ? getComputedStyle(button).backgroundColor : "";
  });
  check(
    "el botón primario usa el color de acento del token",
    btnColor === "rgb(28, 84, 201)",
    btnColor,
  );

  // 12. edición de capacidad
  await page.goto(`${BASE}/capacidades`, { waitUntil: "networkidle" });
  await page.locator("table.table tbody tr").first().locator("button", { hasText: "Editar" }).click();
  await page.fill(".inline-edit__input", "Java 21");
  await page.locator("button", { hasText: "Guardar" }).click();
  await page.waitForFunction(() => document.body.textContent?.includes("Java 21"), { timeout: 5000 });
  check("edición de capacidad se refleja en la lista", true);

  // 13. edición de empleado conserva capacidades
  await page.goto(`${BASE}/empleados`, { waitUntil: "networkidle" });
  await page.locator("table.table tbody tr").first().locator("button", { hasText: "Editar" }).click();
  await page.fill(".inline-edit__input", "Ana Editada");
  await page.locator("button", { hasText: "Guardar" }).click();
  await page.waitForFunction(() => document.body.textContent?.includes("Ana Editada"), { timeout: 5000 });
  await page.goto(`${BASE}/empleados`, { waitUntil: "networkidle" });
  await page.locator("table.table tbody tr").first().locator("a").click();
  await page.waitForSelector(".level-meter", { timeout: 5000 });
  check("edición de empleado conserva sus capacidades", (await page.locator(".level-meter").count()) > 0);

  // 14. corrección de nivel
  await page.locator("button", { hasText: "Cambiar nivel" }).first().click();
  await page.selectOption(".inline-edit__input", "2");
  await page.locator("button", { hasText: "Guardar" }).first().click();
  await page.waitForFunction(
    () => document.querySelector(".level-meter")?.getAttribute("aria-label") === "Nivel 2 de 5",
    { timeout: 5000 },
  );
  check("corrección de nivel se refleja en el medidor", true);

  // 15. desasignación
  await page.locator("button", { hasText: "Quitar" }).first().click();
  await page.locator("button", { hasText: "Sí, quitar" }).click();
  await page.waitForFunction(
    () => document.querySelectorAll(".level-meter").length === 0,
    { timeout: 5000 },
  );
  check("desasignación quita la capacidad de la ficha", true);

  // 16. baja de empleado con confirmación
  await page.goto(`${BASE}/empleados`, { waitUntil: "networkidle" });
  const beforeDelete = await page.locator("table.table tbody tr").count();
  await page.locator("table.table tbody tr").first().locator("button", { hasText: "Eliminar" }).click();
  await page.locator("button", { hasText: "Sí, eliminar" }).click();
  await page.waitForFunction(
    (n) => document.querySelectorAll("table.table tbody tr").length === n - 1,
    beforeDelete,
    { timeout: 5000 },
  );
  check("baja de empleado pide confirmación y desaparece del listado", true);

  // 17. cierre de sesión
  await page.locator("button", { hasText: "Cerrar sesión" }).click();
  await page.waitForSelector("#login-username", { timeout: 5000 });
  await page.goto(`${BASE}/empleados`, { waitUntil: "networkidle" });
  check(
    "tras cerrar sesión, una ruta protegida vuelve al acceso",
    await page.locator("#login-username").isVisible(),
  );

  const realErrors = errors.filter(
    (text) => !/status of (400|401|404|409)/.test(text),
  );
  check("sin errores reales de consola/página", realErrors.length === 0, realErrors.join(" | "));

  await browser.close();

  const failed = results.filter((r) => !r.ok);
  console.log(`\n${results.length - failed.length}/${results.length} comprobaciones PASS`);
  if (failed.length > 0) {
    process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error("E2E abortado:", err);
  process.exitCode = 1;
});
