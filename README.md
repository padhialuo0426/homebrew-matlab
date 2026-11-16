# Homebrew tap for MATLAB MCP Server

This independent tap packages the official [MathWorks MATLAB MCP Server](https://github.com/matlab/matlab-mcp-server) release binary for Apple Silicon Macs. The tap contains the formula only; Homebrew downloads the binary directly from MathWorks' GitHub release.

## Install and upgrade

```sh
brew install padhialuo0426/matlab/matlab-mcp-server
brew update
brew upgrade padhialuo0426/matlab/matlab-mcp-server
matlab-mcp-server --version
```

The server requires a separate, licensed MATLAB installation. In your MCP client, use the absolute path to Homebrew's `bin/matlab-mcp-server` and provide `--matlab-root` if MATLAB is not on its PATH. See the [upstream setup guide](https://github.com/matlab/matlab-mcp-server#manual-setup) for details.

## Maintenance

On a new [upstream release](https://github.com/matlab/matlab-mcp-server/releases), update the formula's URL, version, and SHA-256 using the official `matlab-mcp-server-macos-arm64` asset. Commit and push the formula change before running `brew update` and `brew upgrade` on client machines.
