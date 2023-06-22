---
layout: page
title: Setting up your development environment
octicon: package
toc: false
---

本ワークショップを始めるにあたって、開発環境の設定をして頂きます。
開発環境として、次のツールが必要です。

- [Visual Studio Code](https://code.visualstudio.com/)
- [CodeQL](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-codeql) extension
- [CodeQL CLI](https://github.com/github/codeql-cli-binaries/releases/latest)

次のステップで、環境を設定します。

1. [download page](https://code.visualstudio.com/Download)から、OSにあった最新のVisual Studio Codeをダウンロードします。設定手順は [setup](https://code.visualstudio.com/docs/setup/setup-overview)を参照ください。 

2. CodeQL extensionを[Extension Marketplace](https://code.visualstudio.com/docs/editor/extension-marketplace)からインストールします。

CodeQL extensionは、CodeQL CLIを自動でインストールと更新を行います。ただし、extensionでインストールされたCLIは、Visual Studio Codeのターミナル、もしくはbash, Powershell等のターミナルから使えないので、CodeQL packを作成したり、Databaseを作成する場合には、CodeQL CLIを別途インストールする必要があります。

CodeQL CLIのインストール、Visual Studio Code extensionの設定を次のステップで行います。インストレーション手順は [GitHub CLI](https://cli.github.com/)、または [authenticated](https://cli.github.com/manual/gh_auth_login)を参照ください。

1. Install the CodeQL CLI with the GitHub CLI (GH)

    For those that have GH you can install the CodeQL extension to manage CodeQL CLI installations:

    ```bash
    # Install the CodeQL extension
    gh install codeql

    # Install a CodeQL stub for use with the Visual Studio Code extension. Default directory is /usr/local/bin.
    # For convenience, make sure the chosen path is added to your path environment variable.
    # For Linux and MacOS, add it to the $PATH environment variable.
    # For Windows, add it to the %PATH% environment variable.
    gh codeql install-stub

    # Install the latest version
    gh codeql set-version latest
    ```

2. Install the CodeQL CLI manually

    To manually install the latest CodeQL CLI download the archive corresponding to your operating system from the [release](https://github.com/github/codeql-cli-binaries/releases/latest) page. Unzip the archive to a location of choice, then make sure that location is added to your path environment variable. For Linux and MacOS, add it to the `$PATH` environment variable. For Windows, add it to the `%PATH%` environment variable.

3. Verifying your CodeQL CLI setup

    The CodeQL CLI has subcommands that can help with verify that the CLI is correctly set up.

    Run the following command to show which languages are available for database creation.

    ```bash
    codeql resolve languages
    ```

    For the purpose of this workshop make sure that the `cpp` language is available.

4. Configuring the CodeQL extension

    With the CodeQL CLI installed we are going to configure the CodeQL extension to use the installed extension.

    Locate the setting `codeQL.cli.executablePath` in the [user and workspace settings](https://code.visualstudio.com/docs/getstarted/settings) and update it to the absolute path of the CodeQL CLI executable if is not part of your system's path environment or just `codeql` (`codeql.exe` for Windows). The extension will notify you of any problems in case of a misconfiguration.
