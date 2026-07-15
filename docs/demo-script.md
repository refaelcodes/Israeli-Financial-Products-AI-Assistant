# Demo video — shot-by-shot script · תסריט וידאו הדגמה

**Goal:** a cold-touch demo for XPlace / LinkedIn / a portfolio pin — a
non-technical business owner should get it in one watch.
**Length:** ~75–90 seconds (first-touch length per the video playbook).
**One scenario only:** ask a fund question → get SQL + results → trust + privacy → CTA.
**Narrative arc:** Problem → Solution → Next step.

> Record two cuts from this one script: this **75–90 s** version (cold touch), and
> a **2–3 min** version for a warm lead (linger on the dashboard and the provider
> panel, add one more question). Do **not** cut a 15‑min walkthrough unless a lead asks.

---

## Before you record (setup)

- Start the backend (`cd backend && python fund_ai_app.py`) and frontend
  (`npm run dev`), log in, so nothing loads on camera.
- **AI mode = Mock** for the main flow (instant, offline, deterministic — no key,
  no latency, no data leaves the machine). Optionally show one **Claude API**
  answer in the 2–3 min cut.
- Pre-load the browser at **Client Questions**; have the dashboard tab ready.
- Zoom the browser to ~110–125 % so text is legible on mobile.

---

## Shot list

| # | Time | On screen (what to show / do) | Voiceover — EN | קריינות — עברית |
|---|------|-------------------------------|----------------|------------------|
| **1 · Hook** (B1) | 0:00–0:06 | Open on an **already-answered** Client Question: the Hebrew question, the generated **SQL**, and the **results table** all visible. No logo, no intro. | "A question about pension funds — asked in plain Hebrew. Here's the answer, and the exact query behind it." | "שאלה על קרנות פנסיה — בעברית פשוטה. הנה התשובה, ואיתה השאילתה המדויקת שמאחוריה." |
| **2 · Problem** (B3) | 0:06–0:20 | Cut to **Holdings** and **Funds (Gemel)** grids — scroll sideways to reveal many Hebrew columns and rows. | "Israel's fund data is public — but it's dozens of tables, Hebrew columns, tens of thousands of rows. One simple question means writing SQL by hand." | "נתוני הקרנות בישראל ציבוריים — אבל אלו עשרות טבלאות, עמודות בעברית, עשרות אלפי שורות. שאלה אחת פשוטה דורשת לכתוב SQL ביד." |
| **3 · Solution** (B3) | 0:20–0:44 | Back to **Client Questions**. Type a question (e.g. *"10 הקרנות עם התשואה הגבוהה ביותר"* / "Top 10 funds by yield"), press **Ask**. Show the **SQL** appear, then the **results table** fill. | "Now you just ask. The assistant writes a read-only SQL query, runs it on the database, and shows you both — the numbers, and the query that produced them. Nothing is a black box." | "עכשיו פשוט שואלים. העוזר כותב שאילתת SQL לקריאה בלבד, מריץ אותה על מסד הנתונים, ומראה את שניהם — גם המספרים וגם השאילתה שיצרה אותם. שום דבר לא 'קופסה שחורה'." |
| **4 · Reliability** (B6 / A6–A7) | 0:44–0:58 | Ask something with **no answer in the data** → the honest **"no matching rows"** message appears. (Optional: point at "read-only".) | "Ask something the data can't answer, and it says so — it never invents a number. And it can only read your data, never change it." | "שאלו משהו שאין עליו תשובה בנתונים — והוא אומר זאת במפורש. הוא לא ממציא מספרים. והוא רק קורא את הנתונים, אף פעם לא משנה אותם." |
| **5 · Privacy** (bottom-line fear #2) | 0:58–1:08 | Open the **AI Provider** panel — show **Mock / Claude API / Claude SDK**. Rest on **Mock** ("offline · no key"). | "Worried about your data? Run it fully offline, no API key. Or use Claude's API, which doesn't train on your data. It stays yours." | "חוששים לנתונים שלכם? אפשר להריץ לגמרי לא מקוון, בלי מפתח. או דרך ה‑API של Claude, שלא מתאמן על הנתונים שלכם. הם נשארים שלכם." |
| **6 · CTA** (B8) | 1:08–1:16 | Cut to the **Home dashboard** (clean overview) for one beat, then a plain end card with your name + contact. | "Want this on your business data? I build these. Let's talk." | "רוצים את זה על הנתונים של העסק שלכם? אני בונה כאלה. בואו נדבר." |

---

## Burned-in subtitles (B4 — assume sound off)

Keep lines short, high-contrast (white text, dark pill, WCAG ≥ 4.5:1). One line at a time:

1. Ask in plain Hebrew. · שואלים בעברית פשוטה.
2. The data: dozens of tables, thousands of rows. · הנתונים: עשרות טבלאות, אלפי שורות.
3. You ask — it writes the SQL and runs it. · אתם שואלים — הוא כותב SQL ומריץ.
4. See the query behind every answer. · רואים את השאילתה מאחורי כל תשובה.
5. No answer in the data? It says so. · אין תשובה בנתונים? הוא אומר.
6. Read-only. Never changes your data. · קריאה בלבד. לא משנה נתונים.
7. Offline, or Claude API — no training on your data. · לא מקוון, או Claude API — בלי אימון על הנתונים.
8. Want this on your data? Let's talk. · רוצים את זה על הנתונים שלכם? בואו נדבר.

---

## Recording settings (B5 / B9)

- **Tool:** OBS (free) or Loom; on Windows, **Rapidemo** / **FocuSee** add auto-zoom
  and smooth cursor. (There is no "Pane Studio".)
- **Audio > picture:** a decent mic in a quiet room matters more than 4K. Clean
  audio reads as professional.
- **Export:** 1080p, **~8 Mbit/s** (SDR, standard frame rate — YouTube's guideline).
- **Face on camera:** optional. A short talking-head intro can build trust for a
  cold touch, but a clean screen-only cut is fine — clear audio matters more.
- **Language:** record a **Hebrew** VO for the Israeli market and an **English**
  cut for international leads; burn in subtitles either way.

## Publishing (A11)

GitHub README does **not** embed video players. Publish the video on YouTube/Loom,
export a short **autoplay GIF** of shot 3 (ask → SQL → results) to `docs/demo.gif`,
and in `README.md` replace the hero screenshot with a linked GIF:

```md
[![Watch the 90-second demo](docs/demo.gif)](https://youtu.be/VIDEO_ID)
```

## Why these choices (playbook mapping)

- **B1 hook in 5 s** — open on the result, not a logo.
- **B2 length** — 75–90 s for cold touch; a 2–3 min cut for warm leads.
- **B3 one scenario, Problem→Solution→Next step** — a single fund question, start to finish.
- **B4 subtitles** — burned-in, high contrast (sound-off viewing).
- **B6 + A6/A7** — show the "no data" honesty and read-only safety; the SQL is the answer's source.
- **Privacy** — the Mock/API/SDK panel answers "will my data leak?" on screen.
- **B7 plain language** — short sentences, no jargon.
- **B8 one clear CTA** — a single next step at the end.
