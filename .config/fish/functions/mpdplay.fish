function mpdplay
	set -l fifo ~/.mpd/mpd.fifo

	# Pastikan MPD berjalan
	if not pgrep -x mpd >/dev/null
		echo "Starting MPD..."
		mpd

		if test $status -ne 0
			echo "Failed to start MPD"
			return 1
		end
	end

	# Default
	set -l bass 3
	set -l treble 2
	set -l limiter 0.95

	# Preset atau manual
	if test (count $argv) -gt 0

		switch $argv[1]
			case list help

				echo ""
				echo "Available EQ presets:"
				echo ""
				echo "  flat       : Bass  0 | Treble  0"
				echo "  vocal      : Bass -2 | Treble  4"
				echo "  bass       : Bass  8 | Treble  0"
				echo "  bassboost  : Bass 12 | Treble  2"
				echo "  rock       : Bass  6 | Treble  5"
				echo "  pop        : Bass  4 | Treble  4"
				echo "  jazz       : Bass  3 | Treble  2"
				echo "  classical  : Bass  1 | Treble  3"
				echo "  acoustic   : Bass  2 | Treble  4"
				echo "  movie      : Bass  8 | Treble  4"
				echo "  gaming     : Bass  6 | Treble  6"
				echo "  night      : Bass  3 | Treble -2"
				echo ""
				echo "Manual:"
				echo "  mpdplay <bass> <treble>"
				echo ""
				echo "Examples:"
				echo "  mpdplay bassboost"
				echo "  mpdplay rock"
				echo "  mpdplay 12 5"
				echo ""

				return 0

			case flat
				set bass 0
				set treble 0

			case vocal
				set bass -2
				set treble 4

			case bass
				set bass 8
				set treble 0

			case bassboost
				set bass 12
				set treble 2

			case rock
				set bass 6
				set treble 5

			case pop
				set bass 4
				set treble 4

			case jazz
				set bass 3
				set treble 2

			case classical
				set bass 1
				set treble 3

			case acoustic
				set bass 2
				set treble 4

			case movie
				set bass 8
				set treble 4

			case gaming
				set bass 6
				set treble 6

			case night
				set bass 3
				set treble -2

			case '*'
				if string match -rq '^-?[0-9]+(\.[0-9]+)?$' -- $argv[1]

					set bass $argv[1]

					if test (count $argv) -ge 2

						if string match -rq '^-?[0-9]+(\.[0-9]+)?$' -- $argv[2]
							set treble $argv[2]
						else
							echo "Invalid treble value: $argv[2]"
							return 1
						end

					end

				else
					echo "Unknown preset: $argv[1]"
					echo ""
					echo "Run 'mpdplay list' to see available presets."
					return 1
				end
		end
	end

	set -l af \
		"lavfi=[volume=volume=-2dB,\
		equalizer=f=60:t=h:width=100:g=$bass,\
		equalizer=f=8000:t=h:width=4000:g=$treble,\
		alimiter=limit=$limiter]"

	echo "EQ: Bass=$bass dB | Treble=$treble dB"

	mpv \
		--no-video \
		--keep-open=yes \
		--idle=yes \
		--demuxer=rawaudio \
		--demuxer-rawaudio-channels=2 \
		--demuxer-rawaudio-rate=44100 \
		--demuxer-rawaudio-format=s16 \
		--audio-resample-filter-size=32 \
		--audio-resample-phase-shift=24 \
		--audio-resample-cutoff=0.97 \
		--audio-resample-linear=no \
		--af="$af" \
		"$fifo"
end
