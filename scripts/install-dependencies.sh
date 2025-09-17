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

ROOT_DIRECTORY="$( cd "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" &> /dev/null && pwd )"
SCRIPTS_DIRECTORY="$ROOT_DIRECTORY/scripts"

LOCAL_TOOLS_PATH="$ROOT_DIRECTORY/.local"
CHANGES_DIRECTORY="$SCRIPTS_DIRECTORY/changes"
BUILD_TOOLS_DIRECTORY="$SCRIPTS_DIRECTORY/build-tools"

# Install tools defined in `.tool-versions`.
cd "$ROOT_DIRECTORY"
mise install

# Clean up and recreate the local tools directory.
if [ -d "$LOCAL_TOOLS_PATH" ] ; then
    rm -r "$LOCAL_TOOLS_PATH"
fi
mkdir -p "$LOCAL_TOOLS_PATH"

# Set up a Python venv to bootstrap our python dependency on `pipenv`.
python -m venv "$LOCAL_TOOLS_PATH/python"

# Source `environment.sh` to ensure the remainder of our paths are set up correctly.
source "$SCRIPTS_DIRECTORY/environment.sh"

# Install the Python dependencies.
pip install --upgrade pip pipenv wheel certifi
PIPENV_PIPFILE="$CHANGES_DIRECTORY/Pipfile" pipenv install
PIPENV_PIPFILE="$BUILD_TOOLS_DIRECTORY/Pipfile" pipenv install
