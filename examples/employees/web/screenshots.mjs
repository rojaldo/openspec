import { chromium } from "playwright";

const BASE = process.env.BASE_URL ?? "http://127.0.0.1:8000";

async function main() {
  const browser = await chromium.launch({
    executablePath: process.env.CHROMIUM_PATH ?? "/usr/bin/chromium",
    args: ["--no-sandbox"],
  });
  const page = await browser.newPage({ viewport: { width: 1100, height: 820 } });

  const shots = [
    ["/", "01-home"],
    ["/capacidades", "02-capacidades"],
    ["/empleados", "03-empleados"],
    ["/empleados/1", "04-ficha"],
    ["/buscar", "05-buscador"],
  ];

  for (const [path, name] of shots) {
    await page.goto(`${BASE}${path}`, { waitUntil: "networkidle" });
    await page.waitForTimeout(300);
    await page.screenshot({ path: `/tmp/shot-${name}.png` });
    console.log(`capturada ${name}`);
  }

  // estado de error visible
  await page.goto(`${BASE}/capacidades`, { waitUntil: "networkidle" });
  await page.fill("#capability-name", "Java");
  await page.click("button[type=submit]");
  await page.waitForSelector(".field .error", { timeout: 5000 });
  await page.screenshot({ path: "/tmp/shot-06-error.png" });
  console.log("capturada 06-error");

  await browser.close();
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
