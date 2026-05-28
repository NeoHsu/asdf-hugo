<div align="center">

# asdf-hugo ![Build](https://github.com/NeoHsu/asdf-hugo/workflows/Build/badge.svg) ![Lint](https://github.com/NeoHsu/asdf-hugo/workflows/Lint/badge.svg)

[hugo](https://gohugo.io/) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Build History

[![Build history](https://buildstats.info/github/chart/NeoHsu/asdf-hugo?branch=master)](https://github.com/NeoHsu/asdf-hugo/actions)

# Contents

- [asdf-hugo  ](#asdf-hugo--)
- [Build History](#build-history)
- [Contents](#contents)
- [Dependencies](#dependencies)
- [Install](#install)
  - [Version variants](#version-variants)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.

# Install

Plugin:

```shell
asdf plugin add hugo
# or
asdf plugin add hugo https://github.com/NeoHsu/asdf-hugo.git
```

Hugo:

```shell
# Show all installable versions
asdf list all hugo

# Install the latest regular Hugo release
asdf install hugo latest

# Set a version for your user (writes to your ~/.tool-versions)
asdf set -u hugo latest

# Now hugo commands are available
hugo version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

## Version variants

This plugin supports the Hugo editions published in the official
[gohugoio/hugo releases](https://github.com/gohugoio/hugo/releases):

| Variant | Latest alias | Specific version example | Notes |
| --- | --- | --- | --- |
| Regular | `latest` | `0.162.0` | Standard Hugo release. |
| Extended | `latest:extended` | `extended-0.162.0` | Includes Sass/SCSS support. |
| Extended with deploy | `latest:extended_withdeploy` | `extended_withdeploy-0.162.0` | Includes extended plus deploy/cloud functionality. |

Install the latest release for each variant:

```shell
# Regular Hugo
asdf install hugo latest
asdf set -u hugo latest

# Extended Hugo
asdf install hugo latest:extended
asdf set -u hugo latest:extended

# Extended Hugo with deploy support
asdf install hugo latest:extended_withdeploy
asdf set -u hugo latest:extended_withdeploy
```

Install a specific release:

```shell
# Regular Hugo
asdf install hugo 0.162.0
asdf set -u hugo 0.162.0

# Extended Hugo
asdf install hugo extended-0.162.0
asdf set -u hugo extended-0.162.0

# Extended Hugo with deploy support
asdf install hugo extended_withdeploy-0.162.0
asdf set -u hugo extended_withdeploy-0.162.0
```

The plugin also accepts underscore separators for compatibility, such as `extended_0.162.0` and
`extended_withdeploy_0.162.0`.

See the [Editions section in the Hugo README](https://github.com/gohugoio/hugo/blob/master/README.md#editions) for more
details.

**NOTE**: The extended builds for Hugo (including the with-deploy edition) are only available for 64bit Linux, macOS,
and Windows. See the asset list at https://github.com/gohugoio/hugo/releases/latest.


# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/NeoHsu/asdf-hugo/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Neo Hsu](https://github.com/NeoHsu/)
