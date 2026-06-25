function audioctl

	# =========================
	# PATHS
	# =========================
	set -l fifo ~/.config/mpd/mpd.fifo
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
				set -l parts (string split "=" $line)
				printf "%-10s : %s\n" $parts[1] $parts[2]
			end < $statefile
		else
			echo ""
			echo "EQ PROFILE : not set"
		end

		# ACTIVE EQ (SINKRONISASI BLOK SINKRONISASI PRINT DI SINI)
		if test -S "$sock"

			set -l graph (
			echo '{"command":["get_property","af"]}' \
				| socat - $sock \
				| jq -r '.data[0].params.graph'
			)

			if test "$graph" != "null"

				set -l limiter ""

				# Inisialisasi variabel penampung sesuai filter 6-band aktif Anda
				set -l g60 "";  set -l w60 ""
				set -l g90 "";  set -l w90 ""
				set -l g120 ""; set -l w120 ""
				set -l g350 ""; set -l w350 ""
				set -l g500 ""; set -l w500 ""
				set -l g8000 ""; set -l w8000 ""

				for item in (string split "," $graph)
					set item (string trim $item)

					if string match -q "equalizer=*" $item

						set -l freq (
						string match -r 'f=[0-9.]+' $item \
							| string replace 'f=' ''
						)

						set -l gain (
						string match -r 'g=-?[0-9.]+' $item \
							| string replace 'g=' ''
						)

						set -l width (
						string match -r 'width=[0-9.]+' $item \
							| string replace 'width=' ''
						)

						# Map data langsung dari filter lavfi mpv
						switch $freq
							case 60
								set g60 $gain; set w60 $width
							case 90
								set g90 $gain; set w90 $width
							case 120
								set g120 $gain; set w120 $width
							case 350
								set g350 $gain; set w350 $width
							case 500
								set g500 $gain; set w500 $width
							case 8000
								set g8000 $gain; set w8000 $width
						end

					else if string match -q "alimiter=*" $item
						set limiter (string replace 'alimiter=limit=' '' $item)
					end
				end

				echo ""
				echo "=== ACTIVE EQ STATUS ==="

				echo "Low-End"
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 60 $g60 $w60
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 90 $g90 $w90
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 120 $g120 $w120

				echo ""
				echo "Midrange"
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 350 $g350 $w350
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 500 $g500 $w500

				echo ""
				echo "Treble"
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 8000 $g8000 $w8000

				echo ""
				printf "Limiter : %.2f\n" $limiter
			end
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

		# --- RECOVERY EQ STATE ---
		# Default values jika statefile belum ada
		set -l bass 0
		set -l punch 0
		set -l treble 0
		set -l limiter 0.95

		if test -f "$statefile"
			while read -l line
				set -l parts (string split "=" $line)
				switch $parts[1]
					case bass
						set bass $parts[2]
					case punch
						set punch $parts[2]
					case treble
						set treble $parts[2]
					case limiter
						set limiter $parts[2]
				end
			end < $statefile
		end

		# Rekonstruksi filter lavfi sesuai state terakhir
		set -l f90 (math "$punch * 0.65")
		set -l f350 (math "$punch * 0.35")
		set -l f500 (math "$treble * 0.25")

		set -l filter "lavfi=[volume=-2dB,\
			equalizer=f=60:t=h:width=60:g=$bass,\
			equalizer=f=90:t=h:width=90:g=$f90,\
			equalizer=f=120:t=h:width=100:g=$punch,\
			equalizer=f=350:t=h:width=120:g=$f350,\
			equalizer=f=500:t=h:width=140:g=$f500,\
			equalizer=f=8000:t=h:width=2500:g=$treble,\
			alimiter=limit=$limiter]"
		# -------------------------

		echo "Starting MPV daemon..."


		mpv \
			--no-config \
			--no-video \
			--idle=yes \
			--keep-open=yes \
			--audio-buffer=0.05 \
			--input-ipc-server=$sock \
			--demuxer=rawaudio \
			--demuxer-rawaudio-channels=2 \
			--demuxer-rawaudio-rate=44100 \
			--demuxer-rawaudio-format=s16 \
			--audio-samplerate=44100 \
			--af="$filter" \
			--audio-stream-silence=yes \
			--msg-level=all=error \
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
		set -l f90 (math "$punch * 0.65")
		set -l f350 (math "$punch * 0.35")
		set -l f500 (math "$treble * 0.25")

		set -l filter "lavfi=[volume=-2dB,\
			equalizer=f=60:t=h:width=60:g=$bass,\
			equalizer=f=90:t=h:width=90:g=$f90,\
			equalizer=f=120:t=h:width=100:g=$punch,\
			equalizer=f=350:t=h:width=120:g=$f350,\
			equalizer=f=500:t=h:width=140:g=$f500,\
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
		# SAVE STATE & FORMAT PRINT (DIPERBAIKI DI SINI)
		# =========================
		echo "preset=$preset" > $statefile
		echo "bass=$bass" >> $statefile
		echo "punch=$punch" >> $statefile
		echo "treble=$treble" >> $statefile
		echo "limiter=$limiter" >> $statefile

		echo ""
		echo "PROFILE SET : $preset"
		echo ""
		echo "=== EQ PROFILE ==="
		printf "%-12s : %+d dB\n" "Bass" $bass
		printf "%-12s : %+d dB\n" "Punch" $punch
		printf "%-12s : %+d dB\n" "Treble" $treble
		printf "%-12s : %.2f\n" "Limiter" $limiter
		echo ""
		echo "Filter applied to MPV"
		echo ""
		return 0
	end

	# =========================
	# UNKNOWN COMMAND
	# =========================
	echo "Unknown command: $cmd"
	echo "Try: audioctl"

end

