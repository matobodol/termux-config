function tagtitle
    argparse 'artist=' 'album=' -- $argv
    or return 1

    set -l artist "$_flag_artist"
    set -l album "$_flag_album"

    python -c '
from pathlib import Path
from mutagen import File
import re
import sys

artist = sys.argv[1]
album = sys.argv[2]

exts = {".mp3", ".flac", ".m4a", ".opus", ".ogg"}

for f in Path(".").iterdir():
    if f.suffix.lower() not in exts:
        continue

    title = f.stem

    title = re.sub(r"^\d+\s*-\s*", "", title)
    title = re.sub(r"^\d+\s+", "", title)

    audio = File(f, easy=True)
    if audio is None:
        print(f"SKIP: {f.name}")
        continue

    audio.clear()

    audio["title"] = [title]

    if artist:
        audio["artist"] = [artist]

    if album:
        audio["album"] = [album]

    audio.save()

    print(f"{f.name} -> {title}")
' "$artist" "$album"
end
