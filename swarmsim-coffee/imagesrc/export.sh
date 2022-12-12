#!/bin/sh -eux
cd "`dirname "$0"`"
exportIcon() {
  X=$1; shift
  Y=$1; shift
  inkscape swarmsim-icon.svg --export-png=icon-${X}x${Y}.png -w${X} -h${Y} --export-id=logo --export-id-only
}

exportIcon 32 32
exportIcon 48 48
exportIcon 64 64
exportIcon 72 72
exportIcon 96 96
exportIcon 128 128
exportIcon 144 144
exportIcon 152 152
exportIcon 192 192
exportIcon 256 256
exportIcon 512 512
mv icon-*x*.png ../app
