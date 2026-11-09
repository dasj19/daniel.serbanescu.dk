// Pronunciation links point straight at the MP3s, so they work without
// JavaScript. This script turns them into toggle buttons that play in place.

const player = new Audio();
player.preload = "none";
let current = null;

function setCurrent(control) {
    if (current) {
        current.classList.remove("playing");
        current.setAttribute("aria-pressed", "false");
    }
    current = control;
    if (current) {
        current.classList.add("playing");
        current.setAttribute("aria-pressed", "true");
    }
}

function stop() {
    player.pause();
    player.currentTime = 0;
    setCurrent(null);
}

function toggle(control) {
    if (current === control) {
        stop();
        return;
    }
    player.src = control.href;
    setCurrent(control);
    player.play().catch((error) => {
        // AbortError: playback was interrupted by stop() or another click
        if (error.name === "AbortError") return;
        if (current === control) setCurrent(null);
        console.warn(`Could not play ${control.href}:`, error);
    });
}

player.addEventListener("ended", () => setCurrent(null));
player.addEventListener("error", () => setCurrent(null));

document.querySelectorAll("a.play").forEach((control) => {
    control.setAttribute("role", "button");
    control.setAttribute("aria-pressed", "false");
    control.addEventListener("click", (event) => {
        event.preventDefault();
        toggle(control);
    });
    // Links activate on Enter only; buttons also activate on Space.
    control.addEventListener("keydown", (event) => {
        if (event.key === " " && !event.repeat) {
            event.preventDefault();
            toggle(control);
        }
    });
});
