#!/bin/sh

# ci_post_xcodebuild.sh
# This script runs after Xcode Cloud builds the project
# The actual TestFlight deployment is configured in the Xcode Cloud workflow

echo "Xcode Cloud post-build diagnostics"
echo "Archive path: ${CI_ARCHIVE_PATH:-not available}"
echo "Build number: ${CI_BUILD_NUMBER:-not available}"
echo "Commit: ${CI_COMMIT:-not available}"

# The workflow's Post-Actions will handle TestFlight deployment
# No additional scripting needed - just configure the workflow in Xcode
