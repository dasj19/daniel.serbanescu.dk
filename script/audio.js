const player = new Audio();
player.preload = "none";
document.querySelectorAll(".play").forEach((button) => {
    button.addEventListener("click", () => {
        const src = new URL(button.dataset.src, document.baseURI).href;
        if (player.src === src && !player.paused) {
            player.pause();
            player.currentTime = 0;
            return;
        }
        player.src = src;
        player.play();
    });
});
