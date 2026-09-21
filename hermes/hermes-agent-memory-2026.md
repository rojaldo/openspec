# MEGATHREAD — How Hermes Agent Memory Actually Works in 2026: Native Memory, Providers, Obsidian, Profiles, Backups & Recall Tests

> **MEMORY & Context — Providers, context window, forgetting issues**
>
> **LAST UPDATED:** August 30, 2026
> **Scope:** Hermes Agent v0.20.6 behavior checked against source commit `4f225435`.

Hermes doesn't have one memory. It has several, and each exists to solve a different job. Most memory frustration begins the moment those systems get treated as interchangeable.

This refresh swaps the older "Advanced Memory Systems" framing for how Hermes Agent actually behaves today. Five recent threads had drawn 207 comments at the planning snapshot; the breakdown follows. Two further source threads round out the picture, covering Obsidian and memory churn.

---

## Table of contents

- [TL;DR — the memory stack in one table](#tldr--the-memory-stack-in-one-table)
- [What changed since the older advanced-memory thread](#what-changed-since-the-older-advanced-memory-thread)
- [Part 1: Native memory — small on purpose](#part-1-native-memory--small-on-purpose)
- [Part 2: session_search is history, not always-on memory](#part-2-session_search-is-history-not-always-on-memory)
- [Part 3: External providers — choose by job, not hype](#part-3-external-providers--choose-by-job-not-hype)
- [Part 4: Obsidian is a knowledge layer](#part-4-obsidian-is-a-knowledge-layer)
- [Part 5: Profiles — isolate by default, share deliberately](#part-5-profiles--isolate-by-default-share-deliberately)
- [Part 6: Backups — know what each command misses](#part-6-backups--know-what-each-command-misses)
- [Part 7: Recovery when something goes wrong](#part-7-recovery-when-something-goes-wrong)
- [Part 8: A small recall/reliability test suite](#part-8-a-small-recallreliability-test-suite)
- [Common failure patterns](#common-failure-patterns)
- [The practical default I would give a new user](#the-practical-default-i-would-give-a-new-user)
- [Why this refresh exists](#why-this-refresh-exists)
- [Contribute your setup](#contribute-your-setup)
- [Method and evidence limits](#method-and-evidence-limits)
- [Sources](#sources)

---

## TL;DR — the memory stack in one table

| Layer | What it actually is | Put this there | Do not use it for |
|---|---|---|---|
| **USER.md** | Always-loaded user profile; 1,375 chars by default | Stable preferences, identity, durable corrections | Logs, secrets, temporary plans |
| **MEMORY.md** | Always-loaded agent notes; 2,200 chars by default | Stable environment facts, conventions, compact lessons | Long notes or transcripts |
| **session_search / state.db** | On-demand full-text search over retained conversations | Exact historical detail | Facts needed every turn |
| **External memory provider** | One active provider for broader recall/capture/search | Semantic memory, relationships, deliberate sharing | Guaranteed capture or recall |
| **Obsidian** | Markdown knowledge base accessed through a bundled skill | Long notes, decisions, research | Automatic recall by itself |
| **Context files** | Project instructions such as AGENTS.md / HERMES.md | Rules, architecture, commands | Personal history |
| **Skills** | Reusable procedures loaded when needed | "How to do X reliably" | User facts or document storage |

> **The shortest useful rule is:**
> *Native memory keeps a few facts always visible. A provider retrieves a larger memory on demand. Obsidian holds human-readable knowledge. Profiles decide who owns which state.*

Hermes loads `MEMORY.md` and `USER.md` into the system prompt when a session starts. `session_search` is a different animal: it queries the actual messages sitting in the active profile's SQLite store, and only when you ask for them.

---

## What changed since the older advanced-memory thread

The April master thread did a real service by surfacing the problem, but several parts of it are now outdated, and a few are unsafe to copy verbatim.

| Older framing | Current correction |
|---|---|
| "A provider swaps out the Markdown files" | An external provider is **additive** by default. Built-in memory remains active unless you explicitly disable both native stores. |
| "Share one state.db as the central brain" | `state.db` is the profile's session store. **Do not** point multiple agents at one Hermes home. Use separate profiles and a provider designed for shared memory. |
| "Obsidian is the agent's memory" | Obsidian is a **knowledge layer**. The bundled skill performs filesystem reads, searches, and edits; it does not automatically inject the vault into every turn. |
| "The cap eventually overwrites old entries" | Native memory does **not** silently evict or auto-compact. An over-limit write returns an error so entries can be consolidated or removed. |
| "More memory means a bigger Markdown file" | Bigger always-loaded files create a permanent prompt tax. Use native memory for the small always-on set and retrieval for the long tail. |

> The last correction is the one that matters. A recent Obsidian thread repeated the claim that Hermes "will eventually overwrite" native memory at the cap. The current docs and source say the opposite: the write simply **fails**, leaving the existing entries visible so you can consolidate or delete them on purpose.

---

## Part 1: Native memory — small on purpose

### The documented defaults

- **MEMORY.md:** 2,200 characters, roughly 800 tokens.
- **USER.md:** 1,375 characters, roughly 500 tokens.
- Both live under the active profile's `memories/` directory.
- Both are injected as a **frozen snapshot** when a session starts.
- A write hits disk immediately, but the snapshot in the already-running session does **not** change. A new session picks it up.
- Writing an exact duplicate is a successful no-op, not a second copy.
- Over-limit writes **fail**; Hermes does not silently evict an older fact.

> This is the root of a lot of "it saved the fact but still answered from the old value" reports. The file can already be correct while the running session keeps serving the snapshot it started with.

### Can you raise the limit?

Yes. The limits are configurable:

```bash
hermes config set memory.memory_char_limit 4000
hermes config set memory.user_char_limit 2000
```

But raising the caps does **not** turn native memory into retrieval. Every added character still draws from the same fixed prompt budget. Measure the cost before and after with:

```bash
hermes prompt-size
hermes prompt-size --json
```

> **My advice:** raise the caps only for a measured reason. If you're trying to fit paragraphs, logs, journals, or project history in here, you've picked the wrong layer.

### What belongs in each native file?

| Question | USER.md | MEMORY.md | Somewhere else |
|---|---|---|---|
| "Does this describe the human across many projects?" | ✅ Yes | Maybe | — |
| "Is this a compact fact the agent needs on most turns?" | Maybe | ✅ Yes | — |
| "Is this a procedure?" | — | Pointer only | Skill |
| "Is this a project rule or machine map?" | — | Pointer only | AGENTS.md / HERMES.md |
| "Is this a long note or decision record?" | — | Pointer only | Obsidian/project docs |

A good native entry is **compact and operational**:

> *Project Atlas uses pnpm, tests with `pnpm test`, and keeps the deployment runbook at `docs/runbook.md`.*

A bad native entry is **temporary**:

> *User plans to try the planning skill next week.*

The "Memory frustration" thread is the textbook failure case: temporary plans crowded into the scarce native store while durable family facts fell out of the useful set.

### Stop bad writes before cleaning them forever

Turn on the built-in write gate:

```bash
hermes config set memory.write_approval true
hermes config set display.memory_notifications verbose
```

Then review staged writes with:

```bash
/memory pending
/memory approve <id>
/memory reject <id>
```

Interactive CLI writes can prompt inline; writes from messaging or background review get staged for later review.

> This gate only covers the built-in MEMORY.md / USER.md write path. Automatic capture and tools from a provider run under their own settings, so audit those separately.

If the background learning pass itself is the source of the churn, you can switch off automatic post-turn reviews while keeping manual `/refine` available:

```bash
hermes config set auxiliary.background_review.enabled false
```

If you've already put an external provider through its paces and deliberately want **no** built-in memory, both stores can be disabled:

```bash
hermes config set memory.memory_enabled false
hermes config set memory.user_profile_enabled false
```

> Only do that after the provider passes the recall and restore tests further down. Disabling both stores removes the built-in memory tool and its guidance, but leaves the configured external provider running.

---

## Part 2: session_search is history, not always-on memory

Hermes keeps sessions in the active profile's `state.db`. `session_search` leans on SQLite FTS5, a full-text index, to return real messages and let the agent scroll around a hit. It is **not** an LLM-generated recollection.

**Use it for:**
- "Find the session where we decided how Atlas deploys."
- "What did the error say last Tuesday?"
- Recovering details that were correctly omitted from tiny native memory.

**Don't** copy every old conversation into MEMORY.md. If a topic is genuinely critical, keep a short pointer and retrieve the source conversation when you actually need it.

> One more thing: pruning sessions changes what search can reach. Auto-pruning is off by default, so if you turn it on or prune by hand, **export first.**

---

## Part 3: External providers — choose by job, not hype

The Hermes repository currently ships **eight** memory-provider plugins. Only one can sit in the native provider slot at a time, and built-in memory normally keeps running alongside it.

```bash
hermes memory setup
hermes memory status
hermes memory off
```

When a provider is active it may inject a base context block, prefetch relevant memories, sync completed turns, extract at session boundaries, mirror successful built-in memory writes, and expose provider-specific tools. Which of those actually happen depends on the provider.

### The eight in-repo providers

| Provider | Best fit | Storage | Main catch |
|---|---|---|---|
| **Honcho** | Multi-agent systems that need a shared user model but distinct agent identities | Cloud or self-hosted | Understand its workspace, user-peer, and per-profile AI-peer model before cloning profiles |
| **OpenViking** | Self-hosted, hierarchical knowledge with filesystem-style browsing and tiered retrieval | Self-hosted | You operate the server and must back up its server-side data separately |
| **Mem0** | Hands-off extraction and semantic recall | Cloud, self-hosted server, or OSS | "Local" still requires choosing and maintaining an LLM/embedder/vector store |
| **Hindsight** | Entity relationships, knowledge-graph recall, and reflection across memories | Cloud or local embedded PostgreSQL | Auto-retain/auto-recall are real data-flow choices; verify latency, cost, and retention |
| **Holographic** | Lowest-friction official local option; inspectable SQLite facts and trust scores | Local SQLite | Automatic session-end extraction is off by default; the current native-memory mirror hook handles adds but not replace/remove actions |
| **RetainDB** | Teams already using its hosted memory/file infrastructure | Cloud | Hosted dependency; Hermes docs list $20/month, so verify pricing again before migration |
| **ByteRover** | Developer-focused local-first context tree with an optional sync path | Local or cloud sync | Requires the `brv` CLI; back up the profile's ByteRover tree |
| **Supermemory** | Semantic profile recall plus deliberate multi-container or profile-tag patterns | Cloud or self-hosted | Container naming determines whether profiles isolate or share remote memory |

> This is a capability map from the official docs, not an independent quality ranking.

The same docs page also describes **Memori**, which you install separately via `hermes-memori`; it is **not** among the eight provider plugins in the Hermes source tree. Treat it as an add-on, and verify its install, data, and backup contract yourself before leaning on it.

### What about Mnemosyne?

Mnemosyne came up constantly in recent community replies, including one user reporting three months of clean operation. That's useful field evidence, but it's not a benchmark.

- Mnemosyne is a **third-party** Hermes-native plugin. Its project says it implements Hermes' MemoryProvider interface, stores data in local SQLite, and ships its own Hermes install and health-check workflow.
- It is **not** one of the eight provider plugins shipped in the current Hermes repository.

That distinction matters for updates, support, dependency persistence, backups, and recovery when things break. Popularity in the community is a reason to **test** it, not a reason to skip the test suite.

### Provider selection in plain English

Start with **no external provider** if native memory plus session search already does the job. **Holographic** is the simplest in-repo local fact store; otherwise pick from the table by job, then verify storage, capture policy, namespace, cost, and restore path. Version, back up, and regression-test every third-party provider before you trust it.

### One provider does not mean one privacy boundary

Local profile config files don't automatically prove cloud-side isolation. Remote providers key off banks, projects, workspaces, user IDs, agent IDs, or container tags. Two profiles with the same remote namespace can share data even when their local Hermes homes are separate. **Verify the provider namespace** instead of assuming the local profile directory tells you anything.

**Decide the policy first:**
- **Isolated profiles:** separate Hermes profiles and distinct remote namespaces.
- **Shared human model, distinct agents:** a provider topology designed for that, such as Honcho's shared workspace/user peer plus one AI peer per profile.
- **Shared semantic pool:** deliberately reuse the same provider bank/container, then run the profile-boundary test below.

> **Don't** fake "shared memory" by pointing two agent processes at the same `HERMES_HOME`, `state.db`, or local provider database. Hermes explicitly warns against multiple writers to one home.

---

## Part 4: Obsidian is a knowledge layer

Hermes ships a bundled Obsidian skill that works directly on Markdown files: it reads notes, lists files, searches content, creates notes, appends or patches notes, and adds `[[wikilinks]]`. The documented path convention is the `OBSIDIAN_VAULT_PATH` variable; leave it unset and the skill falls back to `~/Documents/Obsidian Vault`.

### Clean setup

1. Find the active profile's environment file:

   ```bash
   hermes config env-path
   ```

2. Add an absolute vault path to that file:

   ```
   OBSIDIAN_VAULT_PATH=/absolute/path/to/your/Obsidian Vault
   ```

3. Start a new session and run a **read-only test first**:
   > Load the Obsidian skill. Search the vault for "Atlas." Do not create, edit, move, rename, or delete anything. Return note paths and the exact lines that matched.

4. Only then enable a **bounded write** workflow.

> The documented bundled workflow touches only the filesystem, so basic use needs no Obsidian HTTP plugin or MCP server. Those have their place in other architectures, but they're extra layers on top of the basic integration, not part of it.

### Protect an existing vault

The best practical advice from the recent setup thread: **don't grant full-vault write access on day one.** Create an *Agent Inbox* folder or a separate small vault, keep existing notes/config/templates read-only, and widen access only after you've watched the behavior come out clean.

**A sane write contract:**
- Hermes may create new notes only under `Agent Inbox/<profile>/`.
- No deletes, renames, or edits to existing notes without approval.
- Every generated note includes its date and source session/links.
- One profile writes; humans review and move accepted notes. Other profiles stay read-only unless there is a real multi-writer design.
- The vault has its own versioned backup and restore test.

> Instructions are soft controls. If protecting an established vault actually matters, enforce the boundary with filesystem permissions, a read-only mount, a separate copy, or some other OS-level control. A prompt that says "never delete" is not a backup.

### Obsidian search is not provider recall

The Obsidian skill searches **when the agent calls it**. It does not turn every note into context on its own. If the problem is search quality over a large Markdown corpus, **QMD** is a separate optional local-search skill that blends keyword and semantic retrieval; a highly-upvoted community reply recommended it specifically for surfacing Obsidian content.

> QMD is a deliberate local-engine install, not a lightweight toggle. The current skill targets macOS and Linux, needs Node.js 22 or newer, wants a Homebrew SQLite build with extension support on macOS, and pulls down roughly 2 GB of local models on first run.

That gives you **three distinct designs:**
- **Plain Obsidian skill:** simplest, transparent file search and edits.
- **Obsidian + QMD:** local hybrid retrieval over the vault.
- **Obsidian + memory provider:** human-readable source notes plus provider recall, with an explicit rule for what gets indexed or captured.

> Don't index everything just because you can. Bad notes retrieved perfectly are still bad memory.

---

## Part 5: Profiles — isolate by default, share deliberately

A Hermes profile is a separate `HERMES_HOME` with its own config, `.env`, personality, memory, sessions, skills, cron jobs, provider config, and state database.

**Important clone behavior:**

```bash
hermes profile create writer --clone
```

This copies config, `.env`, `SOUL.md`, and skills, but the new profile starts with **fresh sessions and empty native memory**.

```bash
hermes profile create writer-copy --clone-all
```

This also copies memories, cron jobs, and plugins, but **skips session history and state.db**. When history matters, reach for a profile export or a full backup instead.

> Profiles are **not** OS sandboxes. On a host install they normally share the same operating-system user and the same CLI home, so they can still see the same files and external CLI credentials. Profile isolation protects Hermes state. Filesystem isolation is a separate control.

### Safe sharing patterns

A **canary** is a unique made-up fact you plant on purpose, then try to retrieve from the intended profile and nowhere else.

| Goal | Pattern |
|---|---|
| Independent agents | Separate profiles, separate provider namespaces, separate writable vault inboxes |
| Shared read-only knowledge | Same Obsidian vault mounted/readable by several profiles; one writer or per-profile inboxes |
| Shared user model | Provider designed for shared identity, with distinct agent identity per profile |
| Shared provider corpus | Same explicit bank/container/project, documented and canary-tested |
| Shared procedure | Install the same skill in each profile or distribute a reviewed profile package |
| **Never do this** | Two live agents writing the same Hermes home or local SQLite memory store |

---

## Part 6: Backups — know what each command misses

### Backup matrix

| Method | What it covers | What it misses / the catch |
|---|---|---|
| `hermes backup` | Native memory, state.db, credentials, profile-local data, and home-relative paths declared by the active provider | Remote cloud contents and a normal Obsidian vault; the archive is credential-sensitive |
| `hermes backup --quick` / `/snapshot` | state.db, config/auth/cron state, and selected critical DBs such as Holographic `memory_store.db` | The current allow-list does **not** include MEMORY.md, USER.md, or every provider store |
| `hermes profile export` | A profile snapshot including native memory; credentials are stripped | Not a whole-install backup; inspect history/provider coverage inside the archive |
| Provider-native export | The provider corpus, if its export is complete and restorable | Native memory, sessions, Obsidian, and anything the provider omits |
| Vault backup/versioning | Obsidian notes, attachments, and configuration you include | Hermes state and external-provider data |

The full backup uses SQLite's backup API to take a consistent copy while WAL mode (write-ahead logging, which keeps the database live during writes) is active. Import overwrites files in the target Hermes home, and the docs tell you to stop the gateway first.

> As of Hermes commit `4f225435`, the quick-snapshot allow-list covers `state.db`, config/auth/cron state...
