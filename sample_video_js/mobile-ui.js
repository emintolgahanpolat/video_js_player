// Player Mobile UI Initialization
function addMobileUI(player) {
    const video = player.el();


    const mobileControlDiv = document.createElement('div');
    mobileControlDiv.classList.add('mobile-vjs-controls');

    // Rewind button
    const rewindBtn = document.createElement('button');
    rewindBtn.className = 'vjs-replay-button vjs-control vjs-button';
    const rewindSpan = document.createElement('span')
    rewindSpan.classList.add('vjs-icon-placeholder')
    rewindBtn.appendChild(rewindSpan)
    const rewindContent = document.createElement('span')
    rewindContent.classList.add('vjs-control-text')
    rewindContent.innerText = "Rewind"
    rewindBtn.appendChild(rewindContent)

    rewindBtn.addEventListener('click', () => {
        player.currentTime(player.currentTime() - 10);
    });


    // Forward button
    const forwardBtn = document.createElement('button');
    forwardBtn.className = 'vjs-forward-button vjs-control vjs-button';
    const forwardSpan = document.createElement('span')
    forwardSpan.classList.add('vjs-icon-placeholder')
    forwardBtn.appendChild(forwardSpan)
    const forwardContent = document.createElement('span')
    forwardContent.classList.add('vjs-control-text')
    forwardContent.innerText = "Forward"
    forwardBtn.appendChild(forwardContent)

    forwardBtn.addEventListener('click', () => {
        player.currentTime(player.currentTime() + 10);
    });

    // Append buttons to controls div
    mobileControlDiv.appendChild(rewindBtn);
    mobileControlDiv.appendChild(player.controlBar.playToggle.el());
    mobileControlDiv.appendChild(forwardBtn);

    // Append controls to the video container
    video.appendChild(mobileControlDiv);


    // Top Controls Container
    const topControlDiv = document.createElement('div');
    topControlDiv.classList.add('mobile-vjs-controls-top');

    if (player.controlBar.subsCapsButton) {
        topControlDiv.appendChild(player.controlBar.subsCapsButton.el());
    }
    if (player.controlBar.audioTrackButton) {
        topControlDiv.appendChild(player.controlBar.audioTrackButton.el());
    }
    if (player.controlBar.pictureInPictureToggle) {
        topControlDiv.appendChild(player.controlBar.pictureInPictureToggle.el());
    }
    if (player.controlBar.fullscreenToggle) {
        topControlDiv.appendChild(player.controlBar.fullscreenToggle.el());
    }



    video.appendChild(topControlDiv);


}

