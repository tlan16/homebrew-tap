class MacCron < Formula
  version "version = "0.1.0""
  desc "Mac Cron"
  homepage "https://github.com/tlan16/mac-cron"

  depends_on "rust" => :build
  depends_on "git" => :build

  def install
    system "git", "clone", "--depth", "1", "--branch", "main",
           "git@github.com:tlan16/mac-cron.git", buildpath
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    assert_predicate bin/"mac-cron", :exist?
  end
end
