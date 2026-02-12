#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

main() {
  local git_repo_url='https://github.com/usebruno/bruno.git'
  local workdir='temp/bruno'
  mkdir -vp temp
  rm -rf "$workdir"

  local release_json_url='https://api.github.com/repos/usebruno/bruno/releases'
  local release_json_response
  release_json_response="$(curl --silent --fail "$release_json_url")"
  echo "Release JSON response length: ${#release_json_response}"
  if [ -z "$release_json_response" ]; then
    echo "Error: Failed to fetch release information from $release_json_url" >&2
  fi
  local branch_name tag_name
  branch_name=$(echo "$release_json_response" | jq -r '.[0].target_commitish' | head -n 1)
  tag_name=$(echo "$release_json_response" | jq -r '.[0].tag_name' | head -n 1)
  echo "Latest release branch_name: $branch_name, tag_name: $tag_name"
  if [ -z "$branch_name" ]; then
    echo "Error: Failed to extract branch_name from release information" >&2
  fi

  local formula_file_path='Formula/bruno.rb'
  echo "Generating Homebrew formula at $formula_file_path ..."
  cat > "$formula_file_path" <<EOF
class MacCron < Formula
  desc "bruno"
  homepage "https://github.com/usebruno/bruno"
  url "https://github.com/usebruno/bruno.git", branch: "$branch_name"
  version "$tag_name"
  url "file://packages/bruno-electron/out/bruno_2.0.0_arm64_mac.dmg"

  depends_on "node" => :build

  def install
    system "npm", "--frozen-lockfile"
    system "npm", "run", "build:electron:mac"
  end

  livecheck do
    url :url
    strategy :github_latest
  end

  app "Cast.app"

  zap trash: [
    "~/Library/Application Support/Cast",
    "~/Library/Preferences/com.example.cast.plist",
    "~/Library/Caches/com.example.cast",
  ]
end
EOF

  echo "Homebrew formula generated successfully at $formula_file_path"
  echo "Content of the generated formula:"
  echo "-- Start of formula content --"
  cat "$formula_file_path"
  echo "-- End of formula content --"
}

verify_file_exist_and_not_empty() {
  local file_path="$1"
  if [ ! -f "$file_path" ]; then
    echo "Error: File '$file_path' does not exist."
    exit 1
  fi

  if [ ! -s "$file_path" ]; then
    echo "Error: File '$file_path' is empty."
    exit 1
  fi
}

mac_path_patch() {
  local gnu_path='/opt/homebrew/opt/grep/libexec/gnubin'
  if [ -d "$gnu_path" ]; then
    export PATH="$gnu_path:$PATH"
  fi
}

mac_path_patch
main
