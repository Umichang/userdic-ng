# userdic-ng
Convert Japanese Input Method Dictionary Files for Ruby

Current version: `2.1`

## Layout

- `bin/userdic-ng`: GitHub 配布向けの実行エントリポイント
- `userdic.rb`: CLI 実装本体
- `hinshi`, `mkhinshi.rb`: 品詞マップ生成元

GitHub から clone / download したら、そのまま `bin/userdic-ng` を使う前提です。`make dist` による配布アーカイブ生成は廃止しました。

従来どおり `/usr/local/bin/userdic-ng` で使いたい場合は、リポジトリ直下で `make install` を実行してください。

## Usage

```bash
bin/userdic-ng [--input-encoding ENCODING] [--output-encoding ENCODING] <from> <to> < input > output
```

```bash
bin/userdic-ng --version
```

`--input-encoding` and `--output-encoding` accept Ruby encoding names.
Examples: `UTF-8`, `UTF-16`, `UTF-16LE`, `CP932`, `EUC-JP`

- If input encoding is not specified, decoding falls back in this order: `UTF-16`, `CP932`, `EUC-JP`, `UTF-8`
- If output encoding is not specified, defaults remain type-specific:
  - `msime`, `atok`: `UTF-16`
  - `wnn`, `canna`: `EUC-JP`
  - other text formats: `UTF-8`
- `apple` format does not accept `--input-encoding` or `--output-encoding`

## Development

```bash
make test
make install
```
