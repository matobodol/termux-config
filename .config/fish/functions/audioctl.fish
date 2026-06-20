function audioctl

	# =========================
	# PATHS
	# =========================
	set -l fifo ~/.mpd/mpd.fifo
	set -l sock ~/.config/mpv/mpv.sock
	set -l statefile ~/.config/audioctl/state

	mkdir -p ~/.config/audioctl

	# =========================
	# HELP (NO ARGS)
	# =========================
	if test (count $argv) -eq 0
		echo ""
		echo "audioctl - unified audio system"
		echo ""
		echo "Usage:"
		echo "  audioctl start"
		echo "  audioctl stop"
		echo "  audioctl status"
		echo "  audioctl eq <preset|bass treble>"
		echo ""
		echo "Presets:"
		echo " flat vocal bass bassboost rock pop jazz classical acoustic movie gaming night"
		echo ""
		echo "Examples:"
		echo "  audioctl start"
		echo "  audioctl eq bassboost"
		echo "  audioctl eq 12 3"
		echo "  audioctl status"
		echo ""
		return 0
	end

	set -l cmd $argv[1]

	# =========================
	# STOP SYSTEM
	# =========================
	if test "$cmd" = "stop"
		echo "Stopping AUDIOCTL..."

		pkill mpv
		pkill mpd

		if test -e "$sock"
			rm -f $sock
		end

		echo "AUDIOCTL stopped"
		return 0
	end

	# =========================
	# STATUS (FULL)
	# =========================
	if test "$cmd" = "status"

		echo ""
		echo "=== AUDIOCTL STATUS ==="

		# MPD
		if pgrep -x mpd >/dev/null
			echo "MPD        : running"
		else
			echo "MPD        : stopped"
		end

		# MPV
		if test -S "$sock"
			echo "MPV        : running"
		else
			echo "MPV        : stopped"
		end

		# FIFO
		if test -p "$fifo"
			echo "FIFO       : ready"
		else
			echo "FIFO       : missing"
		end

		# STATE FILE
		if test -f "$statefile"
			echo ""
			echo "=== EQ PROFILE ==="
			while read -l line
				echo "  $line"
			end < $statefile
		else
			echo ""
			echo "EQ PROFILE : not set"
		end

		echo ""
		return 0
	end

	# =========================
	# START SYSTEM
	# =========================
	if test "$cmd" = "start"

		echo "Starting MPD..."

		if not pgrep -x mpd >/dev/null
			mpd
		end

		while not test -p $fifo
			sleep 0.2
		end

		mkdir -p ~/.config/mpv

		echo "Starting MPV daemon..."

		mpv \
			--no-video \
			--idle=yes \
			--keep-open=yes \
			--input-ipc-server=$sock \
			--demuxer=rawaudio \
			--demuxer-rawaudio-channels=2 \
			--demuxer-rawaudio-rate=44100 \
			--demuxer-rawaudio-format=s16 \
			--af="lavfi=[volume=-2dB]" \
			$fifo &

		disown

		echo "audioctl ready"
		return 0
	end

	# =========================
	# EQ ENGINE
	# =========================
	if test "$cmd" = "eq"

		if test (count $argv) -lt 2
			echo "Usage: audioctl eq <preset|bass treble>"
			return 1
		end

		if test "$argv[2]" = "list"
			echo ""
			echo "=== EQ PRESETS ==="
			echo "flat       : Bass  0 | Punch  0 | Treble  0"
			echo "vocal      : Bass -2 | Punch -1 | Treble  4"
			echo "bass       : Bass  8 | Punch  2 | Treble  0"
			echo "bassboost  : Bass 12 | Punch  4 | Treble  2"
			echo "rock       : Bass  6 | Punch  3 | Treble  5"
			echo "pop        : Bass  4 | Punch  3 | Treble  4"
			echo "jazz       : Bass  3 | Punch  1 | Treble  2"
			echo "classical  : Bass  1 | Punch  0 | Treble  3"
			echo "acoustic   : Bass  2 | Punch  0 | Treble  4"
			echo "movie      : Bass  8 | Punch  4 | Treble  4"
			echo "gaming     : Bass  6 | Punch  5 | Treble  6"
			echo "night      : Bass  3 | Punch  1 | Treble -2"
			echo ""
			echo "Manual:"
			echo "  audioctl eq <bass> <treble>"
			echo ""
			return 0
		end

		set -l bass 0
		set -l punch 0
		set -l treble 0
		set -l limiter 0.95
		set -l preset $argv[2]

		switch "$preset"

			case dj 
				set bass 6
				set punch 2
				set treble 0

			case flat
				set bass 0
				set punch 0
				set treble 0

			case vocal
				set bass -2
				set punch -1
				set treble 4

			case bass
				set bass 8
				set punch 2
				set treble 0

			case bassboost
				set bass 12
				set punch 4
				set treble 2

			case rock
				set bass 6
				set punch 3
				set treble 5

			case pop
				set bass 4
				set punch 3
				set treble 4

			case jazz
				set bass 3
				set punch 1
				set treble 2

			case classical
				set bass 1
				set punch 0
				set treble 3

			case acoustic
				set bass 2
				set punch 0
				set treble 4

			case movie
				set bass 8
				set punch 4
				set treble 4

			case gaming
				set bass 6
				set punch 5
				set treble 6

			case night
				set bass 3
				set punch 1
				set treble -2

			case '*'
				# manual mode
				if string match -rq '^-?[0-9]+(.[0-9]+)?$' -- $preset

					set bass $preset

					if test (count $argv) -ge 3
						set punch $argv[3]
					else
						set punch 0
					end

					if test (count $argv) -ge 4
						set treble $argv[4]
					else
						set treble 0
					end

					set preset manual

				else
					echo "Invalid preset or value: $preset"
					echo ""
					echo "Examples:"
					echo "  audioctl eq bassboost"
					echo "  audioctl eq rock"
					echo "  audioctl eq 12 4 2"
					echo ""
					echo "Format:"
					echo "  audioctl eq <bass> <punch> <treble>"
					return 1
				end
		end

		# =========================
		# BUILD FILTER
		# =========================
		set -l filter "lavfi=[volume=-2dB,\
			equalizer=f=60:t=h:width=60:g=$bass,\
			equalizer=f=90:t=h:width=50:g=$punch,\
			equalizer=f=120:t=h:width=90:g=$punch,\
			equalizer=f=8000:t=h:width=2500:g=$treble,\
			alimiter=limit=$limiter]"

		# =========================
		# APPLY VIA IPC
		# =========================
		if not test -S "$sock"
			echo "ERROR: mpv socket not running"
			return 1
		end

		echo "{\"command\":[\"set_property\",\"af\",\"$filter\"]}" \
			| socat - UNIX-CONNECT:$sock >/dev/null 2>&1


		# =========================
		# SAVE STATE
		# =========================
		echo "preset=$preset" > $statefile
		echo "bass=$bass" >> $statefile
		echo "punch=$punch" >> $statefile
		echo "treble=$treble" >> $statefile
		echo "limiter=$limiter" >> $statefile

		echo "PROFILE SET: $preset"
		echo "EQ -> Bass=$bass dB | Punch=$punch db | Treble=$treble dB"
		return 0
	end

	# =========================
	# UNKNOWN COMMAND
	# =========================
	echo "Unknown command: $cmd"
	echo "Try: audioctl"

end
