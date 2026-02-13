class Bruno < Formula
  desc "bruno"
  homepage "https://github.com/usebruno/bruno"
  url "https://github.com/usebruno/bruno.git", branch: "release/v3.0.2"
  version "v3.0.2"
  head "https://github.com/usebruno/bruno.git", branch: "main"

  depends_on "node" => :build

  def install
    system "npm", "install"
    # Fix typescript version issue in dependencies
    system "npm", "install", "typescript@latest", "-D"

    # Disable code signing and notarization
    inreplace "packages/bruno-electron/electron-builder-config.js" do |s|
      s.gsub! "identity: 'Anoop MD (W7LPPWA48L)',", "identity: null,"
      s.gsub! "afterSign: 'notarize.js',", "afterSign: null,"
    end

    # Build dependencies in order
    system "npm", "run", "build:schema-types"
    system "npm", "run", "build:bruno-common"
    system "npm", "run", "build:bruno-requests"
    system "npm", "run", "build:bruno-filestore"
    system "npm", "run", "build:bruno-converters"
    system "npm", "run", "build:bruno-query"
    system "npm", "run", "build:graphql-docs"

    # Build the web app
    system "npm", "run", "build:web"

    # Build the electron app
    system "npm", "run", "build:electron:mac"

    # Install the app
    target_arch = Hardware::CPU.intel? ? "mac" : "mac-arm64"
    app_files = Dir["packages/bruno-electron/out/#{target_arch}/Bruno.app"]
    app_files = Dir["packages/bruno-electron/out/**/Bruno.app"] if app_files.empty?

    raise "Could not find Bruno.app" if app_files.empty?

    prefix.install app_files.first
  end

  livecheck do
    url :url
    strategy :github_latest
  end
end
