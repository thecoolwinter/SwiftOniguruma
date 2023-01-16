#!/usr/bin/env sh

status () {
    local GREEN='\033[0;32m'
    local NC='\033[0m' # No Color
    echo "${GREEN}◆ $1${NC}"
}

# If --debug set -quiet flag and redirect output to /dev/null
if [ "$1" = "--debug" ]; then
    QUIET_FLAG=""
    QUIET_OUTPUT=/dev/stdout
else
    QUIET_FLAG="-quiet"
    QUIET_OUTPUT=/dev/null
fi

# Set pipefail to make sure that the script fails if any of the commands fail
set -euo pipefail

# Set some variables
ONI_OUTPUT_PATH="./deps/oniguruma/src/.libs/libonig.a"
OUTPUT_PATH="./SwiftOnigurumaContainer.xcframework"
ARCHIVE_PATH="./$OUTPUT_PATH.zip"

status "Bulding oniguruma..."

# Build oniguruma into a fat binary (arm64 and x86_64)
cd ./deps/oniguruma

autoreconf -vfi &> $QUIET_OUTPUT
./configure CC="gcc -arch arm64 -arch x86_64" &> $QUIET_OUTPUT
make clean &> $QUIET_OUTPUT
make &> $QUIET_OUTPUT
cd ../../

status "Building oniguruma complete!"

rm -rf "$OUTPUT_PATH"
rm -rf "$ARCHIVE_PATH"

status "Creating $OUTPUT_PATH"

rm -rf .temp

mkdir .temp
mkdir .temp/include
cp ./deps/oniguruma/src/oniguruma.h ./.temp/include/

xcrun xcodebuild -create-xcframework \
    -library $ONI_OUTPUT_PATH \
    -headers "./.temp/include" \
    -output $OUTPUT_PATH

#status "Zipping $OUTPUT_PATH..."
#zip -r -q "$ARCHIVE_PATH" "$OUTPUT_PATH"
#
rm -rf .temp
#rm -rf "$OUTPUT_PATH"
#status "$ARCHIVE_PATH created!"

status "Done!"
