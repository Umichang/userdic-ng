# userdic-ng
日本語入力用辞書ファイルの変換ツール

現在のバージョン: `2.1`

`userdic-ng` は、日本語入力システム用の辞書ファイルを相互変換する Ruby 製の CLI ツールです。

## 構成

- `bin/userdic-ng`: 実行用エントリポイント
- `userdic.rb`: CLI 実装本体
- `hinshi`, `mkhinshi.rb`: 品詞対応表の生成元

GitHub から clone / download したら、そのまま `bin/userdic-ng` を使えます。`make dist` による配布アーカイブ生成は廃止しました。

従来どおり `/usr/local/bin/userdic-ng` として使いたい場合は、リポジトリ直下で `make install` を実行してください。

## 使い方

```bash
bin/userdic-ng [--input-encoding ENCODING] [--output-encoding ENCODING] <from> <to> < input > output
```

```bash
bin/userdic-ng --version
```

`--input-encoding` と `--output-encoding` には Ruby のエンコーディング名を指定できます。
例: `UTF-8`, `UTF-16`, `UTF-16LE`, `CP932`, `EUC-JP`

- 入力エンコーディングを省略した場合は、`UTF-16` → `CP932` → `EUC-JP` → `UTF-8` の順で判定します
- 出力エンコーディングを省略した場合の既定値は以下のとおりです
  - `msime`, `atok`: `UTF-16`
  - `wnn`, `canna`: `EUC-JP`
  - それ以外のテキスト形式: `UTF-8`
- `apple` 形式では `--input-encoding` と `--output-encoding` は使用できません

## 対応形式

入出力で指定できる形式は以下です。

- `mozc`
- `google`
- `anthy`
- `canna`
- `atok`
- `msime`
- `wnn`
- `apple`
- `generic`

## インストール

GitHub から取得した状態でそのまま使う場合:

```bash
bin/userdic-ng --version
```

`/usr/local/bin/userdic-ng` としてインストールする場合:

```bash
make install
```

権限が必要な環境では `sudo make install` を使ってください。

## 開発

```bash
make test
make install
```
