# userdic-ng
Convert Japanese Input Method Dictionary Files for Ruby

## Usage

```bash
./userdic-ng [--input-encoding ENCODING] [--output-encoding ENCODING] <from> <to> < input > output
```

`--input-encoding` and `--output-encoding` accept Ruby encoding names.
Examples: `UTF-8`, `UTF-16`, `UTF-16LE`, `CP932`, `EUC-JP`

- If input encoding is not specified, decoding falls back in this order: `UTF-16`, `CP932`, `EUC-JP`, `UTF-8`
- If output encoding is not specified, defaults remain type-specific:
  - `msime`, `atok`: `UTF-16`
  - `wnn`, `canna`: `EUC-JP`
  - other text formats: `UTF-8`
- `apple` format does not accept `--input-encoding` or `--output-encoding`
