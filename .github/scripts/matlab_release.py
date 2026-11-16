"""Read the official stable release and update only the formula's release fields."""

import json
import re
import sys
from pathlib import Path


FORMULA = Path("Formula/matlab-mcp-server.rb")
UPSTREAM = "https://github.com/matlab/matlab-mcp-server"
ASSET = "matlab-mcp-server-macos-arm64"
STABLE = r"(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)"


def url_for(version):
    return f"{UPSTREAM}/releases/download/v{version}/{ASSET}"


def digest_for(value):
    if not re.fullmatch(r"[a-f0-9]{64}", value):
        raise ValueError("Expected a lowercase SHA-256 digest")
    return value


def version_key(value):
    if not re.fullmatch(STABLE, value):
        raise ValueError("Expected a stable three-component version")
    return tuple(map(int, value.split(".")))


def field(source, name):
    pattern = rf'^  {name} "([^"\r\n]+)"$'
    matches = re.findall(pattern, source, re.MULTILINE)
    if len(matches) != 1:
        raise ValueError(f"Expected exactly one {name} field in the formula")
    return matches[0], pattern


def probe(source, metadata):
    if metadata.get("draft") is not False or metadata.get("prerelease") is not False:
        raise ValueError("Upstream did not return a published stable release")
    tag = metadata["tag_name"]
    if not tag.startswith("v"):
        raise ValueError("Expected a release tag with a v prefix")
    version = tag[1:]
    assets = [asset for asset in metadata["assets"] if asset["name"] == ASSET]
    if len(assets) != 1 or assets[0]["browser_download_url"] != url_for(version):
        raise ValueError("Expected one official Apple Silicon release asset")
    digest_type, _, digest = (assets[0].get("digest") or "").partition(":")
    if digest_type != "sha256":
        raise ValueError("The release asset has no published SHA-256")
    digest_for(digest)

    current = field(source, "version")[0]
    latest_key, current_key = version_key(version), version_key(current)
    if latest_key < current_key:
        raise ValueError("Refusing to downgrade the formula")
    if latest_key == current_key:
        if (field(source, "url")[0], field(source, "sha256")[0]) != (url_for(version), digest):
            raise ValueError("Upstream metadata changed for the already published version")
    print(f"version={version}\nsha256={digest}\noutdated={str(latest_key > current_key).lower()}")
    print(f"Tap: {current}; upstream: {version}", file=sys.stderr)


def render(source, version, digest):
    if version_key(version) <= version_key(field(source, "version")[0]):
        raise ValueError("Refusing to write a version that is not newer")
    values = {"url": url_for(version), "version": version, "sha256": digest_for(digest)}
    for name, value in values.items():
        _, pattern = field(source, name)
        source = re.sub(pattern, lambda _: f'  {name} "{value}"', source, flags=re.MULTILINE)
    return source


if __name__ == "__main__":
    action, *args = sys.argv[1:]
    source = FORMULA.read_text()
    if action == "probe" and len(args) == 1:
        probe(source, json.loads(Path(args[0]).read_text()))
    elif action == "apply" and len(args) == 2:
        FORMULA.write_text(render(source, *args))
    else:
        sys.exit("Usage: matlab_release.py probe RELEASE_JSON | apply VERSION SHA256")
