#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

main() {
  local git_repo_url='git@github.com:tlan16/mac-cron.git'
  mkdir -vp temp
  rm -vrf temp/mac-cron

  echo "Cloning mac-cron repository from $git_repo_url ..."
  git clone --depth=1 "$git_repo_url" temp/mac-cron

  local cargo_file_path='temp/mac-cron/Cargo.toml'
  verify_file_exist_and_not_empty "$cargo_file_path"

  local version_from_cargo
  version_from_cargo=$(awk -F '"' '/^version/ {print $2}' "$cargo_file_path")
  echo "Version from Cargo.toml: $version_from_cargo"

  mkdir -vp Formula
  local formula_file_path="Formula/mac-cron.rb"

  echo "Generating Homebrew formula at $formula_file_path ..."
  cat > "$formula_file_path" <<EOF
class MacCron < Formula
  desc "Mac Cron"
  homepage "https://github.com/tlan16/mac-cron"
  url "git@github.com:tlan16/mac-cron.git", branch: "main"
  version "$version_from_cargo"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_predicate bin/"mac-cron", :exist?
  end
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
