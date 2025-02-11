videojs.registerPlugin('mobileUiPlugin', function () {
    var player = this;
    const videoContainer = player.el();

    // Mobil Kontrol Çubuğu
    const mobileControlDiv = document.createElement('div');
    mobileControlDiv.classList.add('mobile-vjs-control');

    // Geri Sar Butonu
    const rewindBtn = createControlButton('vjs-replay-control', 'Rewind', () => {
        player.currentTime(player.currentTime() - 10);
    });

    // İleri Sar Butonu
    const forwardBtn = createControlButton('vjs-forward-control', 'Forward', () => {
        player.currentTime(player.currentTime() + 10);
    });

    // Butonları ekleyelim
    mobileControlDiv.appendChild(rewindBtn);
    mobileControlDiv.appendChild(player.controlBar.playToggle.el());
    mobileControlDiv.appendChild(forwardBtn);
    videoContainer.appendChild(mobileControlDiv);

    // Üst Kontroller
    const topControlDiv = document.createElement('div');
    topControlDiv.classList.add('mobile-vjs-control-top');

    const closeBtn = createControlButton('vjs-close-control', 'Close', () => {

    });
    topControlDiv.appendChild(closeBtn);
    appendControlIfExists(topControlDiv, player.controlBar.subsCapsButton);
    appendControlIfExists(topControlDiv, player.controlBar.audioTrackButton);
    appendControlIfExists(topControlDiv, player.controlBar.pictureInPictureToggle);
    appendControlIfExists(topControlDiv, player.controlBar.fullscreenToggle);

    // Kaplama Butonu
    let isFill = false;
    const coverBtn = createControlButton('vjs-cover-control', 'Cover', () => {
        isFill = !isFill;
        player.setCover(isFill);
    });
    topControlDiv.appendChild(coverBtn);
    videoContainer.appendChild(topControlDiv);
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
function createControlButton(className, text, onClick) {
    const button = document.createElement('button');
    button.className = `${className} vjs-control vjs-button`;

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

function appendControlIfExists(parent, control) {
    if (control) {
        parent.appendChild(control.el());
    }
}