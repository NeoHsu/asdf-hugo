#!/usr/bin/env bash

set -euo pipefail

# this is the correct GitHub homepage where releases can be downloaded for hugo.
GH_REPO="https://github.com/gohugoio/hugo"
TOOL_NAME="hugo"
TOOL_TEST="hugo version"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if hugo is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
  # Change this function if hugo has other means of determining installable versions.
  local tags
  tags=$(list_github_tags)
  echo "$tags"
}

# Parse a version string into a plain version path and its major/minor parts.
# Supports prefixes like "extended_" and "extended_withdeploy_".
parse_version() {
  local version="$1"
  local version_path="${version}"
  version_path="${version_path#extended_withdeploy_}"
  version_path="${version_path#extended_}"
  local major_version
  major_version=$(echo "$version_path" | awk -F. '{print $1}')
  local minor_version
  minor_version=$(echo "$version_path" | awk -F. '{print $2}')
  printf '%s %s %s' "$version_path" "$major_version" "$minor_version"
}

# Determine release extension to download for a given version (tar.gz or pkg)
get_release_ext() {
  local version="$1"
  read -r version_path major_version minor_version <<<"$(parse_version "$version")"
  local platform
  platform=$(get_platform)

  # For macOS (darwin) use .pkg for Hugo minor versions greater than or equal to 153 (since v0.153.0)
  if [ "${platform}" = "darwin" ] && [ "${major_version}" -eq "0" ] && [ "${minor_version}" -ge "153" ]; then
    echo "pkg"
  else
    echo "tar.gz"
  fi
}

get_arch() {
  local arch=""

  case "$(uname -m)" in
    x86_64 | amd64) arch="64bit" ;;
    i686 | i386) arch="32bit" ;;
    armv6l | armv7l) arch="ARM" ;;
    aarch64 | arm64) arch="ARM64" ;;
    *)
      fail "Arch '$(uname -m)' not supported!"
      ;;
  esac

  echo -n $arch
}

get_platform() {
  local platform=""

  case "$(uname | tr '[:upper:]' '[:lower:]')" in
    darwin) platform="darwin" ;;
    linux) platform="Linux" ;;
    windows) platform="Windows" ;;
    openbsd) platform="OpenBSD" ;;
    netbsd) platform="NetBSD" ;;
    freebsd) platform="FreeBSD" ;;
    dragonfly) platform="DragonFlyBSD" ;;
    *)
      fail "Platform '$(uname -m)' not supported!"
      ;;
  esac

  echo -n $platform
}

download_release() {
  local version="$1"
  local version_path
  local filename="$2"
  read -r version_path major_version minor_version <<<"$(parse_version "$version")"
  local platform
  platform=$(get_platform)

  # For Mac downloads use universal binaries for releases >= 0.102.0
  local arch
  if [ "${platform}" = "darwin" ] && [ "${major_version}" -eq "0" ] && [ "${minor_version}" -ge "102" ]; then
    arch="universal"
  else
    arch=$(get_arch)
  fi

  # v0.103.0 changed naming conventions on the Hugo releases. This reverts if trying to install older version of Hugo.
  if [ "${platform}" = "darwin" ] && [ "${major_version}" -eq "0" ] && [ "${minor_version}" -lt "103" ]; then
    local platform="macOS"
  fi

  local ext
  ext=$(get_release_ext "$version")
  local url="${GH_REPO}/releases/download/v${version_path}/hugo_${version}_${platform}-${arch}.${ext}"

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

# Extract a downloaded release (tar.gz or pkg) and place the `hugo` binary
# at $ASDF_DOWNLOAD_PATH/$TOOL_NAME
extract_release() {
  local filename="$1"

  mkdir -p "$ASDF_DOWNLOAD_PATH"
  if [[ "$filename" == *.pkg ]]; then
    # Set up cleanup function for pkg extraction
    cleanup_pkg_files() {
      rm -f "$ASDF_DOWNLOAD_PATH/Payload" \
        "$ASDF_DOWNLOAD_PATH/PackageInfo" \
        "$ASDF_DOWNLOAD_PATH/Distribution"
      rm -rf "$ASDF_DOWNLOAD_PATH/Resources" "$ASDF_DOWNLOAD_PATH/Scripts"
    }

    # Extract xar entries directly into the ASDF download path
    (cd "$ASDF_DOWNLOAD_PATH" && xar -xf "$filename") || fail "Could not extract xar from $filename"
    [ -f "$ASDF_DOWNLOAD_PATH/Payload" ] || fail "Payload not found inside pkg $filename"

    # Extract only the hugo file from the Payload into the download path
    if ! gzip -dc "$ASDF_DOWNLOAD_PATH/Payload" | (cd "$ASDF_DOWNLOAD_PATH" && cpio -idm ./hugo) >/dev/null 2>&1; then
      cleanup_pkg_files
      fail "Could not extract hugo from Payload $filename"
    fi

    # Clean up xar-extracted metadata files to keep the download path tidy
    cleanup_pkg_files

    # Remove the original pkg file now that we have extracted hugo
    rm -f "$filename"
  elif [[ "$filename" == *.tar.gz ]]; then
    # Extract directly into the ASDF download path
    tar -xzf "$filename" -C "$ASDF_DOWNLOAD_PATH" || fail "Could not extract $filename"
    rm -f "$filename"
  else
    fail "Unknown release format for $filename"
  fi
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path/bin"
    # Ensure the release is extracted and the `hugo` binary is available
    ext=$(get_release_ext "$version")
    release_file="$ASDF_DOWNLOAD_PATH/$TOOL_NAME-$version.$ext"
    [ -f "$release_file" ] || fail "Release file for $TOOL_NAME $version not found in $ASDF_DOWNLOAD_PATH"

    extract_release "$release_file"

    # Ensure hugo executable exists and make it executable
    [ -f "$ASDF_DOWNLOAD_PATH/$TOOL_NAME" ] || fail "hugo executable not found after extracting $release_file"
    chmod +x "$ASDF_DOWNLOAD_PATH/$TOOL_NAME"

    cp -r "$ASDF_DOWNLOAD_PATH/$TOOL_NAME" "$install_path/bin/"

    local tool_cmd
    tool_cmd=$(echo "$TOOL_TEST" | cut -d' ' -f1)
    test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}
