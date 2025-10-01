#!/usr/bin/env bash
#
# Build a static website from a JSON blob of the structure:
#   - line_i: { id, content, timestamp }
#
# Author: hxuu <an.mokhtari@esi-sba.dz>
# License: GPL

if (( $# < 1 )); then
    tput setaf 1
    echo 'Usage: $0 <file.json>' >&2
    tput sgr0
    exit 1
fi

mkdir -p "data/${1%/*}" "_site/${1%/*}"
./link-extractor.sh "$1" > "data/$1" || exit 1

input="data/$1"
output="_site/${1%.*}.html"

# start HTML
cat <<EOF > "$output"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>CTFdi</title>
  <style>
    :root {
        --primary: #ff2e63;   /* neon red/pink */
        --secondary: #162447;
        --accent: #08d9d6;    /* neon blue/cyan */
        --background: #0a0a0f;
        --surface: rgba(20, 20, 40, 0.9);
        --text: #e6f1ff;
    }

    body {
        font-family: 'Press Start 2P', monospace;
        background-color: var(--background);
        color: var(--text);
        margin: 0;
        padding: 20px;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        font-size: 14px; /* bigger font */
    }

    .chat {
        width: 100%;
        max-width: 800px;
        height: 500px;
        overflow-y: auto;
        background: var(--surface);
        border-radius: 8px;
        box-shadow: 0 0 25px rgba(255, 46, 99, 0.3);
        padding: 12px;
        display: flex;
        flex-direction: column-reverse;
    }

    .message {
        margin: 12px 0;
        padding: 10px;
        border-radius: 6px;
        background: rgba(15, 15, 25, 0.85);
        box-shadow: 0 0 6px rgba(8, 217, 214, 0.3);
        font-size: 14px;
        line-height: 1.5;
    }

    .timestamp {
        font-size: 11px;
        color: var(--primary); /* red timestamps */
        margin-bottom: 4px;
        display: block;
        opacity: 0.55;
    }

    #summary {
        width: 100%;
        max-width: 800px;
        margin: 30px auto;
        padding: 20px;
        background: var(--surface);
        line-height: 1.6;
        border-radius: 8px;
        box-shadow: 0 0 20px rgba(8, 217, 214, 0.3);
        font-size: 14px;
    }

    .content a {
        color: var(--accent); /* blue links */
        text-decoration: none;
        font-weight: bold;
    }

    .content a:hover {
        opacity: 0.8;
        text-decoration: underline;
    }

    /* CRT scanline effect */
    .scanline {
        background: linear-gradient(to bottom,
            rgba(255, 255, 255, 0) 0%,
            rgba(255, 255, 255, 0.05) 10%,
            rgba(255, 255, 255, 0) 100%);
        animation: scanline 8s linear infinite;
        pointer-events: none;
    }

    @keyframes scanline {
        0% { transform: translateY(-100%); }
        100% { transform: translateY(100%); }
    }
</style>
</head>
<body>
  <h1>Channel: [${input}]</h1>
  <h3>Writeup Chat</h3>
  <div id="chat" class="chat">
EOF

# loop messages (append inside chat container)
while read -r msg; do
    timestamp=$(echo "$msg" | jq -r '.timestamp')
    content=$(echo "$msg" | jq -r '.content')

    # escape HTML entities
    content=$(echo "$content" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

    # auto-link URLs
    content=$(echo "$content" | sed -E 's#(https?://[^ ]+)#<a href="\1" target="_blank">\1</a>#g')

    # fill message template inline
    cat <<EOF >> "$output"
    <div class="message">
      <span class="timestamp">$timestamp</span>
      <div class="content">$content</div>
    </div>
EOF
done < "$input"

# close chat container
echo "  </div>" >> "$output"

# build prompt for LLM to summarize
content=$(jq -r '.content' < "$input" | tr '\n' ' ')
prompt="Write a detailed, comprehensive, thorough and complex summary, while maintaining clarity and conciseness
of the following TEXT conversation. Format your response as HTML and only HTML and make sure your generated HTML doesn't mess the html around you.

TEXT START
"$content"
TEXT END
"

# generate LLM summary and append below chat
{
    echo '  <h3>Gemini Chat Summary</h3>'
    echo "  <section id=\"summary\">"
    gemini -p "$prompt" 2>/dev/null
    echo "  </section>"
} >> "$output"

# finish HTML (with JS for scroll-up behavior)
cat <<'EOF' >> "$output"
  <script>
    // Force chat to start at the bottom (newest messages)
    const chat = document.getElementById("chat");
    chat.scrollTop = chat.scrollHeight;
  </script>
</body>
</html>
EOF

echo "Generated $output"

