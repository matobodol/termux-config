function ytq --description "yt-dlp wrapper (FIXED js-runtime + safe retry)"

	# Expand combined flags
	set -l expanded
	set -l download_dir "~/storage/downloads"

	for arg in $argv
		switch $arg
			case "-mp"
				set expanded $expanded "-m" "-p"
			case "-vp"
				set expanded $expanded "-v" "-p"
			case "*"
				set expanded $expanded $arg
		end
	end

	set argv $expanded

	function __ytq_help
		echo ""
		echo "ytq - yt-dlp wrapper (fixed version)"
		echo ""
		echo "USAGE:"
		echo ""
		echo " AUDIO:"
		echo "   ytq -m -o mp3 URL"
		echo "   ytq -m -o flac URL"
		echo "   ytq -mp -o mp3 URL"
		echo ""
		echo " VIDEO:"
		echo "   ytq -v URL"
		echo "   ytq -v -o mkv URL"
		echo "   ytq -v -o mkv -r 720 URL"
		echo "   ytq -vp -o mkv -r 720 URL"
		echo ""
		echo " OPTIONS:"
		echo "   -m / -v / -p"
		echo "   -o FORMAT   (mp3|flac|opus | mkv|mp4|webm)"
		echo "   -r RES      (144|240|360|480|720|1080)"
		echo "   -mp / -vp   shorthand"
		echo "   -c, --chapters  split output by YouTube chapters"
		echo "   -h, --help"
		echo ""
	end

	set -l mode
	set -l playlist false
	set -l output_format
	set -l resolution
	set -l url
	set -l chapters false

	while test (count $argv) -gt 0
		switch $argv[1]

			case "-h" "--help"
				__ytq_help
				return 0

			case "-m"
				set mode audio

			case "-v"
				set mode video

			case "-p"
				set playlist true

			case "-c" "--chapters"
				set chapters true

			case "-o"
				if test (count $argv) -lt 2
					echo "ytq: missing -o format"
					return 1
				end
				set output_format $argv[2]
				set argv $argv[2..-1]

			case "-r"
				if test (count $argv) -lt 2
					echo "ytq: missing resolution"
					return 1
				end
				set resolution $argv[2]
				set argv $argv[2..-1]

			case "*"
				if test -z "$url"
					set url $argv[1]
				end
		end

		set argv $argv[2..-1]
	end

	if test -z "$mode"
		__ytq_help
		return 1
	end

	if test -z "$url"
		echo "ytq: URL required"
		return 1
	end

	# playlist flag
	set -l playlist_arg --no-playlist
	if test "$playlist" = true
		set playlist_arg --yes-playlist
	end

	# chapter flag
	set -l chapter_arg


	if test "$chapters" = true

		set chapter_arg \
			--split-chapters \
			-o "%(title)s.%(ext)s" \
			-o "chapter:%(section_number)03d %(section_title)s.%(ext)s"
	end

	# FIXED JS runtime (IMPORTANT)
	set -l js_runtime --js-runtimes node

	# format filter default
	set -l format_filter "bestvideo+bestaudio/best"

	if test -n "$resolution"
		switch $resolution
			case 144 240 360 480 720 1080
			case '*'
				echo "ytq: invalid resolution (144|240|360|480|720|1080)"
				return 1
		end

		set format_filter "bestvideo[height<=$resolution]+bestaudio/best[height<=$resolution]"
	end

	# SAFE retry wrapper (FIXED)
	function __ytq_run
		yt-dlp $argv
		if test $status -ne 0
			echo "ytq: retrying extraction (fallback mode)..."
			yt-dlp --no-check-certificate $argv
		end
	end

	switch $mode

		case audio

			if test -z "$output_format"
				set output_format mp3
			end

			__ytq_run \
				$js_runtime \
				$playlist_arg \
				$chapter_arg \
				-P $download_dir \
				-x \
				--audio-format "$output_format" \
				--audio-quality 0 \
				--embed-thumbnail \
				--add-metadata \
				"$url"

		case video

			if test -n "$output_format"

				__ytq_run \
					$js_runtime \
					$playlist_arg \
					$chapter_arg \
					-P $download_dir \
					-f "$format_filter" \
					--remux-video "$output_format" \
					--embed-metadata \
					--embed-thumbnail \
					"$url"

			else

				__ytq_run \
					$js_runtime \
					$playlist_arg \
					$chapter_arg \
					-P $download_dir \
					-f "$format_filter" \
					--embed-metadata \
					--embed-thumbnail \
					"$url"

			end

	end
end
