const player = new Audio();
player.preload = "none";
let current = null;

function setCurrent(button) {
    if (current) {
        current.classList.remove("playing");
        current.setAttribute("aria-pressed", "false");
    }
    current = button;
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

player.addEventListener("ended", () => setCurrent(null));
player.addEventListener("error", () => setCurrent(null));

document.querySelectorAll(".play:not(:disabled)").forEach((button) => {
    button.setAttribute("aria-pressed", "false");
    button.addEventListener("click", () => {
        if (current === button) {
            stop();
            return;
        }
        player.src = new URL(button.dataset.src, document.baseURI).href;
        setCurrent(button);
        player.play().catch((error) => {
            // AbortError: playback was interrupted by stop() or another click
            if (error.name === "AbortError") return;
            if (current === button) setCurrent(null);
            console.warn(`Could not play ${button.dataset.src}:`, error);
        });
    });
});
