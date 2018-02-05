class Player {
    constructor(domID, playerID, onReady) {
        this.domID = domID;
        this.playerID = playerID;
        this.onReady = onReady;
        this.player = null;
        this.appendYoutubeIFrameAPItoHead();
    }

    appendYoutubeIFrameAPItoHead() {
        let youtubeScriptTag = document.createElement("script");
        youtubeScriptTag.src = "//www.youtube.com/iframe_api"
        document.head.appendChild(youtubeScriptTag);
        window.onYouTubeIframeAPIReady = this.onIframeReady.bind(this);
    }

    onIframeReady() {
        this.player = new YT.Player(this.domID, {
            height: '360',
            width: '420',
            videoId: this.playerID,
            events: {
                onReady: event => this.onReady(event),
                onStateChange: event => this.onPlayerStateChange(event)
            }
        });
    }

    onPlayerStateChange(event) {}
    
    getCurrentTime() {
        return Math.floor(this.player.getCurrentTime() * 1000)
    }

    seekTo(dest) {
        return this.player.seekTo(dest / 1000)
    }
}

export default Player