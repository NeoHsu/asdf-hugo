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
  local tags=$(list_github_tags)
  echo "$tags"
}

# Determine release extension to download for a given version (tar.gz or pkg)
get_release_ext() {
  local version="$1"
  local version_path="${version//extended_/}"
  local major_version=$(echo "$version_path" | awk -F. '{print $1}')
  local minor_version=$(echo "$version_path" | awk -F. '{print $2}')
  local platform=$(get_platform)

  # For macOS (darwin) use .pkg for Hugo minor versions greater than 153
  if [ "${platform}" = "darwin" ] && [ "${major_version}" -eq "0" ] && [ "${minor_version}" -gt "153" ]; then
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
  local version_path="${version//extended_/}"
  local filename="$2"
  local platform=$(get_platform)
  local major_version=$(echo "$version_path" | awk -F. '{print $1}')
  local minor_version=$(echo "$version_path" | awk -F. '{print $2}')

  # For Mac downloads use universal binaries for releases >= 0.102.0
  if [ "${platform}" = "darwin" ] && [ "${major_version}" -eq "0" ] && [ "${minor_version}" -ge "102" ]; then
    local arch="universal"
  else
    local arch=$(get_arch)
  fi

  # v0.103.0 changed naming conventions on the Hugo releases. This reverts if trying to install older version of Hugo.
  if [ "${platform}" = "darwin" ] && [ "${major_version}" -eq "0" ] && [ "${minor_version}" -lt "103" ]; then
    local platform="macOS"
  fi

  local ext=$(get_release_ext "$version")
  local url="${GH_REPO}/releases/download/v${version_path}/hugo_${version}_${platform}-${arch}.${ext}"

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
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

    # If a macOS .pkg was downloaded use the system installer.
    pkg_file=$(ls "$ASDF_DOWNLOAD_PATH"/hugo_*"${version}"*.pkg 2>/dev/null || true)
    if [ -n "${pkg_file}" ]; then
      echo "* Installing $TOOL_NAME from pkg ${pkg_file} to ${install_path}..."
      installer -pkg "${pkg_file}" -target "${install_path}" || fail "Failed to run installer on ${pkg_file}"
    else
      cp -r "$ASDF_DOWNLOAD_PATH/$TOOL_NAME" "$install_path/bin/"
    fi

    # Assert hugo executable exists
    local tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}
