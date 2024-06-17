#!/bin/bash

function screenshot_light {
    convert \
        -size 2880x1800 \
        gradient:"rgb(0 157 238)-rgb(0 206 246)" \
        "$1" \
        -gravity Center \
        -geometry +0+36 \
        -composite "$2"
}

function screenshot_dark {
    convert \
        -size 2880x1800 \
        gradient:"rgb(26 30 47)-rgb(0 58 59)" \
        -modulate 80,100,100 \
        "$1" \
        -gravity Center \
        -geometry +0+36 \
        -composite "$2"
}

screenshot_light "graphics/screenshots/screenshot@2x.png" "graphics/screenshots/screenshot-appstore@2x.png"
screenshot_dark "graphics/screenshots/screenshot-dark@2x.png" "graphics/screenshots/screenshot-appstore-dark@2x.png"
