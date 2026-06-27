function mplay 

	# =========================
	# PATHS & CONSTANTS
	# =========================
	set -l fifo ~/.config/mpd/mpd.fifo
	set -l sock ~/.config/mpv/mpv.sock
	set -l statefile ~/.config/audioctl/state

	mkdir -p ~/.config/audioctl

	# Helper function internal untuk membangun string filter lavfi (DRY Principle)
	function _audioctl_build_filter -d "Membangun argumen filter lavfi untuk mpv"
		argparse 'bass=' 'punch=' 'treble=' 'limiter=' -- $argv
		or return 1

		set -l f90  (math "$_flag_punch * 0.50")
		set -l f350 (math "$_flag_punch * 0.15")
		set -l f500 (math "$_flag_treble * 0.10")

		set -l max_gain (math "max($_flag_bass, $_flag_punch, $_flag_treble)")
		set -l preamp (math "-0.5 * $max_gain")
		set -l volume_filter (printf "volume=%sdB" "$preamp")

		string join "" \
			"lavfi=[$volume_filter," \
			"equalizer=f=63:t=h:width=60:g=$_flag_bass," \
			"equalizer=f=90:t=h:width=90:g=$f90," \
			"equalizer=f=120:t=h:width=100:g=$_flag_punch," \
			"equalizer=f=350:t=h:width=120:g=$f350," \
			"equalizer=f=500:t=h:width=140:g=$f500," \
			"equalizer=f=8000:t=h:width=2500:g=$_flag_treble," \
			"alimiter=limit=$_flag_limiter]"
	end

	# Helper function untuk membaca statefile ke variabel lokal secara dinamis
	function _audioctl_load_state -S
		# Default values jika statefile tidak ada atau corrupt
		set -g _state_bass 0
		set -g _state_punch 0
		set -g _state_treble 0
		set -g _state_limiter 0.95
		set -g _state_preset unknown

		if test -f "$statefile"
			while read -l line
				set -l parts (string split -m 1 "=" $line)
				test (count $parts) -eq 2; or continue
				set -g "_state_$parts[1]" $parts[2]
			end < $statefile
		end
	end

	# =========================
	# HELP (NO ARGS)
	# =========================
	if test (count $argv) -eq 0
		echo -e "\naudioctl - unified audio system\n"
		echo "Usage:"
		echo "  audioctl start"
		echo "  audioctl stop"
		echo "  audioctl status"
		echo "  audioctl eq <preset|bass punch treble>"
		echo ""
		echo "Presets:"
		echo "  flat vocal bass bassboost rock pop jazz classical acoustic movie gaming night"
		echo ""
		echo "Examples:"
		echo "  audioctl start"
		echo "  audioctl eq bassboost"
		echo "  audioctl eq 12 4 2"
		echo "  audioctl status\n"
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
		rm -f $sock
		echo "AUDIOCTL stopped"
		return 0
	end

	# =========================
	# STATUS (FULL)
	# =========================
	if test "$cmd" = "status"
		echo -e "\n=== AUDIOCTL STATUS ==="

		pgrep -x mpd >/dev/null; and echo "MPD        : running"; or echo "MPD        : stopped"
		test -S "$sock"; and echo "MPV        : running"; or echo "MPV        : stopped"
		test -p "$fifo"; and echo "FIFO       : ready"; or echo "FIFO       : missing"

		if test -f "$statefile"
			echo -e "\n=== EQ PROFILE ==="
			while read -l line
				set -l parts (string split -m 1 "=" $line)
				printf "%-10s : %s\n" $parts[1] $parts[2]
			end < $statefile
		else
			echo -e "\nEQ PROFILE : not set"
		end

		if test -S "$sock"
			set -l graph (echo '{"command":["get_property","af"]}' | socat - $sock 2>/dev/null | jq -r '.data[0].params.graph' 2>/dev/null)

			if test -n "$graph" -a "$graph" != "null"
				set -l limiter ""
				set -l preamp ""
				set -l g63 "";   set -l w63 ""
				set -l g90 "";   set -l w90 ""
				set -l g120 "";  set -l w120 ""
				set -l g350 "";  set -l w350 ""
				set -l g500 "";  set -l w500 ""
				set -l g8000 ""; set -l w8000 ""

				for item in (string split "," $graph)
					set item (string trim $item)
					if string match -q "equalizer=*" $item
						set -l freq (string match -r 'f=[0-9.]+' $item | string replace 'f=' '')
						set -l gain (string match -r 'g=-?[0-9.]+' $item | string replace 'g=' '')
						set -l width (string match -r 'width=[0-9.]+' $item | string replace 'width=' '')

						switch $freq
							case 63;   set g63 $gain;   set w63 $width
							case 90;   set g90 $gain;   set w90 $width
							case 120;  set g120 $gain;  set w120 $width
							case 350;  set g350 $gain;  set w350 $width
							case 500;  set g500 $gain;  set w500 $width
							case 8000; set g8000 $gain; set w8000 $width
						end
					else if string match -q "volume=*" $item
						set preamp (string replace 'volume=' '' $item | string replace 'dB' '')
					else if string match -q "alimiter=*" $item
						set limiter (string replace 'alimiter=limit=' '' $item)
					end
				end

				echo -e "\n=== ACTIVE EQ STATUS ==="
				printf "Pre-Amp    : %s dB\n\n" $preamp
				echo "Low-End"
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 63 $g63 $w63
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 90 $g90 $w90
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 120 $g120 $w120
				echo -e "\nMidrange"
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 350 $g350 $w350
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 500 $g500 $w500
				echo -e "\nTreble"
				printf "  %5s Hz : %+0.2f dB  (w=%s)\n" 8000 $g8000 $w8000
				echo ""
				printf "Limiter    : %.2f\n" $limiter
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
		pgrep -x mpd >/dev/null; or mpd

		while not test -p $fifo
			sleep 0.2
		end

		mkdir -p ~/.config/mpv

		# Recovery state menggunakan helper function
		_audioctl_load_state
		set -l filter (_audioctl_build_filter --bass $_state_bass --punch $_state_punch --treble $_state_treble --limiter $_state_limiter)

		echo "Starting MPV daemon..."
		mpv \
			--no-config --no-video \
			--idle=yes \
			--keep-open=yes \
			--audio-buffer=0 \
			--cache=no \
			--input-ipc-server=$sock \
			--demuxer=rawaudio \
			--demuxer-rawaudio-channels=2 \
			--demuxer-rawaudio-rate=44100 \
			--demuxer-rawaudio-format=s16 \
			--audio-samplerate=44100 \
			--af="$filter" --audio-stream-silence=yes --msg-level=all=error \
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
			echo "Usage: audioctl eq <preset|bass punch treble>"
			return 1
		end

		# Data map preset dikelompokkan agar mudah di-maintenance (Format: preset_name bass punch treble)
		set -l presets_matrix \
			"flat 0 0 0" \
			"vocal -2 -1 4" \
			"bass 8 2 0" \
			"bassboost 12 4 2" \
			"rock 6 3 5" \
			"pop 4 3 4" \
			"jazz 3 1 2" \
			"classical 1 0 3" \
			"acoustic 2 0 4" \
			"movie 8 4 4" \
			"gaming 6 5 6" \
			"night 3 1 -2" \
			"dj 6 2 0"

		if test "$argv[2]" = "list"
			echo -e "\n=== EQ PRESETS ==="
			for p in $presets_matrix
				set -l fields (string split " " $p)
				printf "%-10s : Bass %2d | Punch %2d | Treble %2d\n" $fields[1] $fields[2] $fields[3] $fields[4]
			end
			echo -e "\nManual:\n  audioctl eq <bass> <punch> <treble>\n"
			return 0
		end

		set -l preset $argv[2]
		set -l bass 0
		set -l punch 0
		set -l treble 0
		set -l limiter 0.95
		set -l is_preset false

		# Mencari preset di dalam matrix data
		for p in $presets_matrix
			set -l fields (string split " " $p)
			if test "$fields[1]" = "$preset"
				set bass $fields[2]
				set punch $fields[3]
				set treble $fields[4]
				set is_preset true
				break
			end
		end

		# Jika bukan preset dari daftar, cek apakah input berupa manual angka
		if test "$is_preset" = "false"
			if string match -rq '^-?[0-9]+(\.[0-9]+)?$' -- $preset
				set bass $preset
				set punch (test (count $argv) -ge 3; and echo $argv[3]; or echo 0)
				set treble (test (count $argv) -ge 4; and echo $argv[4]; or echo 0)
				set preset manual
			else
				echo -e "Invalid preset or value: $preset\n"
				echo "Examples:"
				echo "  audioctl eq bassboost"
				echo "  audioctl eq 12 4 2\n"
				echo "Format:"
				echo "  audioctl eq <bass> <punch> <treble>"
				return 1
			end
		end

		# Hitung nilai preamp untuk tampilan output (sinkron dengan rumus di fungsi _audioctl_build_filter)
		set -l max_gain (math "max($bass, $punch, $treble)")
		set -l calculated_preamp (math "-0.5 * $max_gain")

		# Build filter menggunakan helper function tunggal
		set -l filter (_audioctl_build_filter --bass $bass --punch $punch --treble $treble --limiter $limiter)

		if not test -S "$sock"
			echo "ERROR: mpv socket not running"
			return 1
		end

		echo "{\"command\":[\"set_property\",\"af\",\"$filter\"]}" | socat - UNIX-CONNECT:$sock >/dev/null 2>&1

		# Save State
		echo -e "preset=$preset\nbass=$bass\npunch=$punch\ntreble=$treble\nlimiter=$limiter" > $statefile

		echo -e "\nPROFILE SET : $preset\n"
		echo "=== EQ PROFILE ==="
		printf "%-12s : %0.2f dB\n" "Pre-Amp" $calculated_preamp
		printf "%-12s : %+d dB\n" "Bass" $bass
		printf "%-12s : %+d dB\n" "Punch" $punch
		printf "%-12s : %+d dB\n" "Treble" $treble
		printf "%-12s : %.2f\n" "Limiter" $limiter
		echo -e "\nFilter applied to MPV\n"
		return 0
	end

	echo "Unknown command: $cmd"
	echo "Try: audioctl"
end

