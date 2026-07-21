---
layout: default
---

{% include icon-header.html %}

<div class="showcase">
    <div class="window">
        <div id="title" class="title">Friday 3 May 2024 at 11:11:15</div>
        <div id="container" class="container"></div>
    </div>
    <div id="source">
        <div>
            <strong>**Thoughts**</strong> is a lightweight note taking app for macOS.
        </div>
        <div>&nbsp;</div>
        <div>
            It’s for recording <em>_ephemeral_</em> notes. For when you just want to get something down and out of your head, happy in the knowledge that it’s recorded <em>_somewhere_</em>.
        </div>
        <div>&nbsp;</div>
        <div>
            Thoughts doesn’t offer any viewing functionality--it’s all about file-and-forget. It saves notes in <strong>**Markdown**</strong> and <strong>**Frontmatter**</strong> so it pairs perfectly with tools like <a href="https://obsidian.md" target="_blank">[Obsidian](https://obsidian.md)</a> and static site builders like <a href="https://jekyllrb.com" target="_blank">[Jekyll](https://jekyllrb.com)</a>, <a href="https://gohugo.io" target="_blank">[Hugo](https://gohugo.io)</a>, and <a href="https://incontext.app" target="_blank">[InContext](https://incontext.app)</a>.
        </div>
    </div>
</div>

<script>

    async function typeChildren(from, to) {
        const delay = ms => new Promise(res => setTimeout(res, ms));
        const isWhitespaceString = str => !/\S/.test(str)
        for (const child of from.childNodes) {

            console.log(child);
            console.log(child.nodeType)

            if (child.nodeType == Node.TEXT_NODE) {
                const text = child.nodeValue
                if (isWhitespaceString(text)) {
                    to.innerHTML += text
                } else {
                    for (const c of text) {
                        await delay(40);
                        console.log(c);
                        to.innerHTML += c;
                    }
                }
            } else {
                // Create a placeholder destination node to type in.
                var placeholder = document.createElement("span");
                to.appendChild(placeholder);

                // Type the contents.
                await typeChildren(child, placeholder);

                // Create the actual node and replace the placeholder node.
                placeholder.replaceWith(child.cloneNode(true));
            }
        }
    }

    function setTitle() {

        let title = document.getElementById("title");

        var now = new Date();
        const weekdays = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
        let weekday = weekdays[now.getDay()];

        const months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
        let month = months[now.getMonth()];

        var dd = now.getDate();
        var yyyy = now.getFullYear();
        var hours = now.getHours();
        var minutes = now.getMinutes().toString().padStart(2, '0');
        var seconds = now.getSeconds().toString().padStart(2, '0');

        title.innerHTML = weekday + ' ' + dd + ' ' + month + ' ' + yyyy + ' at ' + hours + ':' + minutes + ':' + seconds;
    }

    async function update() {
        let container = document.getElementById("source");
        let destination = document.getElementById("container");
        typeChildren(container, destination);
    }

    setTitle();
    update();

</script>

<div class="content">
    <ul class="features">
        <li>
            <p><img class="symbol" src="/images/tray.and.arrow.down.svg" /></p>
            <p><strong>Capture Your Ideas</strong></p>
            <p>Thoughts stores all your notes in a folder of your choosing so you can easily integrate it with your exiting workflows.</p>
        </li>
        <li>
            <p><img class="symbol" src="/images/location.svg" /></p>
            <p><strong>Remember Your Location</strong></p>
            <p>Thoughts can automatically store your location in Frontmatter so you never forget where you were when you had that important idea.</p>
        </li>
        <li>
            <p><img class="symbol" src="/images/menubar.arrow.up.rectangle.svg" /></p>
            <p><strong>Always Available</strong></p>
            <p>Thoughts lives in the Menu Bar, waiting for your notes.</p>
        </li>
        <li>
            <p><img class="symbol" src="/images/keyboard.svg" /></p>
            <p><strong>Keyboard First</strong></p>
            <p>Use global shortcuts to write and edit notes without taking your hands off the keyboard.</p>
        </li>
    </ul>
</div>
