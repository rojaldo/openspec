# Módulo 7: Despliegue en contenedores Docker

> **Duración:** 2.0 h · **Objetivo:** contenerizar el gateway OpenClaw y sus servicios complementarios.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Escribir un `Dockerfile` que levante el gateway con el workspace montado.
- Orquestar un stack con Docker Compose (gateway + base vectorial + MCP).
- Persistir estado con volúmenes (workspace, config, SQLite).
- Gestionar redes, puertos y variables de entorno (API keys).
- Aplicar buenas prácticas: sin secretos en la imagen, healthchecks, logs.

---

## 7.1 ¿Por qué Docker? La mudanza perfecta

**Docker** empaqueta tu aplicación (y sus dependencias) en un **contenedor** reproducible. Es como meter toda la oficina en una **caja estándar**: la abres en cualquier máquina y todo funciona igual, sin "en mi máquina sí funcionaba".

> 💡 **Analogía:** Docker es la *caja de mudanza con etiqueta*. Empaquetas el edificio (gateway + config + workspace), lo etiquetas y lo llevas a cualquier host; se monta igual siempre.

**Beneficios para OpenClaw:**
- **Reproducibilidad:** misma imagen → mismo comportamiento en cualquier host.
- **Aislamiento:** el gateway y sus servicios no ensucian el host.
- **Orquestación:** Docker Compose levanta gateway + Qdrant + MCP juntos.
- **Persistencia controlada:** los volúmenes deciden qué sobrevive a un reinicio.

---

## 7.2 El Dockerfile del gateway

Un `Dockerfile` describe cómo construir la imagen. Para OpenClaw:

```dockerfile
# 1. Base: imagen oficial de Node
FROM node:24-slim

# 2. Instala OpenClaw globalmente
RUN npm install -g openclaw@latest

# 3. Directorio del workspace
WORKDIR /workspace

# 4. Copia tu config (sin secrets: usa variables de entorno)
COPY openclaw.json /root/.openclaw/openclaw.json

# 5. Expón el puerto del gateway (Control UI)
EXPOSE 18789

# 6. Comando de arranque
CMD ["openclaw", "gateway", "start"]
```

> ⚠️ **Nunca copies API keys en la imagen.** Se pasan por **variables de entorno** en tiempo de ejecución (ver 7.4).

**Puntos clave:**
- Imagen base `node:24-slim` (ligera).
- `WORKDIR /workspace` = el hogar del agente dentro del contenedor.
- El puerto 18789 es el del Gateway/Control UI.
- El workspace debe venir de un **volumen** (persistencia), no de la imagen.

---

## 7.3 Docker Compose: el stack completo

Compose orquesta varios contenedores. Montamos **gateway + Qdrant** (vectores) para integrar con el Módulo 6:

```yaml
services:
  gateway:
    build: .
    container_name: openclaw-gateway
    ports:
      - "18789:18789"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}    # desde el .env, no hardcodeado
      - TZ=Europe/Madrid
    volumes:
      - ./workspace:/workspace             # persistencia del workspace
      - openclaw_state:/root/.openclaw     # persistencia config + estado SQLite
    restart: unless-stopped

  qdrant:
    image: qdrant/qdrant
    container_name: openclaw-qdrant
    ports:
      - "6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    restart: unless-stopped

volumes:
  openclaw_state:
  qdrant_data:
```

**Qué hace cada bloque:**
- **`gateway`:** tu imagen; expone el puerto; recibe API keys de variables de entorno; monta el workspace y el estado.
- **`qdrant`:** la base vectorial del Módulo 6; guarda sus datos en un volumen.
- **`volumes:`** nombrados para persistir: el workspace, el estado de OpenClaw y los datos de Qdrant sobreviven a `down`/`up`.

> 💡 Los servicios se ven entre sí por **nombre de servicio** en la red de Compose (ej. el gateway puede llamar a `qdrant:6333`).

---

## 7.4 Redes, puertos y variables de entorno

### Variables de entorno (API keys)
Nunca en la imagen ni en el `docker-compose.yml` versionado. Usa un archivo `.env` local (no lo subas a git):

```bash
# .env  (NO versionar)
OPENAI_API_KEY=sk-...
```

Y en Compose: `environment: - OPENAI_API_KEY=${OPENAI_API_KEY}`.

> ⚠️ Añade `.env` a tu `.gitignore`. Los secretos se quedan fuera del repo.

### Puertos
- `18789` → Gateway / Control UI (interfaz web).
- `6333` → Qdrant REST.

Solo expón al host los que necesites. Si no necesitas acceso externo, omite el `ports` y deja que Compose use la red interna.

### Zona horaria
El gateway usa la zona del contenedor. Fija `TZ=Europe/Madrid` (o la tuya) para que cron y fechas sean correctos.

---

## 7.5 Buenas prácticas

1. **Sin secretos en la imagen:** siempre variables de entorno en runtime.
2. **Volúmenes para todo lo que deba persistir:** workspace, config/estado, datos vectoriales.
3. **Healthcheck:** para que orquestadores sepan si el gateway está sano:
   ```yaml
   healthcheck:
     test: ["CMD", "openclaw", "status"]
     interval: 30s
     timeout: 10s
     retries: 3
   ```
4. **Logs:** el gateway escribe a stdout; Compose los captura (`docker compose logs -f gateway`).
5. **`restart: unless-stopped`:** el contenedor se recupera solo si el host se reinicia.
6. **Versión fija de la imagen:** ancla la versión de OpenClaw (`openclaw@X.Y.Z`) para reproducibilidad, y actualiza a propósito.
7. **`.gitignore`:** excluye `.env`, workspaces con secretos, y datos de volumen.

---

## Errores comunes

1. **API key dentro de la imagen:** se filtra a cualquiera que obtenga la imagen. Usa env vars.
2. **Sin volumen en el workspace:** al recrear el contenedor pierdes todo el trabajo.
3. **Confundir `down` con reinicio:** `docker compose down` elimina contenedores; los volúmenes nombrados persisten (salvo `-v`).
4. **Zona horaria por defecto (UTC):** cron/fechas "raro" si no fijas `TZ`.
5. **Exponer puertos innecesarios:** menos superficie de ataque. Solo los que uses.
6. **Sin healthcheck:** no sabes si el gateway está realmente operativo.

---

## Ejercicios

- [ ] Escribe un `Dockerfile` que instale OpenClaw y arranque el gateway con el workspace montado.
- [ ] Crea un `docker-compose.yml` con gateway + Qdrant y un `.env` para la API key.
- [ ] Levanta el stack (`docker compose up -d`) y verifica que el gateway responde en `18789`.
- [ ] Detén y recrea los contenedores (`down` + `up`) y comprueba que workspace y datos persisten.
- [ ] Añade un healthcheck y revisa los logs con `docker compose logs -f`.

---

## Resumen

- **Docker** = empaquetado reproducible (la caja de mudanza).
- **Dockerfile:** imagen base Node, instala OpenClaw, expone 18789.
- **Compose:** orquesta gateway + Qdrant (u otros servicios) en una red.
- **Persistencia:** volúmenes para workspace, estado y datos vectoriales.
- **Seguridad:** API keys por env vars (`.env` no versionado), healthchecks, `restart: unless-stopped`.

---

*Siguiente: [Módulo 8 — Proyecto final integrador](08-proyecto-final.md)*
