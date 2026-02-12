class Bruno < Formula
  desc "bruno"
  homepage "https://github.com/usebruno/bruno"
  url "https://github.com/usebruno/bruno.git", branch: "release/v3.0.2"
  version "v3.0.2"
  head "https://github.com/usebruno/bruno.git", branch: "main"

  depends_on "node" => :build

  def install
    system "npm", "install"
    system "npm", "run", "build:electron:mac"

    # Install the app
    app_files = Dir["packages/bruno-electron/out/**/Bruno.app"]
    raise "Could not find Bruno.app" if app_files.empty?

    prefix.install app_files.first
  end

  livecheck do
    url :url
    strategy :github_latest
  end
end
