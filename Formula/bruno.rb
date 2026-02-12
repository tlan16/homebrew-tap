class MacCron < Formula
  desc "bruno"
  homepage "https://github.com/usebruno/bruno"
  url "https://github.com/usebruno/bruno.git", branch: "release/v3.0.2"
  version "v3.0.2"
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
