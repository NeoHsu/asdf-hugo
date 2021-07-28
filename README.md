<div align="center">

# asdf-hugo ![Build](https://github.com/NeoHsu/asdf-hugo/workflows/Build/badge.svg) ![Lint](https://github.com/NeoHsu/asdf-hugo/workflows/Lint/badge.svg)

[hugo](https://gohugo.io/) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Build History

[![Build history](https://buildstats.info/github/chart/NeoHsu/asdf-hugo?branch=master)](https://github.com/NeoHsu/asdf-hugo/actions)

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Why?](#why)
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

hugo:

```shell
# Show all installable versions
asdf list-all hugo

# Install specific version
asdf install hugo latest

# Set a version globally (on your ~/.tool-versions file)
asdf global hugo latest

# Now hugo commands are available
hugo version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

## Extended builds for Sass/SCSS support

To install an extended Hugo version with Sass/SCSS support simply prefix the version number in the `asdf install` command with `extended_`.

```shell
# Install extended hugo version
asdf install hugo extended_0.85.0

# Now you can manage it like you're used to
asdf global hugo extended_0.85.0
```

**NOTE**: The extended builds for hugo are only available for 64bit Linux, macOS, and Windows.
See the asset list at https://github.com/gohugoio/hugo/releases/latest.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/NeoHsu/asdf-hugo/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Neo Hsu](https://github.com/NeoHsu/)
