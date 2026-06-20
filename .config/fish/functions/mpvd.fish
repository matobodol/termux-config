function mpvd

    set -l fifo "$HOME/.mpd/mpd.fifo"
    set -l sock "$HOME/.config/mpv/mpv.sock"

    # =========================
    # STOP
    # =========================
    if test "$argv[1]" = "stop"
        echo "Stopping MPD + MPV..."
        pkill mpv
        pkill mpd
        rm -f $sock
        return 0
    end

    # =========================
    # START MPD
    # =========================
    if not pgrep -x mpd >/dev/null
        echo "Starting MPD..."
        mpd
    end

    # =========================
    # WAIT FIFO
    # =========================
    while not test -p $fifo
        sleep 0.2
    end

    # small stabilization delay (anti underrun awal)
    sleep 0.5

    # =========================
    # START MPV DAEMON
    # =========================
    echo "Starting MPV daemon..."

    mpv \
        --no-video \
        --idle=yes \
        --keep-open=yes \
        --input-ipc-server="$sock" \
        --demuxer=rawaudio \
        --demuxer-rawaudio-channels=2 \
        --demuxer-rawaudio-rate=44100 \
        --demuxer-rawaudio-format=s16 \
        --audio-buffer=2 \
        --demuxer-readahead-secs=5 \
        --af="lavfi=[volume=volume=-2dB,alimiter=limit=0.95]" \
        "$fifo" &

    disown

    echo "mpvd ready (LEVEL 3 - CLEAN AUDIO ENGINE MODE)"

end
