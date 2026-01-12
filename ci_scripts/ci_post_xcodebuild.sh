#!/bin/sh

# ci_post_xcodebuild.sh
# This script runs after Xcode Cloud builds the project
# The actual TestFlight deployment is configured in the Xcode Cloud workflow

echo "Build completed successfully!"
echo "Archive path: $CI_ARCHIVE_PATH"
echo "Build number: $CI_BUILD_NUMBER"
echo "Commit: $CI_COMMIT"

# The workflow's Post-Actions will handle TestFlight deployment
# No additional scripting needed - just configure the workflow in Xcode
