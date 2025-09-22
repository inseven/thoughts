#!/bin/bash

# Copyright (c) 2024-2025 Jason Morley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e
set -o pipefail
set -x
set -u

SCRIPTS_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ROOT_DIRECTORY="$SCRIPTS_DIRECTORY/.."
WEBSITE_DIRECTORY="$ROOT_DIRECTORY/docs"

source "$SCRIPTS_DIRECTORY/environment.sh"

cd "$ROOT_DIRECTORY"

# Update the release notes.
"$SCRIPTS_DIRECTORY/update-release-notes.sh"

# Install the Jekyll dependencies.
export GEM_HOME="$ROOT_DIRECTORY/.local/ruby"
mkdir -p "$GEM_HOME"
export PATH="$GEM_HOME/bin":$PATH
gem install bundler
cd "$WEBSITE_DIRECTORY"
bundle install

# Get the latest release URL.
if ! DOWNLOAD_URL=$(build-tools latest-github-release inseven thoughts "Thoughts-*.zip"); then
    echo >&2 failed
    exit 1
fi
# Belt-and-braces check that we managed to get the download URL.
if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "Failed to get release download URL."
    exit 1
fi
export DOWNLOAD_URL

# Determine the version.
VERSION_NUMBER=`changes version`
export VERSION_NUMBER

# Create a JSON file pointing to the latest download.
echo """{
    "version": "$VERSION_NUMBER",
    "url": "$DOWNLOAD_URL"
}
""" > "$WEBSITE_DIRECTORY/current.json"

# Build the website.
cd "$WEBSITE_DIRECTORY"
bundle exec jekyll build
