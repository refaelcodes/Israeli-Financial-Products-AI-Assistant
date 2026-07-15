import { spawnSync } from "node:child_process";
import { once } from "node:events";
import {
  copyFile,
  mkdir,
  readFile,
  stat,
  writeFile,
} from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { MsEdgeTTS, OUTPUT_FORMAT } from "msedge-tts";
import sharp from "sharp";

const OUT = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(OUT, "..");
const SCREENSHOTS = path.join(ROOT, "docs", "screenshots");
const ASSETS = path.join(OUT, "assets");
const W = 1920;
const H = 1080;
const CONTENT_H = 900;
const FPS = 30;

const COLORS = {
  bg: "#080b10",
  bg2: "#101722",
  panel: "#151b25",
  panel2: "#202733",
  border: "#303a49",
  ink: "#f5f7fb",
  muted: "#a7b0c0",
  faint: "#6c7585",
  blue: "#5b8cff",
  blue2: "#2f63d8",
  green: "#39cf91",
  amber: "#f5b942",
  red: "#f2777a",
};

const LANGS = {
  en: {
    voice: "en-US-GuyNeural",
    rtl: false,
    title: "English",
    scenes: [
      {
        slug: "01_hook",
        visual: "hook",
        target: 6.5,
        narration:
          "A question about pension funds, asked in plain Hebrew. Here is the answer, and the exact query behind it.",
        caption: "Ask in plain Hebrew.",
      },
      {
        slug: "02_holdings",
        visual: "holdings",
        target: 9,
        narration:
          "Israel's fund data is public, but it spans dozens of tables, Hebrew columns, and tens of thousands of rows.",
        caption: "The data: dozens of tables, thousands of rows.",
      },
      {
        slug: "03_funds",
        visual: "funds",
        target: 5,
        narration: "One simple question means writing SQL by hand.",
        caption: "One question usually means hand-written SQL.",
      },
      {
        slug: "04_ask",
        visual: "ask",
        target: 4,
        narration: "Now you just ask.",
        caption: "You ask — it writes the SQL and runs it.",
      },
      {
        slug: "05_sql",
        visual: "sql",
        target: 8.5,
        narration:
          "The assistant writes a read-only SQL query, and runs it on the database.",
        caption: "Read-only SQL, generated from the question.",
      },
      {
        slug: "06_results",
        visual: "results",
        target: 10,
        narration:
          "It shows you both: the numbers, and the query that produced them. Nothing is a black box.",
        caption: "See the query behind every answer.",
      },
      {
        slug: "07_no_data",
        visual: "no_data",
        target: 8,
        narration:
          "Ask something the data cannot answer, and it says so. It never invents a number.",
        caption: "No answer in the data? It says so.",
      },
      {
        slug: "08_read_only",
        visual: "read_only",
        target: 6,
        narration:
          "And it can only read your data, never change it.",
        caption: "Read-only. Never changes your data.",
      },
      {
        slug: "09_privacy",
        visual: "privacy",
        target: 11,
        narration:
          "Worried about your data? Run it fully offline, with no API key. Or use Claude's API, which does not train on your data. It stays yours.",
        caption: "Offline, or Claude API — no training on your data.",
      },
      {
        slug: "10_cta",
        visual: "cta",
        target: 7,
        narration:
          "Want this on your business data? I build these. Let's talk.",
        caption: "Want this on your data? Let's talk.",
      },
    ],
  },
  he: {
    voice: "he-IL-AvriNeural",
    rtl: true,
    title: "עברית",
    scenes: [
      {
        slug: "01_hook",
        visual: "hook",
        target: 6.5,
        narration:
          "שאלה על קרנות פנסיה — בעברית פשוטה. הנה התשובה, ואיתה השאילתה המדויקת שמאחוריה.",
        caption: "שואלים בעברית פשוטה.",
      },
      {
        slug: "02_holdings",
        visual: "holdings",
        target: 9,
        narration:
          "נתוני הקרנות בישראל ציבוריים — אבל אלו עשרות טבלאות, עמודות בעברית, ועשרות אלפי שורות.",
        caption: "הנתונים: עשרות טבלאות, אלפי שורות.",
      },
      {
        slug: "03_funds",
        visual: "funds",
        target: 5,
        narration: "שאלה אחת פשוטה דורשת לכתוב אס קיו אל ביד.",
        caption: "שאלה אחת דורשת בדרך כלל SQL ידני.",
      },
      {
        slug: "04_ask",
        visual: "ask",
        target: 4,
        narration: "עכשיו פשוט שואלים.",
        caption: "אתם שואלים — הוא כותב SQL ומריץ.",
      },
      {
        slug: "05_sql",
        visual: "sql",
        target: 8.5,
        narration:
          "העוזר כותב שאילתת אס קיו אל לקריאה בלבד, ומריץ אותה על מסד הנתונים.",
        caption: "SQL לקריאה בלבד, שנוצר מהשאלה.",
      },
      {
        slug: "06_results",
        visual: "results",
        target: 10,
        narration:
          "הוא מראה את שניהם — גם את המספרים וגם את השאילתה שיצרה אותם. שום דבר לא קופסה שחורה.",
        caption: "רואים את השאילתה מאחורי כל תשובה.",
      },
      {
        slug: "07_no_data",
        visual: "no_data",
        target: 8,
        narration:
          "שאלו משהו שאין עליו תשובה בנתונים — והוא אומר זאת במפורש. הוא לא ממציא מספרים.",
        caption: "אין תשובה בנתונים? הוא אומר.",
      },
      {
        slug: "08_read_only",
        visual: "read_only",
        target: 6,
        narration:
          "והוא רק קורא את הנתונים, אף פעם לא משנה אותם.",
        caption: "קריאה בלבד. לא משנה נתונים.",
      },
      {
        slug: "09_privacy",
        visual: "privacy",
        target: 11,
        narration:
          "חוששים לנתונים שלכם? אפשר להריץ לגמרי לא מקוון, בלי מפתח. או דרך האיי פי איי של קלוד, שלא מתאמן על הנתונים שלכם. הם נשארים שלכם.",
        caption: "לא מקוון, או Claude API — בלי אימון על הנתונים.",
      },
      {
        slug: "10_cta",
        visual: "cta",
        target: 7,
        narration:
          "רוצים את זה על הנתונים של העסק שלכם? אני בונה כאלה. בואו נדבר.",
        caption: "רוצים את זה על הנתונים שלכם? בואו נדבר.",
      },
    ],
  },
};

function esc(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function rtlAttrs(rtl, anchor = "start") {
  return rtl
    ? `direction="rtl" unicode-bidi="plaintext" text-anchor="${anchor}"`
    : `direction="ltr" text-anchor="${anchor}"`;
}

function textLines(lines, x, y, options = {}) {
  const {
    size = 36,
    color = COLORS.ink,
    weight = 600,
    gap = Math.round(size * 1.28),
    rtl = false,
    anchor = rtl ? "start" : "start",
    family = "Segoe UI, Arial, sans-serif",
    opacity = 1,
  } = options;
  return lines
    .map(
      (line, index) =>
        `<text x="${x}" y="${y + index * gap}" fill="${color}" font-family="${family}" font-size="${size}" font-weight="${weight}" opacity="${opacity}" ${rtlAttrs(rtl, anchor)}>${esc(line)}</text>`,
    )
    .join("");
}

function pill(x, y, width, text, options = {}) {
  const {
    fill = COLORS.blue,
    ink = "#ffffff",
    size = 24,
    rtl = false,
    stroke = "none",
  } = options;
  return `<g>
    <rect x="${x}" y="${y}" width="${width}" height="52" rx="26" fill="${fill}" stroke="${stroke}"/>
    <text x="${rtl ? x + width - 24 : x + 24}" y="${y + 35}" fill="${ink}" font-family="Segoe UI, Arial, sans-serif" font-size="${size}" font-weight="700" ${rtlAttrs(rtl, "start")}>${esc(text)}</text>
  </g>`;
}

function captionBand(text, rtl) {
  return `<g>
    <rect x="0" y="${CONTENT_H}" width="${W}" height="${H - CONTENT_H}" fill="#05080d" opacity="0.98"/>
    <rect x="${rtl ? W - 14 : 0}" y="${CONTENT_H}" width="14" height="${H - CONTENT_H}" fill="${COLORS.blue}"/>
    <rect x="160" y="938" width="1600" height="90" rx="45" fill="#151c26" stroke="#2f3948" stroke-width="2"/>
    <text x="${rtl ? 1690 : 230}" y="997" fill="#ffffff" font-family="Segoe UI, Arial, sans-serif" font-size="42" font-weight="700" ${rtlAttrs(rtl, "start")}>${esc(text)}</text>
  </g>`;
}

function svgShell(body, caption, rtl, background = true) {
  return Buffer.from(`<?xml version="1.0" encoding="UTF-8"?>
  <svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
    <defs>
      <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
        <stop offset="0" stop-color="#070a0f"/>
        <stop offset="0.55" stop-color="#111827"/>
        <stop offset="1" stop-color="#0b2630"/>
      </linearGradient>
      <linearGradient id="shade" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#000000" stop-opacity="0.62"/>
        <stop offset="0.28" stop-color="#000000" stop-opacity="0"/>
        <stop offset="1" stop-color="#000000" stop-opacity="0.14"/>
      </linearGradient>
      <filter id="shadow"><feDropShadow dx="0" dy="12" stdDeviation="18" flood-color="#000000" flood-opacity="0.36"/></filter>
    </defs>
    ${background ? `<rect width="${W}" height="${H}" fill="url(#bg)"/>` : ""}
    ${body}
    ${captionBand(caption, rtl)}
  </svg>`, "utf8");
}

async function screenshotScene(source, output, caption, rtl, label, labelWidth = 650) {
  const image = await sharp(source)
    .resize(W, CONTENT_H, { fit: "cover", position: "centre" })
    .modulate({ brightness: 0.94, saturation: 0.96 })
    .toBuffer();
  const labelX = rtl ? W - labelWidth - 42 : 42;
  const overlay = svgShell(
    `<rect x="0" y="0" width="${W}" height="${CONTENT_H}" fill="url(#shade)"/>
     ${pill(labelX, 32, labelWidth, label, { fill: "#0d1520", stroke: COLORS.blue, rtl, size: 23 })}`,
    caption,
    rtl,
    false,
  );
  await sharp({
    create: { width: W, height: H, channels: 3, background: COLORS.bg },
  })
    .composite([
      { input: image, left: 0, top: 0 },
      { input: overlay, left: 0, top: 0 },
    ])
    .png()
    .toFile(output);
}

async function focusScene(source, output, caption, rtl, mode) {
  const isSql = mode === "sql";
  const crop = isSql
    ? { left: 350, top: 70, width: 1660, height: 620 }
    : { left: 365, top: 650, width: 1640, height: 346 };
  const focus = await sharp(source)
    .extract(crop)
    .resize(1720, isSql ? 642 : 505, { fit: "fill" })
    .toBuffer();
  const title = isSql
    ? rtl
      ? "השאילתה המדויקת — גלויה לבדיקה"
      : "THE EXACT QUERY — VISIBLE AND AUDITABLE"
    : rtl
      ? "התוצאות החיות ממסד הנתונים"
      : "LIVE RESULTS FROM THE DATABASE";
  const question = "מהן 10 הקרנות עם התשואה הגבוהה ביותר?";
  const body = `<rect x="74" y="54" width="1772" height="790" rx="34" fill="${COLORS.panel}" stroke="${COLORS.border}" stroke-width="2" filter="url(#shadow)"/>
    ${pill(rtl ? 1230 : 112, 86, 575, title, { fill: COLORS.blue2, rtl, size: 21 })}
    <rect x="112" y="153" width="1696" height="72" rx="18" fill="#0e131b" stroke="#263142"/>
    <circle cx="${rtl ? 1755 : 158}" cy="189" r="14" fill="${COLORS.blue}"/>
    <text x="1718" y="199" fill="${COLORS.ink}" font-family="Segoe UI, Arial, sans-serif" font-size="28" font-weight="650" ${rtlAttrs(true, "start")}>${esc(question)}</text>
    <rect x="100" y="${isSql ? 238 : 270}" width="1720" height="${isSql ? 642 : 505}" rx="18" fill="#f5f7fb" stroke="#3c4656" stroke-width="2"/>
    ${isSql ? pill(rtl ? 115 : 1500, 772, 250, rtl ? "קריאה בלבד" : "READ-ONLY", { fill: COLORS.green, ink: "#07120d", rtl, size: 22 }) : pill(rtl ? 125 : 1500, 790, 250, rtl ? "10 שורות" : "10 ROWS", { fill: COLORS.green, ink: "#07120d", rtl, size: 22 })}`;
  const base = await sharp(svgShell(body, caption, rtl)).png().toBuffer();
  await sharp(base)
    .composite([{ input: focus, left: 100, top: isSql ? 238 : 270 }])
    .png()
    .toFile(output);
}

async function askScene(output, caption, rtl) {
  const title = rtl ? "שואלים בשפה רגילה" : "ASK IN PLAIN LANGUAGE";
  const subtitle = rtl
    ? "בלי לזכור שמות של טבלאות או עמודות"
    : "No table names or column names to remember";
  const body = `${textLines([title], rtl ? 1790 : 130, 115, { size: 58, weight: 750, rtl })}
    ${textLines([subtitle], rtl ? 1790 : 130, 165, { size: 27, color: COLORS.muted, weight: 450, rtl })}
    <rect x="120" y="225" width="1680" height="190" rx="28" fill="${COLORS.panel}" stroke="${COLORS.border}" stroke-width="2" filter="url(#shadow)"/>
    ${textLines([rtl ? "ספק בינה מלאכותית" : "AI Provider"], rtl ? 1745 : 175, 275, { size: 25, weight: 700, rtl })}
    ${pill(rtl ? 1450 : 175, 305, 325, rtl ? "Mock — לא מקוון" : "Mock — Offline", { fill: "#183a32", stroke: COLORS.green, rtl, size: 21 })}
    ${pill(rtl ? 1100 : 525, 305, 325, "Claude API", { fill: COLORS.panel2, stroke: COLORS.border, rtl, size: 21 })}
    ${pill(rtl ? 750 : 875, 305, 325, "Claude SDK", { fill: COLORS.panel2, stroke: COLORS.border, rtl, size: 21 })}
    ${pill(rtl ? 225 : 1450, 305, 220, rtl ? "מחובר" : "CONNECTED", { fill: COLORS.green, ink: "#07120d", rtl, size: 20 })}
    <rect x="120" y="455" width="1680" height="245" rx="28" fill="${COLORS.panel}" stroke="${COLORS.border}" stroke-width="2" filter="url(#shadow)"/>
    <rect x="175" y="530" width="1320" height="84" rx="18" fill="#f8fafc"/>
    <text x="1445" y="583" fill="#1a2431" font-family="Segoe UI, Arial, sans-serif" font-size="30" font-weight="600" direction="rtl" unicode-bidi="plaintext" text-anchor="start">${esc("10 הקרנות עם התשואה הגבוהה ביותר")}</text>
    <rect x="1525" y="530" width="220" height="84" rx="18" fill="${COLORS.blue}"/>
    <text x="1635" y="583" fill="#ffffff" font-family="Segoe UI, Arial, sans-serif" font-size="27" font-weight="750" text-anchor="middle">${rtl ? "שאל" : "Ask"}</text>
    <circle cx="${rtl ? 1745 : 175}" cy="490" r="10" fill="${COLORS.blue}"/>
    ${textLines([rtl ? "שאל שאלה על נתוני הקרנות" : "Ask a question about fund data"], rtl ? 1718 : 200, 499, { size: 22, color: COLORS.muted, weight: 500, rtl })}
    <path d="M 780 770 L 1140 770" stroke="${COLORS.blue}" stroke-width="4" stroke-linecap="round"/>
    <path d="M 1124 754 L 1142 770 L 1124 786" fill="none" stroke="${COLORS.blue}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
    ${textLines([rtl ? "עברית" : "HEBREW"], 650, 785, { size: 30, color: COLORS.ink, weight: 750, anchor: "middle" })}
    ${textLines(["SQL"], 1270, 785, { size: 30, color: COLORS.green, weight: 750, anchor: "middle" })}`;
  await sharp(svgShell(body, caption, rtl)).png().toFile(output);
}

async function noDataScene(output, caption, rtl) {
  const question = rtl
    ? "הצג קרן בשם שאינה קיימת"
    : "Show a fund whose name does not exist";
  const body = `${textLines([rtl ? "תשובה כנה כשאין נתונים" : "AN HONEST ANSWER WHEN DATA IS MISSING"], rtl ? 1790 : 130, 95, { size: 45, weight: 750, rtl })}
    <rect x="110" y="145" width="1700" height="675" rx="30" fill="${COLORS.panel}" stroke="${COLORS.border}" stroke-width="2" filter="url(#shadow)"/>
    ${pill(rtl ? 1490 : 155, 185, 245, rtl ? "נענה" : "ANSWERED", { fill: "#173b31", stroke: COLORS.green, ink: COLORS.green, rtl, size: 20 })}
    ${pill(rtl ? 1215 : 420, 185, 230, rtl ? "0 שורות" : "0 ROWS", { fill: "#182839", stroke: COLORS.blue, ink: "#78a1ff", rtl, size: 20 })}
    ${textLines([question], rtl ? 1735 : 165, 300, { size: 30, weight: 700, rtl })}
    <rect x="155" y="340" width="1610" height="245" rx="20" fill="#222832" stroke="#303947"/>
    ${textLines(["SQL Query"], rtl ? 1715 : 195, 382, { size: 21, color: COLORS.green, weight: 700, rtl })}
    ${textLines([
      'SELECT FUND_NAME, MANAGING_CORPORATION',
      'FROM "Gemel"',
      "WHERE FUND_NAME = '__NO_MATCH__'",
      'LIMIT 10;',
    ], 195, 430, { size: 25, color: "#d5dbe5", weight: 500, family: "Consolas, monospace", gap: 38 })}
    <rect x="155" y="620" width="1610" height="130" rx="20" fill="#10161e" stroke="#374151"/>
    <circle cx="${rtl ? 1710 : 210}" cy="685" r="22" fill="${COLORS.amber}"/>
    <text x="${rtl ? 1710 : 210}" y="694" fill="#15100a" font-family="Segoe UI" font-size="27" font-weight="800" text-anchor="middle">!</text>
    ${textLines(rtl
      ? ["אין שורות תואמות — השאילתה רצה בהצלחה", "ומסד הנתונים החזיר 0 שורות."]
      : ["No matching rows — the query ran successfully", "and the database returned 0 rows."], rtl ? 1655 : 255, 671, { size: 28, color: COLORS.ink, weight: 620, gap: 38, rtl })}`;
  await sharp(svgShell(body, caption, rtl)).png().toFile(output);
}

async function readOnlyScene(output, caption, rtl) {
  const labels = rtl
    ? ["שאלה", "שאילתת SELECT", "מסד נתונים"]
    : ["QUESTION", "SELECT QUERY", "DATABASE"];
  const body = `${textLines([rtl ? "בטיחות שנבנתה לתוך המערכת" : "SAFETY BUILT INTO THE PIPELINE"], rtl ? 1790 : 130, 105, { size: 48, weight: 750, rtl })}
    ${[
      [120, COLORS.blue, "?", labels[0]],
      [700, COLORS.green, "SQL", labels[1]],
      [1280, "#7d70f5", "DB", labels[2]],
    ].map(([x, color, icon, label]) => `<g>
      <rect x="${x}" y="225" width="520" height="270" rx="30" fill="${COLORS.panel}" stroke="${COLORS.border}" stroke-width="2" filter="url(#shadow)"/>
      <circle cx="${x + 260}" cy="315" r="58" fill="${color}"/>
      <text x="${x + 260}" y="330" fill="#ffffff" font-family="Segoe UI, Arial" font-size="${icon === "SQL" ? 29 : 43}" font-weight="800" text-anchor="middle">${icon}</text>
      <text x="${x + 260}" y="430" fill="${COLORS.ink}" font-family="Segoe UI, Arial" font-size="30" font-weight="720" text-anchor="middle">${esc(label)}</text>
    </g>`).join("")}
    <path d="M 650 360 L 680 360" stroke="${COLORS.blue}" stroke-width="6"/><path d="M 1230 360 L 1260 360" stroke="${COLORS.blue}" stroke-width="6"/>
    ${pill(165, 560, 450, "mode=ro", { fill: "#132d28", stroke: COLORS.green, ink: COLORS.green, size: 24 })}
    ${pill(735, 560, 450, "PRAGMA query_only = ON", { fill: "#132d28", stroke: COLORS.green, ink: COLORS.green, size: 22 })}
    ${pill(1305, 560, 450, "SELECT / WITH only", { fill: "#132d28", stroke: COLORS.green, ink: COLORS.green, size: 23 })}
    <rect x="260" y="680" width="1400" height="105" rx="25" fill="#321b22" stroke="${COLORS.red}" stroke-width="2"/>
    <text x="960" y="745" fill="#ffb1b3" font-family="Consolas, monospace" font-size="29" font-weight="700" text-anchor="middle">INSERT · UPDATE · DELETE · DROP · ALTER · CREATE — BLOCKED</text>`;
  await sharp(svgShell(body, caption, rtl)).png().toFile(output);
}

async function privacyScene(output, caption, rtl) {
  const cards = rtl
    ? [
        ["Mock", "לא מקוון · בלי מפתח", ["ללא רשת", "SQL דטרמיניסטי", "פועל על מסד הנתונים"]],
        ["Claude API", "מפתח Anthropic", ["הבנת שפה מלאה", "המפתח נשאר בשרת", "ללא אימון על הנתונים"]],
        ["Claude SDK", "מנוי Claude מקומי", ["מצב פיתוח", "חיבור מקומי", "ניתן להחלפה בזמן ריצה"]],
      ]
    : [
        ["Mock", "Offline · no key", ["Zero network calls", "Deterministic SQL", "Runs on the live database"]],
        ["Claude API", "Anthropic key", ["Full language understanding", "Key stays on the backend", "No training on your data"]],
        ["Claude SDK", "Local Claude subscription", ["Development mode", "Local connection", "Switch at runtime"]],
      ];
  const title = rtl ? "הנתונים שלכם נשארים שלכם" : "YOUR DATA STAYS YOURS";
  const body = `${textLines([title], rtl ? 1790 : 130, 100, { size: 50, weight: 760, rtl })}
    ${pill(rtl ? 1450 : 130, 135, 340, rtl ? "מחובר · Mock" : "CONNECTED · MOCK", { fill: "#16382f", stroke: COLORS.green, ink: COLORS.green, rtl, size: 21 })}
    ${cards.map((card, index) => {
      const x = 110 + index * 570;
      const selected = index === 0;
      const [name, hint, points] = card;
      return `<g>
        <rect x="${x}" y="235" width="520" height="545" rx="30" fill="${selected ? "#142521" : COLORS.panel}" stroke="${selected ? COLORS.green : COLORS.border}" stroke-width="${selected ? 4 : 2}" filter="url(#shadow)"/>
        <rect x="${x + 35}" y="275" width="${selected ? 150 : 215}" height="58" rx="22" fill="${selected ? COLORS.green : COLORS.blue2}"/>
        <text x="${rtl ? x + (selected ? 160 : 225) - 20 : x + 55}" y="314" fill="${selected ? "#07120d" : "#ffffff"}" font-family="Segoe UI, Arial" font-size="27" font-weight="800" ${rtlAttrs(rtl, "start")}>${esc(name)}</text>
        ${textLines([hint], rtl ? x + 475 : x + 35, 385, { size: 23, color: COLORS.muted, weight: 550, rtl })}
        ${points.map((point, pIndex) => `<g>
          <circle cx="${rtl ? x + 460 : x + 55}" cy="${470 + pIndex * 82}" r="18" fill="${selected ? COLORS.green : COLORS.blue}"/>
          <text x="${rtl ? x + 460 : x + 55}" y="${477 + pIndex * 82}" fill="#ffffff" font-family="Segoe UI" font-size="20" font-weight="800" text-anchor="middle">✓</text>
          ${textLines([point], rtl ? x + 425 : x + 88, 479 + pIndex * 82, { size: 23, color: COLORS.ink, weight: 600, rtl })}
        </g>`).join("")}
      </g>`;
    }).join("")}`;
  await sharp(svgShell(body, caption, rtl)).png().toFile(output);
}

async function ctaScene(output, caption, rtl) {
  const title = rtl ? "סקירת שוק הקרנות" : "FUND MARKET OVERVIEW";
  const question = rtl
    ? "רוצים את זה על הנתונים של העסק שלכם?"
    : "Want this on your business data?";
  const cta = rtl ? "בואו נדבר" : "LET'S TALK";
  const body = `<rect x="60" y="45" width="1800" height="800" rx="38" fill="${COLORS.panel}" stroke="${COLORS.border}" stroke-width="2" filter="url(#shadow)"/>
    ${textLines([title], rtl ? 1795 : 125, 110, { size: 27, color: COLORS.muted, weight: 700, rtl })}
    ${[
      ["~3,000", rtl ? "קרנות" : "FUNDS"],
      ["29", rtl ? "טבלאות נכסים" : "ASSET TABLES"],
      ["~24K", rtl ? "רשומות קרנות" : "FUND RECORDS"],
      ["READ-ONLY", rtl ? "שאילתות בטוחות" : "SAFE QUERIES"],
    ].map(([value, label], index) => {
      const x = 125 + index * 420;
      return `<g><rect x="${x}" y="155" width="375" height="155" rx="24" fill="#202836" stroke="#334054"/>
        <text x="${x + 28}" y="220" fill="${index === 3 ? COLORS.green : COLORS.ink}" font-family="Segoe UI, Arial" font-size="42" font-weight="800">${esc(value)}</text>
        <text x="${x + 28}" y="270" fill="${COLORS.muted}" font-family="Segoe UI, Arial" font-size="20" font-weight="650">${esc(label)}</text></g>`;
    }).join("")}
    <rect x="125" y="360" width="1670" height="405" rx="32" fill="#0c121b" stroke="${COLORS.blue}" stroke-width="3"/>
    ${textLines([question], rtl ? 1715 : 205, 470, { size: 48, weight: 760, rtl })}
    ${textLines([rtl ? "אני בונה מערכות AI ונתונים שאפשר לבדוק ולסמוך עליהן." : "I build AI and data systems you can inspect and trust."], rtl ? 1715 : 205, 535, { size: 27, color: COLORS.muted, weight: 500, rtl })}
    ${pill(rtl ? 1320 : 205, 590, 395, cta, { fill: COLORS.blue, rtl, size: 29 })}
    ${textLines(["Refael Myshiakov"], rtl ? 1130 : 650, 623, { size: 28, weight: 720, rtl })}
    ${textLines(["refael.mishiakov@gmail.com  ·  github.com/refaelcodes"], rtl ? 1130 : 650, 670, { size: 23, color: COLORS.muted, weight: 500, rtl })}`;
  await sharp(svgShell(body, caption, rtl)).png().toFile(output);
}

async function renderScene(lang, scene, output) {
  const { rtl } = LANGS[lang];
  const q = path.join(SCREENSHOTS, "client-questions.png");
  const h = path.join(SCREENSHOTS, "holdings.png");
  const f = path.join(SCREENSHOTS, "funds-gemel.png");
  switch (scene.visual) {
    case "hook":
      return screenshotScene(
        q,
        output,
        scene.caption,
        rtl,
        rtl ? "שאלה בעברית  ·  SQL  ·  תוצאות" : "HEBREW QUESTION  ·  SQL  ·  RESULTS",
        620,
      );
    case "holdings":
      return screenshotScene(
        h,
        output,
        scene.caption,
        rtl,
        rtl ? "29 טבלאות נכסים  ·  אלפי שורות" : "29 ASSET TABLES  ·  THOUSANDS OF ROWS",
        700,
      );
    case "funds":
      return screenshotScene(
        f,
        output,
        scene.caption,
        rtl,
        rtl ? "גמל + פנסיה  ·  עמודות בעברית" : "GEMEL + PENSIA  ·  HEBREW COLUMNS",
        650,
      );
    case "ask":
      return askScene(output, scene.caption, rtl);
    case "sql":
      return focusScene(q, output, scene.caption, rtl, "sql");
    case "results":
      return focusScene(q, output, scene.caption, rtl, "results");
    case "no_data":
      return noDataScene(output, scene.caption, rtl);
    case "read_only":
      return readOnlyScene(output, scene.caption, rtl);
    case "privacy":
      return privacyScene(output, scene.caption, rtl);
    case "cta":
      return ctaScene(output, scene.caption, rtl);
    default:
      throw new Error(`Unknown visual ${scene.visual}`);
  }
}

async function fileGood(file, minimum = 1000) {
  try {
    return (await stat(file)).size >= minimum;
  } catch {
    return false;
  }
}

async function synthesize(text, voice, output) {
  if (await fileGood(output, 5000)) return;
  let lastError;
  for (let attempt = 1; attempt <= 3; attempt += 1) {
    try {
      const tts = new MsEdgeTTS();
      await tts.setMetadata(
        voice,
        OUTPUT_FORMAT.AUDIO_24KHZ_48KBITRATE_MONO_MP3,
      );
      const { audioStream } = tts.toStream(text);
      const chunks = [];
      audioStream.on("data", (chunk) => chunks.push(Buffer.from(chunk)));
      await Promise.race([
        once(audioStream, "close"),
        once(audioStream, "end"),
        once(audioStream, "error").then(([error]) => Promise.reject(error)),
      ]);
      const audio = Buffer.concat(chunks);
      if (audio.length < 5000) throw new Error("TTS returned too little audio");
      await writeFile(output, audio);
      return;
    } catch (error) {
      lastError = error;
      if (attempt < 3) {
        await new Promise((resolve) => setTimeout(resolve, 1200 * attempt));
      }
    }
  }
  throw lastError;
}

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: options.cwd || OUT,
    encoding: "utf8",
    maxBuffer: 32 * 1024 * 1024,
  });
  if (result.status !== 0) {
    throw new Error(
      `${command} failed (${result.status})\n${result.stdout || ""}\n${result.stderr || ""}`,
    );
  }
  return (result.stdout || "").trim();
}

function duration(file) {
  return Number(
    run("ffprobe", [
      "-v",
      "error",
      "-show_entries",
      "format=duration",
      "-of",
      "default=noprint_wrappers=1:nokey=1",
      file,
    ]),
  );
}

function srtTime(seconds) {
  const total = Math.round(seconds * 1000);
  const hours = Math.floor(total / 3_600_000);
  const minutes = Math.floor((total % 3_600_000) / 60_000);
  const secs = Math.floor((total % 60_000) / 1000);
  const millis = total % 1000;
  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}:${String(secs).padStart(2, "0")},${String(millis).padStart(3, "0")}`;
}

async function buildLanguage(lang) {
  const config = LANGS[lang];
  const langDir = path.join(ASSETS, lang);
  const scenesDir = path.join(langDir, "scenes");
  const audioDir = path.join(langDir, "audio");
  const partsDir = path.join(langDir, "parts");
  await Promise.all([
    mkdir(scenesDir, { recursive: true }),
    mkdir(audioDir, { recursive: true }),
    mkdir(partsDir, { recursive: true }),
  ]);

  const slidePaths = [];
  const audioPaths = [];
  for (const [index, scene] of config.scenes.entries()) {
    const slide = path.join(scenesDir, `${scene.slug}.png`);
    const audio = path.join(audioDir, `${scene.slug}.mp3`);
    console.log(`[${lang}] ${index + 1}/${config.scenes.length} render ${scene.slug}`);
    await renderScene(lang, scene, slide);
    console.log(`[${lang}] ${index + 1}/${config.scenes.length} voice ${scene.slug}`);
    await synthesize(scene.narration, config.voice, audio);
    slidePaths.push(slide);
    audioPaths.push(audio);
  }

  const durations = audioPaths.map((audio, index) =>
    Math.max(config.scenes[index].target, duration(audio) + 0.75),
  );
  const parts = [];
  for (let index = 0; index < config.scenes.length; index += 1) {
    const scene = config.scenes[index];
    const seconds = durations[index];
    const frames = Math.ceil(seconds * FPS);
    const part = path.join(partsDir, `${scene.slug}.mp4`);
    const zoomRate = scene.visual === "holdings" || scene.visual === "funds" ? 0.0002 : 0.00011;
    const filter =
      `[0:v]scale=${W}:${H},` +
      `zoompan=z='min(zoom+${zoomRate},1.022)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=${frames}:s=${W}x${H}:fps=${FPS},` +
      `fade=t=in:st=0:d=0.28,fade=t=out:st=${Math.max(0, seconds - 0.38).toFixed(3)}:d=0.32,format=yuv420p[v];` +
      `[1:a]afade=t=in:st=0:d=0.12,afade=t=out:st=${Math.max(0, seconds - 0.32).toFixed(3)}:d=0.28,apad=whole_dur=${seconds.toFixed(3)}[a]`;
    console.log(`[${lang}] encode ${scene.slug} (${seconds.toFixed(1)}s)`);
    run("ffmpeg", [
      "-hide_banner",
      "-loglevel",
      "error",
      "-y",
      "-loop",
      "1",
      "-i",
      slidePaths[index],
      "-i",
      audioPaths[index],
      "-filter_complex",
      filter,
      "-map",
      "[v]",
      "-map",
      "[a]",
      "-t",
      seconds.toFixed(3),
      "-c:v",
      "libx264",
      "-preset",
      "medium",
      "-crf",
      "18",
      "-c:a",
      "aac",
      "-b:a",
      "192k",
      "-ar",
      "48000",
      "-movflags",
      "+faststart",
      part,
    ]);
    parts.push(part);
  }

  const concatPath = path.join(langDir, "concat.txt");
  await writeFile(
    concatPath,
    parts.map((file) => `file '${file.replaceAll("\\", "/")}'`).join("\n") + "\n",
    "utf8",
  );
  const voiceOnly = path.join(langDir, "voice-only.mp4");
  run("ffmpeg", [
    "-hide_banner",
    "-loglevel",
    "error",
    "-y",
    "-f",
    "concat",
    "-safe",
    "0",
    "-i",
    concatPath,
    "-c",
    "copy",
    "-movflags",
    "+faststart",
    voiceOnly,
  ]);

  const master = path.join(OUT, `israeli_funds_demo_${lang}.mp4`);
  run("ffmpeg", [
    "-hide_banner",
    "-loglevel",
    "error",
    "-y",
    "-i",
    voiceOnly,
    "-filter:a",
    "loudnorm=I=-16:TP=-1.5:LRA=11",
    "-c:v",
    "copy",
    "-c:a",
    "aac",
    "-b:a",
    "192k",
    "-ar",
    "48000",
    "-movflags",
    "+faststart",
    master,
  ]);

  const compact = path.join(OUT, `israeli_funds_demo_${lang}_github.mp4`);
  run("ffmpeg", [
    "-hide_banner",
    "-loglevel",
    "error",
    "-y",
    "-i",
    master,
    "-c:v",
    "libx264",
    "-preset",
    "slow",
    "-crf",
    "27",
    "-maxrate",
    "700k",
    "-bufsize",
    "1400k",
    "-c:a",
    "aac",
    "-b:a",
    "96k",
    "-ar",
    "48000",
    "-movflags",
    "+faststart",
    compact,
  ]);

  const srt = [];
  let cursor = 0;
  for (let index = 0; index < config.scenes.length; index += 1) {
    srt.push(
      String(index + 1),
      `${srtTime(cursor + 0.12)} --> ${srtTime(cursor + durations[index] - 0.18)}`,
      config.scenes[index].narration,
      "",
    );
    cursor += durations[index];
  }
  await writeFile(
    path.join(OUT, `israeli_funds_demo_${lang}.srt`),
    srt.join("\n"),
    "utf8",
  );
  await copyFile(slidePaths[0], path.join(OUT, `thumbnail_${lang}.png`));
  await makeContactSheet(slidePaths, path.join(OUT, `contact_sheet_${lang}.png`));
  return { master, compact, durations, total: cursor };
}

async function makeContactSheet(files, output) {
  const thumbW = 384;
  const thumbH = 216;
  const tiles = await Promise.all(
    files.map((file) => sharp(file).resize(thumbW, thumbH, { fit: "cover" }).png().toBuffer()),
  );
  await sharp({
    create: {
      width: thumbW * 5,
      height: thumbH * 2,
      channels: 3,
      background: COLORS.bg,
    },
  })
    .composite(
      tiles.map((input, index) => ({
        input,
        left: (index % 5) * thumbW,
        top: Math.floor(index / 5) * thumbH,
      })),
    )
    .png()
    .toFile(output);
}

async function makeGif(master, startSeconds) {
  const gif = path.join(ROOT, "docs", "demo.gif");
  const palette = path.join(ASSETS, "gif-palette.png");
  const vf = "setpts=0.64*PTS,fps=10,scale=800:-1:flags=lanczos";
  run("ffmpeg", [
    "-hide_banner",
    "-loglevel",
    "error",
    "-y",
    "-ss",
    startSeconds.toFixed(3),
    "-t",
    "14",
    "-i",
    master,
    "-vf",
    `${vf},palettegen=max_colors=128:stats_mode=diff`,
    palette,
  ]);
  run("ffmpeg", [
    "-hide_banner",
    "-loglevel",
    "error",
    "-y",
    "-ss",
    startSeconds.toFixed(3),
    "-t",
    "14",
    "-i",
    master,
    "-i",
    palette,
    "-lavfi",
    `${vf}[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle`,
    "-loop",
    "0",
    gif,
  ]);
  return gif;
}

async function main() {
  await mkdir(ASSETS, { recursive: true });
  console.log("Building English cut...");
  const en = await buildLanguage("en");
  console.log("Building Hebrew cut...");
  const he = await buildLanguage("he");
  const solutionStart = en.durations.slice(0, 3).reduce((a, b) => a + b, 0) + 0.5;
  console.log("Building README GIF...");
  const gif = await makeGif(en.master, solutionStart);
  const report = {
    generatedAt: new Date().toISOString(),
    englishSeconds: en.total,
    hebrewSeconds: he.total,
    files: {
      english: path.basename(en.master),
      englishCompact: path.basename(en.compact),
      hebrew: path.basename(he.master),
      hebrewCompact: path.basename(he.compact),
      gif: path.relative(ROOT, gif).replaceAll("\\", "/"),
    },
  };
  await writeFile(path.join(OUT, "build-report.json"), `${JSON.stringify(report, null, 2)}\n`, "utf8");
  console.log(JSON.stringify(report, null, 2));
}

main().catch((error) => {
  console.error(error.stack || error);
  process.exitCode = 1;
});
