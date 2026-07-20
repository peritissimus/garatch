#!/bin/sh
set -eu

face_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
designer_dir="$face_dir/designer"
drawables_dir="$face_dir/resources/drawables"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
cd "$face_dir"

magick -background none "mvg:$designer_dir/dashboard-time.mvg" "$tmp_dir/time.png"
magick -background none "mvg:$designer_dir/dashboard-small.mvg" "$tmp_dir/small.png"
magick -background none "mvg:$designer_dir/dashboard-medium.mvg" "$tmp_dir/medium.png"

i=0
while [ "$i" -lt 10 ]; do
    magick "$tmp_dir/time.png" -crop "64x68+$((i * 64))+0" +repage \
        -resize '64x56!' -background none -gravity north -splice 0x3 -extent 64x68 \
        -fill '#C9CBAE' -colorize 100 "PNG32:$drawables_dir/digit-warm-$i.png"
    magick "$tmp_dir/time.png" -crop "64x68+$((i * 64))+0" +repage \
        -resize '64x56!' -background none -gravity north -splice 0x3 -extent 64x68 \
        -fill '#36383A' -colorize 100 "PNG32:$drawables_dir/digit-dim-$i.png"
    i=$((i + 1))
done

i=0
while [ "$i" -lt 10 ]; do
    magick "$tmp_dir/medium.png" -crop "32x32+$((i * 32))+0" +repage \
        -fill '#F1F3E8' -colorize 100 "PNG32:$drawables_dir/medium-ink-$i.png"
    i=$((i + 1))
done
magick "$tmp_dir/medium.png" -crop '32x32+320+0' +repage \
    -fill '#F1F3E8' -colorize 100 "PNG32:$drawables_dir/medium-ink-dot.png"
magick "$tmp_dir/medium.png" -crop '32x32+352+0' +repage \
    -fill '#F1F3E8' -colorize 100 "PNG32:$drawables_dir/medium-ink-dash.png"

for color_name in track warm cyan mint; do
    magick -background none "$designer_dir/icons/segment-$color_name.svg" \
        "PNG8:$drawables_dir/icon-segment-$color_name.png"
done

# Preserve the heart's ECG cutout after the final-size downsample.
magick -background none -density 192 "$designer_dir/icons/heart.svg" -resize 22x20 \
    -fill none -stroke black -strokewidth 2 \
    -draw 'polyline 2,10 8,10 9,6 12,13 14,10 19,10' \
    "PNG8:$drawables_dir/icon-heart.png"

for color_name in warm ink; do
    if [ "$color_name" = warm ]; then
        color='#C9CBAE'
    else
        color='#F1F3E8'
    fi

    i=0
    while [ "$i" -lt 10 ]; do
        magick "$tmp_dir/small.png" -crop "32x28+$((i * 32))+0" +repage \
            -fill "$color" -colorize 100 "PNG32:$drawables_dir/small-$color_name-$i.png"
        i=$((i + 1))
    done

    for glyph in dot percent dash f c; do
        case "$glyph" in
            dot) index=10 ;;
            percent) index=11 ;;
            dash) index=12 ;;
            f) index=13 ;;
            c) index=14 ;;
        esac
        magick "$tmp_dir/small.png" -crop "32x28+$((index * 32))+0" +repage \
            -fill "$color" -colorize 100 "PNG32:$drawables_dir/small-$color_name-$glyph.png"
    done
done
