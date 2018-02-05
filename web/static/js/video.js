import Player from './player'

class Video {
    constructor(socket, element) {
        this.playerID = element.getAttribute('data-player-id');
        this.videoID = element.getAttribute('data-id');
        this.socket = socket;
        socket.connect();

        // Displays the video to the user and bind this classes'
        // onReady callback to the video player
        this.player = new Player(element.id, this.playerID, this.onReady.bind(this));
        this.vidChannel = null;
    }

    onReady() {
        this.msgContainer = document.getElementById('msg-container');
        this.msgInput = document.getElementById('msg-input');
        this.postButton = document.getElementById('msg-submit');
        this.vidChannel = this.socket.channel(`videos:${this.videoID}`);

        this.postButton.addEventListener('click', this.onPostButtonClicked.bind(this));
        
        this.bindVideoChannelEvents();
        this.joinVideoChannel();
    }

    bindVideoChannelEvents() {
        this.vidChannel.on('new_annotation', this.onNewAnnotationReceived.bind(this));
    }

    joinVideoChannel() {
        this.vidChannel.join()
            .receive('ok', ({annotations}) => this.scheduleMessages(annotations))
            .receive('error', reason => console.log('join failed', reason));
    }

    onPostButtonClicked(e) {
        // Pushes a new annotation to the channel
        this.vidChannel.push('new_annotation', {
            body: this.msgInput.value,
            at: this.player.getCurrentTime()
        }).receive('error', e => console.log(e));

        // Clears the msgInput
        this.msgInput.value = '';
    }

    escape(str) {
        let div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }

    onNewAnnotationReceived(annotation) {
        this.renderAnnotation(annotation);
    }

    scheduleMessages(annotations) {
        setTimeout(() => {
            let cTime = this.player.getCurrentTime();
            let remainingAnnotations = this.renderAtTime(annotations, cTime);
            this.scheduleMessages(remainingAnnotations);
        }, 1000);
    }

    renderAtTime(annotations, seconds) {
        return annotations.filter(ann => {
            // Renders the annotation and remove it from the annotations array
            if (ann.at <= seconds) {
                this.renderAnnotation(ann);
                return false;
            }

            return true;
        });
    }

    renderAnnotation({user, body, at}) {
        let template = document.createElement('div');
        template.innerHTML = `
            <a href="#" data-seek="${this.escape(at)}">
            [${this.formatTime(at)}]
                <b>${this.escape(user.username)}</b>: ${this.escape(body)}
            </a>
        `

        this.msgContainer.appendChild(template);
        this.msgContainer.scrollTop = this.msgContainer.scrollHeight;
    }

    formatTime(at) {
        console.log(at);
        at = at / 1000;
        let params = ['en-US', {minimumIntegerDigits: 2, useGrouping:false}];
        let formatDigit = (digit) => Math.floor(digit).toLocaleString(...params);
        let minutes = formatDigit(at / 60);
        let seconds = formatDigit(at % 60);
        return `${minutes}:${seconds}`;
    }
}

export default Video