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
- [CodeQL CLI](https://github.com/github/codeql-action/releases)

次のステップで、環境を設定します。

1. [download page](https://code.visualstudio.com/Download)から、OSにあった最新のVisual Studio Codeをダウンロードします。設定手順は [setup](https://code.visualstudio.com/docs/setup/setup-overview)を参照ください。 

2. CodeQL extensionを[Extension Marketplace](https://code.visualstudio.com/docs/editor/extension-marketplace)からインストールします。

CodeQL extensionは、CodeQL CLIを自動でインストールと更新を行います。ただし、extensionでインストールされたCLIは、Visual Studio Codeのターミナル、もしくはbash, Powershell等のターミナルから使えないので、CodeQL packを作成したり、Databaseを作成する場合には、CodeQL CLIを別途インストールする必要があります。

CodeQL CLIのインストール、Visual Studio Code extensionの設定を次のステップで行います。インストレーション手順は [GitHub CLI](https://cli.github.com/)、または [authenticated](https://cli.github.com/manual/gh_auth_login)を参照ください。

1.  CodeQL CLI のインストール

    [CodeQL CLI](https://github.com/github/codeql-action/releases)から、OSにあったCodeQLをダウンロードします。ダウンロードしたファイルはアーカイブされているので、unzipコマンドで解凍します。解凍後のディレクトリをLinux,MacOSの場合には、`$PATH`に追加、Windowsの場合には、`%PATH%`に追加します。

2. CodeQL CLIのセットアップの完了を確認 

    CodeQL CLIが正しくセットアップできたか以下のコマンドを使って確認します。実行すると対応する言語のリストが表示されます。

    ```bash
    codeql resolve languages
    ```
    `cpp` `javascript` `python`言語が有効であることをこのコマンドで確認します。

3. CodeQL extensionの環境設定

    インストールしたCodeQLをVisual Studio Codeで利用するための設定をこちらで行います。

    Visual Studio Codeの設定から、`codeQL.cli.executablePath`を検索します。ここでCodeQL CLIのパスを設定します。空白の場合には、OSのPATHを参照します。Visual Studio Codeの設定方法については、 [user and workspace settings](https://code.visualstudio.com/docs/getstarted/settings)を参照してください。 OSのPATHにCodeQL CLIのディレクトリを設定していない場合には、こちらに `codeql` (`codeql.exe` for Windows)を指定します。
