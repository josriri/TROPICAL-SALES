cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Claude × ChatKazi</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', system-ui, sans-serif; background: #0a0f0d; color: #e8f5e9; height: 100dvh; display: flex; flex-direction: column; }
    #setup { flex: 1; display: flex; align-items: center; justify-content: center; padding: 24px; }
    .setup-card { width: 100%; max-width: 440px; }
    .logo-wrap { text-align: center; margin-bottom: 36px; }
    .logo-icon { display: inline-flex; align-items: center; justify-content: center; width: 56px; height: 56px; border-radius: 16px; background: linear-gradient(135deg, #25d366 0%, #128c7e 100%); color: #fff; margin-bottom: 12px; }
    .logo-wrap h1 { color: #e8f5e9; font-size: 22px; font-weight: 700; margin-bottom: 6px; }
    .logo-wrap p { color: #5a7a62; font-size: 14px; }
    form { background: #111a14; border: 1px solid #1e2e22; border-radius: 16px; padding: 28px; display: flex; flex-direction: column; gap: 20px; }
    .field { display: flex; flex-direction: column; gap: 6px; }
    .field label { font-size: 12px; font-weight: 600; color: #5a7a62; letter-spacing: 0.06em; text-transform: uppercase; }
    .field input { background: #0d1710; border: 1px solid #1e3524; border-radius: 8px; padding: 10px 12px; color: #d4ead8; font-size: 14px; outline: none; font-family: inherit; width: 100%; }
    .field input:focus { border-color: #25d366; }
    #connect-btn { background: linear-gradient(135deg, #25d366 0%, #128c7e 100%); color: #fff; border: none; border-radius: 10px; padding: 13px; font-size: 15px; font-weight: 600; cursor: pointer; width: 100%; transition: opacity 0.2s; }
    #connect-btn:hover { opacity: 0.9; }
    #connect-btn:active { opacity: 0.8; }
    .setup-note { color: #2e4a34; font-size: 12px; text-align: center; margin-top: 16px; }
    #chat { flex: 1; display: none; flex-direction: column; height: 100dvh; }
    .chat-header { background: #111a14; border-bottom: 1px solid #1e2e22; padding: 14px 20px; display: flex; align-items: center; gap: 12px; flex-shrink: 0; }
    .avatar { width: 38px; height: 38px; border-radius: 50%; background: linear-gradient(135deg, #25d366 0%, #128c7e 100%); display: flex; align-items: center; justify-content: center; color: #fff; flex-shrink: 0; }
    .info .name { font-size: 15px; font-weight: 600; }
    .info .badge { font-size: 12px; color: #25d366; }
    .info { flex: 1; }
    .settings-btn { background: none; border: 1px solid #1e3524; border-radius: 8px; color: #25d366; font-size: 12px; padding: 6px 10px; cursor: pointer; font-family: inherit; transition: all 0.2s; }
    .settings-btn:hover { border-color: #25d366; }
    #messages { flex: 1; overflow-y: auto; padding: 20px; display: flex; flex-direction: column; gap: 12px; }
    #messages::-webkit-scrollbar { width: 4px; }
    #messages::-webkit-scrollbar-thumb { background: #1e3524; border-radius: 2px; }
    #messages::-webkit-scrollbar-track { background: transparent; }
    .msg-wrap-user { display: flex; justify-content: flex-end; }
    .msg-wrap-bot { display: flex; justify-content: flex-start; }
    .msg-wrap-system { display: flex; justify-content: center; }
    .bubble { max-width: 72%; padding: 10px 14px; font-size: 14px; line-height: 1.6; color: #d4ead8; word-wrap: break-word; overflow-wrap: break-word; }
    .bubble-user { background: #1a3a26; border: 1px solid #25d36640; border-radius: 14px 4px 14px 14px; }
    .bubble-bot { background: #1a2b1e; border: 1px solid #1e3524; border-radius: 4px 14px 14px 14px; }
    .bubble-system { background: #111a14; border: 1px solid #1e2e22; border-radius: 20px; font-size: 12px; color: #3a5a3e; padding: 4px 12px; max-width: 90%; text-align: center; }
    .bubble-label { font-size: 10px; color: #25d366; font-weight: 600; margin-bottom: 4px; letter-spacing: 0.05em; text-transform: uppercase; }
    .bubble-meta { font-size: 11px; color: #3a5a3e; margin-top: 4px; text-align: right; }
    .typing { display: flex; justify-content: flex-start; }
    .typing-inner { background: #1a2b1e; border: 1px solid #1e3524; border-radius: 4px 14px 14px 14px; padding: 12px 16px; display: flex; gap: 4px; align-items: center; }
    .dot { width: 6px; height: 6px; border-radius: 50%; background: #25d366; animation: pulse 1.2s ease-in-out infinite; opacity: 0.7; }
    .dot:nth-child(2) { animation-delay: 0.2s; }
    .dot:nth-child(3) { animation-delay: 0.4s; }
    @keyframes pulse { 0%,80%,100%{transform:scale(0.6);opacity:0.4} 40%{transform:scale(1);opacity:1} }
    .error-bar { background: #2a1010; border-top: 1px solid #4a2020; padding: 10px 20px; font-size: 13px; color: #ff8080; display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
    .error-bar button { background: none; border: none; color: #ff8080; cursor: pointer; font-size: 16px; padding: 0 4px; }
    .error-bar button:hover { opacity: 0.8; }
    .input-row { background: #111a14; border-top: 1px solid #1e2e22; padding: 14px 20px; display: flex; gap: 10px; align-items: flex-end; flex-shrink: 0; }
    #msg-input { flex: 1; background: #0d1710; border: 1px solid #1e3524; border-radius: 10px; padding: 10px 14px; color: #d4ead8; font-size: 14px; resize: none; outline: none; font-family: inherit; line-height: 1.4; max-height: 120px; }
    #msg-input:focus { border-color: #25d366; }
    #send-btn { width: 42px; height: 42px; border: none; border-radius: 10px; background: linear-gradient(135deg, #25d366 0%, #128c7e 100%); color: #fff; cursor: pointer; display: flex; align-items: center; justify-content: center; flex-shrink: 0; transition: opacity 0.2s; }
    #send-btn:hover:not(:disabled) { opacity: 0.9; }
    #send-btn:active:not(:disabled) { opacity: 0.8; }
    #send-btn:disabled { background: #1e2e22; color: #3a5a3e; cursor: not-allowed; }
    @media (max-width: 480px) {
      .bubble { max-width: 85%; }
      .setup-card { max-width: 100%; }
      .field label { font-size: 11px; }
    }
  </style>
</head>
<body>
<div id="setup">
  <div class="setup-card">
    <div class="logo-wrap">
      <div class="logo-icon">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
          <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.149-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.297-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.501-.67-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.076 4.487.709.306 1.262.489 1.694.626.712.228 1.36.196 1.871.119.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421-7.403h-.004c-3.183 0-5.778 2.591-5.778 5.771 0 1.138.336 2.243.977 3.181l-1.039 3.783 3.861-1.014c.93.564 1.995.86 3.08.86h.004c3.184 0 5.778-2.592 5.778-5.772 0-1.54-.631-2.99-1.778-4.08-1.148-1.092-2.673-1.691-4.301-1.691"/>
        </svg>
      </div>
      <h1>Claude × ChatKazi</h1>
      <p>AI-powered WhatsApp responses</p>
    </div>
    <form id="setup-form">
      <div class="field">
        <label>Recipient Phone Number</label>
        <input id="phone" type="text" placeholder="254712345678 (with country code)" required />
      </div>
      <div class="field">
        <label>Session ID</label>
        <input id="session" type="text" placeholder="default" value="default" />
      </div>
      <button type="submit" id="connect-btn">Start Chatting →</button>
    </form>
    <p class="setup-note">API keys are secured on the server — nothing sensitive here.</p>
  </div>
</div>

<div id="chat">
  <div class="chat-header">
    <div class="avatar">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.149-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.297-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.501-.67-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.076 4.487.709.306 1.262.489 1.694.626.712.228 1.36.196 1.871.119.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421-7.403h-.004c-3.183 0-5.778 2.591-5.778 5.771 0 1.138.336 2.243.977 3.181l-1.039 3.783 3.861-1.014c.93.564 1.995.86 3.08.86h.004c3.184 0 5.778-2.592 5.778-5.772 0-1.54-.631-2.99-1.778-4.08-1.148-1.092-2.673-1.691-4.301-1.691"/>
      </svg>
    </div>
    <div class="info">
      <div class="name">Claude WhatsApp Bot</div>
      <div class="badge" id="header-badge">● Live</div>
    </div>
    <button class="settings-btn" id="back-btn">⚙ Settings</button>
  </div>
  <div id="messages"></div>
  <div id="error-bar" style="display:none" class="error-bar">
    <span id="error-text"></span>
    <button type="button" onclick="document.getElementById('error-bar').style.display='none'">✕</button>
  </div>
  <div class="input-row">
    <textarea id="msg-input" rows="1" placeholder="Type a message…"></textarea>
    <button id="send-btn" type="button" disabled>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="m22 2-7 20-4-9-9-4Z"></path>
        <path d="M22 2 11 13"></path>
      </svg>
    </button>
  </div>
</div>

<script>
  let recipientPhone = "", sessionId = "default", sending = false;
  const setupEl = document.getElementById("setup");
  const chatEl  = document.getElementById("chat");
  const msgsEl  = document.getElementById("messages");
  const inputEl = document.getElementById("msg-input");
  const sendBtn = document.getElementById("send-btn");
  const errBar  = document.getElementById("error-bar");
  const errText = document.getElementById("error-text");

  // Setup form submission
  document.getElementById("setup-form").addEventListener("submit", (e) => {
    e.preventDefault();
    recipientPhone = document.getElementById("phone").value.trim();
    if (!recipientPhone) {
      alert("Please enter a phone number");
      return;
    }
    sessionId = document.getElementById("session").value.trim() || "default";
    setupEl.style.display = "none";
    chatEl.style.display  = "flex";
    document.getElementById("header-badge").textContent = "● Live · → " + recipientPhone;
    addSystemMsg("Claude is live. Send a message below.");
    inputEl.focus();
  });

  // Back button
  document.getElementById("back-btn").addEventListener("click", () => {
    chatEl.style.display  = "none";
    setupEl.style.display = "flex";
    msgsEl.innerHTML = "";
  });

  // Input handling
  inputEl.addEventListener("input", () => {
    sendBtn.disabled = !inputEl.value.trim() || sending;
    inputEl.style.height = "auto";
    inputEl.style.height = Math.min(inputEl.scrollHeight, 120) + "px";
  });

  // Enter to send
  inputEl.addEventListener("keydown", (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  });

  sendBtn.addEventListener("click", handleSend);

  async function handleSend() {
    const text = inputEl.value.trim();
    if (!text || sending) return;

    sending = true;
    sendBtn.disabled = true;
    errBar.style.display = "none";

    const userDiv = addMsg("user", text, "sending…");
    inputEl.value = "";
    inputEl.style.height = "auto";
    const typingDiv = addTyping();

    try {
      const res = await fetch("/send", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ to: recipientPhone, text, sessionId }),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Server error");

      userDiv.querySelector(".bubble-meta").textContent = "✓ sent";
      typingDiv.remove();
      addMsg("bot", data.reply, "✓ received");
    } catch (err) {
      userDiv.querySelector(".bubble-meta").textContent = "⚠ failed";
      typingDiv.remove();
      errText.textContent = err.message;
      errBar.style.display = "flex";
    } finally {
      sending = false;
      sendBtn.disabled = !inputEl.value.trim();
    }
  }

  function addMsg(role, text, meta) {
    const wrap = document.createElement("div");
    wrap.className = "msg-wrap-" + (role === "user" ? "user" : "bot");
    const bubbleClass = role === "user" ? "bubble-user" : "bubble-bot";
    const label = role === "bot" ? '<div class="bubble-label">CLAUDE AI</div>' : "";
    wrap.innerHTML = `<div class="bubble ${bubbleClass}">${label}<div>${escHtml(text)}</div><div class="bubble-meta">${escHtml(meta)}</div></div>`;
    msgsEl.appendChild(wrap);
    msgsEl.scrollTop = msgsEl.scrollHeight;
    return wrap;
  }

  function addSystemMsg(text) {
    const wrap = document.createElement("div");
    wrap.className = "msg-wrap-system";
    wrap.innerHTML = `<div class="bubble bubble-system">${escHtml(text)}</div>`;
    msgsEl.appendChild(wrap);
    msgsEl.scrollTop = msgsEl.scrollHeight;
  }

  function addTyping() {
    const wrap = document.createElement("div");
    wrap.className = "typing";
    wrap.innerHTML = `<div class="typing-inner"><div class="dot"></div><div class="dot"></div><div class="dot"></div></div>`;
    msgsEl.appendChild(wrap);
    msgsEl.scrollTop = msgsEl.scrollHeight;
    return wrap;
  }

  function escHtml(str) {
    const div = document.createElement("div");
    div.textContent = str;
    return div.innerHTML
      .replace(/\n/g, "<br>")
      .replace(/  /g, "&nbsp;&nbsp;");
  }
</script>
</body>
</html>
EOF

# 4. Push both files
git add public/index.html server.js
git commit -m "Add frontend UI served from Express"
git push
