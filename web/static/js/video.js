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

    /**
     * Callback called once the player is ready (for reference, see YouTube's iFrame API)
     */
    onReady() {
        this.msgContainer = document.getElementById('msg-container');
        this.msgInput = document.getElementById('msg-input');
        this.postButton = document.getElementById('msg-submit');
        this.vidChannel = this.socket.channel(`videos:${this.videoID}`);

        this.postButton.addEventListener('click', this.onPostButtonClicked.bind(this));
        this.msgContainer.addEventListener('click', this.onMsgContainerClicked.bind(this));
        
        this.bindVideoChannelEvents();
        this.joinVideoChannel();
    }

    /**
     * Binds a number of socket events to the video channel
     */
    bindVideoChannelEvents() {
        this.vidChannel.on('new_annotation', this.onNewAnnotationReceived.bind(this));
    }

    /**
     * Joins the video channel, setting success and error callbacks
     */
    joinVideoChannel() {
        this.vidChannel.join()
            .receive('ok', ({annotations}) => this.scheduleMessages(annotations))
            .receive('error', reason => console.log('join failed', reason));
    }

    /**
     * Callback called once a link on the message box was clicked
     * @param {Event} e - The click event
     */
    onMsgContainerClicked(e) {
        e.preventDefault()
        let seconds = e.target.getAttribute('data-seek') || e.target.parentNode.getAttribute('data-seek');
        // Return early if the seconds couldn't be found
        if (seconds == null) return

        this.player.seekTo(seconds)
    };

    /**
     * Callback called once the 'Post' button is clicked
     * @param {Event} e - The click event
     */
    onPostButtonClicked(e) {
        // Pushes a new annotation to the channel
        this.vidChannel.push('new_annotation', {
            body: this.msgInput.value,
            at: this.player.getCurrentTime()
        }).receive('error', e => console.log(e));

        // Clears the msgInput
        this.msgInput.value = '';
    }

    /**
     * Escapes a string (to prevent XSS attacks)
     * @param {String} str - The string to be escaped
     */
    escape(str) {
        let div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }

    /**
     * Callback called once an annotation is received from the channel
     * @param {Object} annotation - The received annotation
     */
    onNewAnnotationReceived(annotation) {
        this.renderAnnotation(annotation);
    }

    /**
     * Schedules an array of annotations for rendering
     * @param {Array} annotations - An array of annotations
     */
    scheduleMessages(annotations) {
        setTimeout(() => {
            let cTime = this.player.getCurrentTime();
            let remainingAnnotations = this.renderAtTime(annotations, cTime);
            this.scheduleMessages(remainingAnnotations);
        }, 1000);
    }

    /**
     * Iterates and filters an annoations array, filtering and rendering those whose
     * position is lesser or equal compared to the current video position
     * @param {Array} annotations - An array of annotations
     * @param {Number} seconds - The current position of the video
     */
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

    /**
     * Render an annotation to the annotation box
     * @param {string} user - The user who made the annotation 
     * @param {string} body - The body of the annotation
     * @param {number} at - When the annotatio was made
     */
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

    /**
     * Formats milliseconds to mm:ss
     * @param {Number} at - The location (in ms)
     */
    formatTime(at) {
        at = at / 1000;
        let params = ['en-US', {minimumIntegerDigits: 2, useGrouping:false}];
        let formatDigit = (digit) => Math.floor(digit).toLocaleString(...params);
        let minutes = formatDigit(at / 60);
        let seconds = formatDigit(at % 60);
        return `${minutes}:${seconds}`;
    }
}

export default Video