class MatlabMcpServer < Formula
  desc "Official MathWorks MCP server for MATLAB"
  homepage "https://github.com/matlab/matlab-mcp-server"
  url "https://github.com/matlab/matlab-mcp-server/releases/download/v0.16.2/matlab-mcp-server-macos-arm64"
  version "0.16.2"
  sha256 "0126382f9ef38e8eae71694c6916919538b3bc402088d8f02ca952f338eebed6"

  depends_on :macos
  depends_on arch: :arm64

  def install
    bin.install "matlab-mcp-server-macos-arm64" => "matlab-mcp-server"
    chmod 0755, bin/"matlab-mcp-server"
  end

  test do
    assert_match " v#{version}", shell_output("#{bin}/matlab-mcp-server --version")
  end
end
