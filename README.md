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

The [update workflow](.github/workflows/autobump.yml) checks for new [upstream releases](https://github.com/matlab/matlab-mcp-server/releases) every hour, at minute 23. Before publishing an update, it verifies the official arm64 binary's SHA-256, MathWorks code signature, and reported version on an Apple Silicon runner. It opens and merges only its own formula update PR for the verified commit. A manual run also verifies the current binary by default.

For a manual update, use the URL, version, and SHA-256 of the official `matlab-mcp-server-macos-arm64` asset.
