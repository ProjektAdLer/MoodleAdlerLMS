#!/bin/bash

# Read plugins.json
plugins=$(jq -c '.[]' plugins.json)

# Initialize the supported_moodle_versions variable
supported_moodle_versions=""

# Iterate over each plugin
for plugin in $plugins; do
  git_project=$(echo $plugin | jq -r '.git_project')
  version=$(echo $plugin | jq -r '.version')
  name=$(echo $plugin | jq -r '.name')

  # Construct the URL to the plugin_compatibility.json file
  if [ "$version" == "main" ]; then
    url="https://raw.githubusercontent.com/$git_project/refs/heads/$version/plugin_compatibility.json"
  else
    url="https://raw.githubusercontent.com/$git_project/refs/tags/$version/plugin_compatibility.json"
  fi

  # Fetch the plugin_compatibility.json file
  response=$(curl -s $url)

  if [[ "$response" == "404: Not Found" ]]; then
    echo "Failed to fetch plugin_compatibility.json for $name ($version)"
    exit 1
  fi

  # Extract the list of Moodle versions from the response
  current_moodle_versions=$(echo $response | jq -r '.[].moodle')
  if [ $? -eq 0 ]; then
    if [ -z "$supported_moodle_versions" ]; then
      # If supported_moodle_versions is empty, set it to the current list
      supported_moodle_versions=$current_moodle_versions
    else
      # Otherwise, keep only the versions that are in both lists
      supported_moodle_versions=$(echo "$supported_moodle_versions" | grep -Fxf - <(echo "$current_moodle_versions"))
    fi
  else
    echo "Failed to fetch plugin_compatibility.json for $name ($version)"
    exit 1
  fi
done

convert_branch_to_version() {
  branch_name=$1
  major_version=${branch_name:7:1}
  minor_version=${branch_name:8:2}
  minor_version=${minor_version#0} # Remove leading zero if present
  echo "$major_version.$minor_version"
}

json_array="["
for moodle_branch in $supported_moodle_versions; do
  moodle_version=$(convert_branch_to_version $moodle_branch)
  json_array="$json_array {\"moodle\": \"$moodle_version\"},"
done
json_array="${json_array%,} ]"


# Output the final list of supported Moodle versions
echo "$json_array"