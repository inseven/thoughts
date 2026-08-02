#!/bin/bash

# Copyright (c) 2021-2026 Jason Morley
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

ROOT_DIRECTORY="$( cd "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" &> /dev/null && pwd )"
SCRIPTS_DIRECTORY="$ROOT_DIRECTORY/scripts"

export LOCAL_TOOLS_PATH="$ROOT_DIRECTORY/.local"

# Keep Python user installs local to the project instead of polluting the host.
export PYTHONUSERBASE="$LOCAL_TOOLS_PATH/python"
mkdir -p "$PYTHONUSERBASE"
export PATH="$PYTHONUSERBASE/bin":$PATH

# Keep pipenv virtualenvs local and predictable.
export WORKON_HOME="$LOCAL_TOOLS_PATH"
export PIPENV_CUSTOM_VENV_NAME="venv"
export PIPENV_VENV_IN_PROJECT=0
export PIPENV_IGNORE_VIRTUALENVS=1
export PIPENV_PIPFILE="$SCRIPTS_DIRECTORY/Pipfile"

# Add the tools to the path.
export PATH="$LOCAL_TOOLS_PATH/venv/bin":$PATH
