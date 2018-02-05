import Player from './player'

class Video {
    constructor(socket, element) {
        this.playerID = element.getAttribute('data-player-id');
        this.videoID = element.getAttribute('data-id');
        this.socket = socket;
        socket.connect();

        // Displays the video to the user and bind this classes'
        // onReady callback to the video player
        new Player(element.id, this.playerID, this.onReady.bind(this));
    }

    onReady() {
        let msgContainer = document.getElementById('msg-container');
        let msgInput = document.getElementById('msg-input');
        let postButton = document.getElementById('msg-submit');
        let vidChannel = this.socket.channel(`videos:${this.videoID}`);

        vidChannel.join()
            .receive('ok', resp => console.log('joined the video channel', resp))
            .receive('error', reason => console.log('join failed', reason));
    }
}

export default Video