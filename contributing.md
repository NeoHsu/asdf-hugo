# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test hugo https://github.com/NeoHsu/asdf-hugo.git "hugo --version"
```

Tests are automatically run in GitHub Actions on push and PR.
