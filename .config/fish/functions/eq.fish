function eq

    set -l sock "$HOME/.config/mpv/mpv.sock"

    if not test -S $sock
        echo "MPV socket not found"
        return 1
    end

    # =========================
    # DEFAULT VALUES
    # =========================
    set -l bass 0
    set -l treble 0
    set -l limiter 0.95

    # =========================
    # PRESETS
    # =========================
    switch "$argv[1]"

        case list help
            echo ""
            echo "EQ presets:"
            echo "flat vocal bass bassboost rock pop jazz classical acoustic movie gaming night"
            echo "manual: eq <bass> <treble>"
            return 0

        case flat; set bass 0; set treble 0
        case vocal; set bass -2; set treble 4
        case bass; set bass 8; set treble 0
        case bassboost; set bass 12; set treble 2
        case rock; set bass 6; set treble 5
        case pop; set bass 4; set treble 4
        case jazz; set bass 3; set treble 2
        case classical; set bass 1; set treble 3
        case acoustic; set bass 2; set treble 4
        case movie; set bass 8; set treble 4
        case gaming; set bass 6; set treble 6
        case night; set bass 3; set treble -2

        case '*'
            if string match -rq '^-?[0-9]+(\.[0-9]+)?$' -- $argv[1]
                set bass $argv[1]

                if test (count $argv) -ge 2
                    if string match -rq '^-?[0-9]+(\.[0-9]+)?$' -- $argv[2]
                        set treble $argv[2]
                    else
                        echo "Invalid treble value"
                        return 1
                    end
                end
            else
                echo "Unknown preset: $argv[1]"
                return 1
            end
    end

    # =========================
    # SMOOTH FILTER ENGINE
    # (no enable=true, no dynamic crash)
    # =========================
    set -l filter "lavfi=[volume=-2dB,\
equalizer=f=60:t=h:width=100:g=$bass,\
equalizer=f=8000:t=h:width=4000:g=$treble,\
alimiter=limit=$limiter]"

    # =========================
    # APPLY (atomic replace)
    # =========================
    echo "{\"command\":[\"set_property\",\"af\",\"$filter\"]}" \
        | socat - UNIX-CONNECT:$sock

    echo "EQ -> Bass=$bass dB | Treble=$treble dB"

end
