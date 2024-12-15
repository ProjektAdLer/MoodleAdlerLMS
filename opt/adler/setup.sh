#!/bin/bash
set -e

cd /bitnami/moodle

#### install declarativesetup if not exists
# Define the directory and URL
DECLARATIVESETUP_VERSION=$(jq -r '.[] | select(.name == "local_declarativesetup") | .version' /opt/adler/plugins.json)
DECLARATIVESETUP_REPO=$(jq -r '.[] | select(.name == "local_declarativesetup") | .package_repo' /opt/adler/plugins.json)
TARGET_DIR="local/declarativesetup"
ZIP_URL="$DECLARATIVESETUP_REPO/local_declarativesetup/$DECLARATIVESETUP_VERSION.zip"
ZIP_FILE="/tmp/local_declarativesetup_$DECLARATIVESETUP_VERSION.zip"

# Check if the directory exists
echo "Checking if $TARGET_DIR exists"
if [ ! -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR does not exist. Downloading and extracting the zip file: $ZIP_URL"

    # Download the zip file
    curl -f -o "$ZIP_FILE" "$ZIP_URL"
    if [ $? -ne 0 ]; then
        echo "Failed to download the zip file from $ZIP_URL"
        exit 1
    fi

    # Extract the zip file to the target directory
    echo "Extracting the zip file to $TARGET_DIR"
    unzip -q "$ZIP_FILE" -d "$(dirname "$TARGET_DIR")"
    if [ $? -ne 0 ]; then
        echo "Failed to extract the zip file to $TARGET_DIR"
        exit 1
    fi

    # Clean up the zip file
    rm "$ZIP_FILE"

    # Run the upgrade script
    echo "Running the upgrade script"
    php admin/cli/upgrade.php --non-interactive

    if [ $? -ne 0 ]; then
        echo "Upgrade script failed"
        exit 1
    fi
else
    echo "Directory $TARGET_DIR already exists. Skipping download and extraction."
fi

#### install main playbook (installing all plugins and potential further playbooks)
echo "installing adler playbook"
ADLER_PLAYBOOK_VERSION=$(jq -r '.[] | select(.name == "playbook_adler") | .version' /opt/adler/plugins.json)
ADLER_PLAYBOOK_PACKAGE_REPO=$(jq -r '.[] | select(.name == "playbook_adler") | .package_repo' /opt/adler/plugins.json)
php local/declarativesetup/cli/install_plugin.php --package-repo=$ADLER_PLAYBOOK_PACKAGE_REPO --version="$ADLER_PLAYBOOK_VERSION" --moodle-name=playbook_adler
# copy plugins.json to playbook
cp /opt/adler/plugins.json local/declarativesetup/playbook/adler/files/plugins.json

#### run playbooks
echo "running adler playbook"
php local/declarativesetup/cli/run_playbook.php --playbook=adler --roles="$ADLER_PLAYBOOK_ROLES"

echo "finished adler setup/update script"
