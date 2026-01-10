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
  - [Extended builds for Sass/SCSS support and deploy edition](#extended-builds-for-sassscss-support-and-deploy-edition)
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
asdf list all hugo

# Install specific version
asdf install hugo latest

# Set a version for your user (writes to your ~/.tool-versions)
asdf set -u hugo latest

# Now hugo commands are available
hugo version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

## Extended builds for Sass/SCSS support and deploy edition

To install an extended Hugo version with Sass/SCSS support simply prefix the version number in the `asdf install`
command with `extended_`.

```shell
# Install extended hugo version
asdf install hugo extended_0.154.3

# Now you can manage it like you're used to
asdf set -u hugo extended_0.154.3
```

There is also an "extended/deploy" variant which includes the extended build plus additional deployment/cloud
functionality.

```shell
# Install extended/deploy hugo version
asdf install hugo extended_withdeploy-0.154.3

# Manage it the same way
asdf set --home hugo extended_withdeploy-0.154.3
```

See the [Editions section in the Hugo README](https://github.com/gohugoio/hugo/blob/master/README.md#editions) for more
details.

**NOTE**: The extended builds for Hugo (including the with-deploy edition) are only available for 64bit Linux, macOS,
and Windows. See the asset list at https://github.com/gohugoio/hugo/releases/latest.


# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/NeoHsu/asdf-hugo/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Neo Hsu](https://github.com/NeoHsu/)
