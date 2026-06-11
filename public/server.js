// Load env app.use(express.json());
vars first — must be before any other imports
import { fileURLToPath } from "url";
import { dirname, join } from "path";
const __dirname = dirname(fileURLToPath(import.meta.url));
app.use(express.static(join(__dirname, "public")));
import "dotenv/config";
import express from "express";
import cors from "cors";
import Anthropic from "@anthropic-ai/sdk";

const app = express();

// Explicitly allow all origins including claude.ai artifacts
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));

// Handle preflight OPTIONS requests for all routes
app.options("*", cors());

app.use(express.json());

// ── Serve frontend ────────────────────────────────────────────────────────────
import { fileURLToPath } from "url";
import { dirname, join } from "path";
const __dirname = dirname(fileURLToPath(import.meta.url));
app.use(express.static(join(__dirname, "public")));

// ── Validate required env vars on startup ────────────────────────────────────
const REQUIRED = ["CHATKAZI_API_KEY", "ANTHROPIC_API_KEY"];
for (const key of REQUIRED) {
  if (!process.env[key]) {
    console.error(`Missing required environment variable: ${key}`);
    process.exit(1);
  }
}

const CHATKAZI_BASE = "https://api.chatkazi.app/api/v1";

// Initialise the Anthropic SDK — picks up ANTHROPIC_API_KEY automatically
const anthropic = new Anthropic();

// In-memory conversation history keyed by phone number
// NOTE: resets on server restart. For production, swap with Redis or SQLite.
const conversations = {};

// ── Helper: send a WhatsApp message via ChatKazi ─────────────────────────────
async function sendWhatsApp(to, text, sessionId = "default") {
  const res = await fetch(`${CHATKAZI_BASE}/messages/text`, {
    method: "POST",
    headers: {
      "x-api-key": process.env.CHATKAZI_API_KEY,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ sessionId, to, text }),
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(data.message || `ChatKazi error: ${res.status}`);
  }
  return data;
}

// ── Helper: get Claude AI reply with per-number conversation history ──────────
async function getClaudeReply(phone, userText) {
  if (!conversations[phone]) conversations[phone] = [];

  // Append incoming message
  conversations[phone].push({ role: "user", content: userText });

  // Keep last 20 turns to control token usage
  const history = conversations[phone].slice(-20);

  const response = await anthropic.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1000,
    system:
      process.env.SYSTEM_PROMPT ||
      "You are a helpful WhatsApp assistant. Keep replies concise and friendly, as if texting. Use plain text only — no markdown, no bullet points.",
    messages: history,
  });

  const reply = response.content.find((b) => b.type === "text")?.text ?? "";

  // Append Claude's reply to history
  conversations[phone].push({ role: "assistant", content: reply });

  return reply;
}

// ── POST /send ────────────────────────────────────────────────────────────────
// Trigger a conversation from your app / scripts.
// Body: { to: "254712345678", text: "Hello!", sessionId: "default" }
app.post("/send", async (req, res) => {
  const { to, text, sessionId } = req.body ?? {};

  if (!to || !text) {
    return res.status(400).json({ error: "Both 'to' and 'text' are required." });
  }

  try {
    // 1. Send the user's outgoing message via WhatsApp
    await sendWhatsApp(to, text, sessionId);

    // 2. Generate Claude's reply
    const reply = await getClaudeReply(to, text);

    // 3. Send Claude's reply via WhatsApp
    await sendWhatsApp(to, reply, sessionId);

    return res.json({ success: true, reply });
  } catch (err) {
    console.error("[/send]", err.message);
    return res.status(500).json({ error: err.message });
  }
});

// ── POST /webhook ─────────────────────────────────────────────────────────────
// Configure this URL in your ChatKazi dashboard.
// ChatKazi POSTs here whenever a WhatsApp message arrives.
app.post("/webhook", async (req, res) => {
  // Always respond 200 immediately so ChatKazi doesn't retry
  res.sendStatus(200);

  try {
    const body = req.body;
    console.log("[webhook] payload:", JSON.stringify(body, null, 2));

    // ChatKazi webhook fields — covers both flat and nested payload shapes
    const from =
      body?.from ??
      body?.sender ??
      body?.data?.from ??
      body?.message?.from ??
      body?.contact?.phone;

    const text =
      body?.text ??
      body?.body ??
      body?.message?.text?.body ??
      body?.data?.message?.text ??
      body?.message?.body;

    const sessionId = body?.sessionId ?? body?.session ?? "default";

    if (!from || !text) {
      console.log("[webhook] skipped — missing sender or text");
      return;
    }

    // Ignore messages sent by the bot itself to avoid loops
    if (body?.fromMe === true || body?.isFromMe === true) {
      console.log("[webhook] skipped — own message");
      return;
    }

    console.log(`[webhook] from=${from} text="${text}"`);

    const reply = await getClaudeReply(from, text);
    await sendWhatsApp(from, reply, sessionId);

    console.log(`[webhook] replied to ${from}: "${reply}"`);
  } catch (err) {
    console.error("[webhook] error:", err.message);
  }
});

// ── GET /health ───────────────────────────────────────────────────────────────
// Render pings this to confirm the service is alive.
app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// ── GET /history/:phone ───────────────────────────────────────────────────────
app.get("/history/:phone", (req, res) => {
  const history = conversations[req.params.phone] ?? [];
  res.json({ phone: req.params.phone, count: history.length, messages: history });
});

// ── DELETE /history/:phone ────────────────────────────────────────────────────
app.delete("/history/:phone", (req, res) => {
  delete conversations[req.params.phone];
  res.json({ cleared: true, phone: req.params.phone });
});

// ── Start ─────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`   POST /send      — trigger a conversation`);
  console.log(`   POST /webhook   — ChatKazi incoming messages`);
  console.log(`   GET  /health    — health check`);
});
