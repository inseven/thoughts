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
SOURCE_DIRECTORY="$ROOT_DIRECTORY/macos"
BUILD_DIRECTORY="$ROOT_DIRECTORY/build"
ARCHIVES_DIRECTORY="$ROOT_DIRECTORY/archives"
TEMPORARY_DIRECTORY="$ROOT_DIRECTORY/temp"
SPARKLE_DIRECTORY="$SCRIPTS_DIRECTORY/Sparkle"

KEYCHAIN_PATH="$TEMPORARY_DIRECTORY/temporary.keychain"
ARCHIVE_PATH="$BUILD_DIRECTORY/Thoughts.xcarchive"
APP_STORE_ARCHIVE_PATH="$BUILD_DIRECTORY/Thoughts_App_Store.xcarchive"
ENV_PATH="$ROOT_DIRECTORY/.env"

RELEASE_NOTES_TEMPLATE_PATH="$SCRIPTS_DIRECTORY/sparkle-release-notes.html"

RELEASE_SCRIPT_PATH="$SCRIPTS_DIRECTORY/release.sh"

IOS_XCODE_PATH=${IOS_XCODE_PATH:-/Applications/Xcode.app}
MACOS_XCODE_PATH=${MACOS_XCODE_PATH:-/Applications/Xcode.app}

source "$SCRIPTS_DIRECTORY/environment.sh"

# Check that the GitHub command is available on the path.
which gh || (echo "GitHub cli (gh) not available on the path." && exit 1)

# Process the command line arguments.
POSITIONAL=()
RELEASE=${RELEASE:-false}
UPLOAD_TO_APP_STORE=${UPLOAD_TO_APP_STORE:-false}
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -r|--release)
        RELEASE=true
        shift
        ;;
        -u|--upload-to-app-store)
        UPLOAD_TO_APP_STORE=true
        shift
        ;;
        *)
        POSITIONAL+=("$1")
        shift
        ;;
    esac
done

# We always need to upload to TestFlight if we're attempting to make a release.
if $RELEASE ; then
    UPLOAD_TO_APP_STORE=true
fi

# Generate a random string to secure the local keychain.
export TEMPORARY_KEYCHAIN_PASSWORD=`openssl rand -base64 14`

# Source the .env file if it exists to make local development easier.
if [ -f "$ENV_PATH" ] ; then
    echo "Sourcing .env..."
    source "$ENV_PATH"
fi

cd "$SOURCE_DIRECTORY"

# Select the correct Xcode.
sudo xcode-select --switch "$MACOS_XCODE_PATH"

# List the available schemes.
xcodebuild \
    -project Thoughts.xcodeproj \
    -list

# Clean up and recreate the output directories.

if [ -d "$BUILD_DIRECTORY" ] ; then
    rm -r "$BUILD_DIRECTORY"
fi
mkdir -p "$BUILD_DIRECTORY"

if [ -d "$ARCHIVES_DIRECTORY" ] ; then
    rm -r "$ARCHIVES_DIRECTORY"
fi
mkdir -p "$ARCHIVES_DIRECTORY"

# Create the a new keychain.
if [ -d "$TEMPORARY_DIRECTORY" ] ; then
    rm -rf "$TEMPORARY_DIRECTORY"
fi
mkdir -p "$TEMPORARY_DIRECTORY"
echo "$TEMPORARY_KEYCHAIN_PASSWORD" | build-tools create-keychain "$KEYCHAIN_PATH" --password

function cleanup {

    # Cleanup the temporary files, keychain and keys.
    cd "$ROOT_DIRECTORY"
    build-tools delete-keychain "$KEYCHAIN_PATH"
    rm -rf "$TEMPORARY_DIRECTORY"
    rm -rf ~/.appstoreconnect/private_keys
}

trap cleanup EXIT

# Determine the version and build number.
VERSION_NUMBER=`changes version`
BUILD_NUMBER=`build-number.swift`

# Import the certificates into our dedicated keychain.
echo "$APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD" | build-tools import-base64-certificate --password "$KEYCHAIN_PATH" "$APPLE_DISTRIBUTION_CERTIFICATE_BASE64"
echo "$DEVELOPER_ID_APPLICATION_CERTIFICATE_PASSWORD" | build-tools import-base64-certificate --password "$KEYCHAIN_PATH" "$DEVELOPER_ID_APPLICATION_CERTIFICATE_BASE64"
echo "$MACOS_DEVELOPER_INSTALLER_CERTIFICATE_PASSWORD" | build-tools import-base64-certificate --password "$KEYCHAIN_PATH" "$MACOS_DEVELOPER_INSTALLER_CERTIFICATE_BASE64"

# Install the provisioning profiles.
build-tools install-provisioning-profile "profiles/Thoughts_Developer_ID_Profile.provisionprofile"
build-tools install-provisioning-profile "profiles/Thoughts_Mac_App_Store_Profile.provisionprofile"

## Developer ID Build

# Build and archive the macOS project.
sudo xcode-select --switch "$MACOS_XCODE_PATH"
xcodebuild \
    -project Thoughts.xcodeproj \
    -scheme "Thoughts" \
    -config Release \
    -archivePath "$ARCHIVE_PATH" \
    OTHER_CODE_SIGN_FLAGS="--keychain=\"${KEYCHAIN_PATH}\"" \
    CURRENT_PROJECT_VERSION=$BUILD_NUMBER \
    MARKETING_VERSION=$VERSION_NUMBER \
    clean archive

# Export the app for Developer ID distribution.
xcodebuild \
    -archivePath "$ARCHIVE_PATH" \
    -exportArchive \
    -exportPath "$BUILD_DIRECTORY" \
    -exportOptionsPlist "ExportOptions_Developer_ID.plist"

# Apple recommends we use ditto to prepare zips for notarization.
# https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow
# Install the private key.
mkdir -p ~/.appstoreconnect/private_keys/
API_KEY_PATH=~/".appstoreconnect/private_keys/AuthKey_${APPLE_API_KEY_ID}.p8"
echo -n "$APPLE_API_KEY_BASE64" | base64 --decode -o "$API_KEY_PATH"

# Notarize and staple the app.
build-tools notarize "$BUILD_DIRECTORY/Thoughts.app" \
    --key "$API_KEY_PATH" \
    --key-id "$APPLE_API_KEY_ID" \
    --issuer "$APPLE_API_KEY_ISSUER_ID"

# Compress the app.
APP_BASENAME="Thoughts.app"
RELEASE_BASENAME="Thoughts-$VERSION_NUMBER-$BUILD_NUMBER"
RELEASE_ZIP_BASENAME="$RELEASE_BASENAME.zip"
RELEASE_ZIP_PATH="$BUILD_DIRECTORY/$RELEASE_ZIP_BASENAME"
pushd "$BUILD_DIRECTORY"
zip --symlinks -r "$RELEASE_ZIP_BASENAME" "$APP_BASENAME"
rm -r "$APP_BASENAME"
popd

# Build Sparkle.
cd "$SPARKLE_DIRECTORY"
xcodebuild -project Sparkle.xcodeproj -scheme generate_appcast SYMROOT=`pwd`/.build
GENERATE_APPCAST=`pwd`/.build/Debug/generate_appcast

SPARKLE_PRIVATE_KEY_FILE="$TEMPORARY_DIRECTORY/private-key-file"
echo -n "$SPARKLE_PRIVATE_KEY_BASE64" | base64 --decode -o "$SPARKLE_PRIVATE_KEY_FILE"

# Generate the appcast.
cd "$ROOT_DIRECTORY"
cp "$RELEASE_ZIP_PATH" "$ARCHIVES_DIRECTORY"
changes notes --all --template "$RELEASE_NOTES_TEMPLATE_PATH" >> "$ARCHIVES_DIRECTORY/$RELEASE_BASENAME.html"
"$GENERATE_APPCAST" --ed-key-file "$SPARKLE_PRIVATE_KEY_FILE" "$ARCHIVES_DIRECTORY"
APPCAST_PATH="$ARCHIVES_DIRECTORY/appcast.xml"
cp "$APPCAST_PATH" "$BUILD_DIRECTORY"

## App Store Build

cd "$SOURCE_DIRECTORY"

# Copy the App Store Package.swift configuration.
cp ThoughtsCore/Package_App_Store.swift ThoughtsCore/Package.swift

# Build and archive the macOS project.
sudo xcode-select --switch "$MACOS_XCODE_PATH"
xcodebuild \
    -project Thoughts.xcodeproj \
    -scheme "Thoughts" \
    -config Release \
    -archivePath "$APP_STORE_ARCHIVE_PATH" \
    OTHER_CODE_SIGN_FLAGS="--keychain=\"${KEYCHAIN_PATH}\"" \
    CURRENT_PROJECT_VERSION=$BUILD_NUMBER \
    MARKETING_VERSION=$VERSION_NUMBER \
    clean archive

# Export the app for App Store distribution.
xcodebuild \
    -archivePath "$APP_STORE_ARCHIVE_PATH" \
    -exportArchive \
    -exportPath "$BUILD_DIRECTORY" \
    -exportOptionsPlist "ExportOptions_App_Store.plist"

PKG_PATH="$BUILD_DIRECTORY/Thoughts.pkg"

if $UPLOAD_TO_APP_STORE ; then

    # Upload the macOS build.
    xcrun altool --upload-app \
        -f "$PKG_PATH" \
        --primary-bundle-id "uk.co.jbmorley.thoughts.apps.appstore" \
        --apiKey "$APPLE_API_KEY_ID" \
        --apiIssuer "$APPLE_API_KEY_ISSUER_ID" \
        --type macos

fi

## ---

cd "$ROOT_DIRECTORY"

# Archive the build directory.
ZIP_BASENAME="build-$VERSION_NUMBER-$BUILD_NUMBER.zip"
ZIP_PATH="$BUILD_DIRECTORY/$ZIP_BASENAME"
pushd "$BUILD_DIRECTORY"
zip -r "$ZIP_BASENAME" .
popd

if $RELEASE ; then

    changes \
        release \
        --skip-if-empty \
        --push \
        --exec "$RELEASE_SCRIPT_PATH" \
        "$PKG_PATH" "$ZIP_PATH" "$RELEASE_ZIP_PATH" "$BUILD_DIRECTORY/appcast.xml"

fi
