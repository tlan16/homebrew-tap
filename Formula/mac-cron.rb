class MacCron < Formula
  desc "Mac Cron"
  homepage "https://github.com/tlan16/mac-cron"
  head "git@github.com:tlan16/mac-cron.git", branch: "main", using: :git

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: ".")
  end

  test do
    assert_path_exists bin/"mac-cron"
  end
end
