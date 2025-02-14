videojs.registerPlugin('mobileControl', function () {
    var player = this;
    const videoContainer = player.el();
    // Mobil Kontrol Çubuğu
    const mobileControlDiv = document.createElement('div');
    mobileControlDiv.classList.add('mobile-vjs-control');


    mobileControlDiv.appendChild(player.controlBar.skipBackward.el())
    mobileControlDiv.appendChild(player.controlBar.playToggle.el());
    mobileControlDiv.appendChild(player.controlBar.skipForward.el())

    videoContainer.appendChild(mobileControlDiv);
    player.mobileControl = {
        el: () => mobileControlDiv
    };
});
videojs.registerPlugin('mobileControlTop', function () {
    var player = this;
    const videoContainer = player.el();


    // Üst Kontroller
    const topControlDiv = document.createElement('div');
    topControlDiv.classList.add('mobile-vjs-control-top');

    var mobileTitleBar = player.titleBar.el();
    mobileTitleBar.classList.add('mobile-vjs-title-bar');
    topControlDiv.appendChild(mobileTitleBar);
    topControlDiv.appendChild(player.controlBar.playbackRateMenuButton.el())
    topControlDiv.appendChild(player.controlBar.subsCapsButton.el())
    topControlDiv.appendChild(player.controlBar.audioTrackButton.el())
    topControlDiv.appendChild(player.controlBar.pictureInPictureToggle.el())
    player.controlBar.fullscreenToggle.hide();
    // topControlDiv.appendChild(player.controlBar.fullscreenToggle.el())
    topControlDiv.appendChild(createControlButton('vjs-fullscreen-control', null, 'Fullscreen', () => {
        var videoElement = player.el().querySelector('video');
        videoElement.webkitEnterFullscreen();
    }));

    let isFill = false;
    topControlDiv.appendChild(createControlButton('vjs-cover-control', null, 'Cover', () => {
        isFill = !isFill;
        player.setCover(isFill);
    }));
    videoContainer.appendChild(topControlDiv);


    player.mobileControlTop = {
        el: () => topControlDiv,
        addButton: (className, order, text, onClick) => topControlDiv.appendChild(createControlButton(className, order, text, onClick))
    };
});

// Video Kaplama Modunu Ayarlayan Plugin
videojs.registerPlugin('setCover', function (enable) {
    const videoContainer = this.el();
    videoContainer.classList.toggle('vjs-cover', enable);
});

// Dokunarak Geri/İleri Sarma Plugin'i
videojs.registerPlugin('setTouchTime', function (enable) {
    const player = this;
    const videoContainer = player.el();

    function handleTouch(event) {
        if (event.touches.length === 1) {
            const touchX = event.touches[0].clientX;
            const videoWidth = videoContainer.clientWidth;
            const seekTime = 5;

            if (touchX < videoWidth * 0.3) {
                player.currentTime(Math.max(0, player.currentTime() - seekTime));
            } else if (touchX > videoWidth * 0.7) {
                player.currentTime(Math.min(player.duration(), player.currentTime() + seekTime));
            }
        }
    }

    if (enable) {
        if (!videoContainer.hasTouchListener) {
            videoContainer.addEventListener('touchstart', handleTouch);
            videoContainer.hasTouchListener = true;
        }
    } else {
        videoContainer.removeEventListener('touchstart', handleTouch);
        videoContainer.hasTouchListener = false;
    }
});

// Yardımcı Fonksiyonlar
function createControlButton(className, order, text, onClick) {
    const button = document.createElement('button');
    button.className = `${className} vjs-control vjs-button`;
    if (order) {
        button.style.order = order;
    }

    const iconSpan = document.createElement('span');
    iconSpan.classList.add('vjs-icon-placeholder');
    button.appendChild(iconSpan);

    const textSpan = document.createElement('span');
    textSpan.classList.add('vjs-control-text');
    textSpan.innerText = text;
    button.appendChild(textSpan);

    button.addEventListener('click', onClick);
    return button;
}
