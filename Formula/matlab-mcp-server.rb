class MatlabMcpServer < Formula
  desc "Official MathWorks MCP server for MATLAB"
  homepage "https://github.com/matlab/matlab-mcp-server"
  url "https://github.com/matlab/matlab-mcp-server/releases/download/v0.16.1/matlab-mcp-server-macos-arm64"
  version "0.16.1"
  sha256 "06661014da29d781e232fe9c257678357b5553b917cad29cbb644e9c6ece70fe"

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
