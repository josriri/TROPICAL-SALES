# Claude × ChatKazi WhatsApp Bot

An AI-powered WhatsApp bot that uses Claude to automatically reply to messages via the ChatKazi API.

---

## How it works

1. Someone sends a WhatsApp message to your number
2. ChatKazi receives it and POSTs the payload to your `/webhook` endpoint
3. The server passes the message to Claude (with per-number conversation history)
4. Claude's reply is sent back to the sender via ChatKazi
5. The person receives Claude's response on WhatsApp

You can also trigger conversations manually via `POST /send`.

---

## Local setup

### 1. Install dependencies
```bash
npm install
```

### 2. Configure environment variables
```bash
cp .env.example .env
# Edit .env and fill in CHATKAZI_API_KEY and ANTHROPIC_API_KEY
```

### 3. Run locally
```bash
npm run dev
```
Server starts on `http://localhost:3000`

### 4. Test it
```bash
curl -X POST http://localhost:3000/send \
  -H "Content-Type: application/json" \
  -d '{"to": "254712345678", "text": "Hello!"}'
```

---

## Deploy to Render

### 1. Push to GitHub
```bash
git add .
git commit -m "Fix: corrected server, render config and env handling"
git push
```

### 2. Create a Web Service on Render
1. Go to [render.com](https://render.com) → **New → Web Service**
2. Connect your GitHub repo — Render auto-reads `render.yaml`
3. Under **Environment**, add:
   - `CHATKAZI_API_KEY` → your ChatKazi key
   - `ANTHROPIC_API_KEY` → your Anthropic key
4. Click **Deploy**

Your live URL will be:
```
https://chatkazi-claude-bot.onrender.com
```

### 3. Set the webhook in ChatKazi dashboard
```
https://chatkazi-claude-bot.onrender.com/webhook
```

---

## API reference

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/send` | Send a message + get Claude reply |
| `POST` | `/webhook` | ChatKazi calls this for incoming messages |
| `GET` | `/health` | Health check (used by Render) |
| `GET` | `/history/:phone` | View conversation history |
| `DELETE` | `/history/:phone` | Clear conversation for a number |

### POST /send body
```json
{
  "to": "254712345678",
  "text": "Your message here",
  "sessionId": "default"
}
```

---

## Notes

- Conversation history is in-memory and resets on restart. For persistence, replace the `conversations` map with Redis or SQLite.
- Render's free tier spins down after 15 min of inactivity. Use the **Starter** ($7/mo) plan for always-on uptime.
- To customise Claude's personality, update `SYSTEM_PROMPT` in Render's environment variables — no redeploy needed.
