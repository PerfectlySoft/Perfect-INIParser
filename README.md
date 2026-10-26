# Perfect INI File Parser

<p align="center">
    <img src="https://img.shields.io/badge/Swift-6.2%2B-orange.svg?style=flat" alt="Swift 6.2+">
    <img src="https://img.shields.io/badge/Platforms-macOS%2012%2B%20%7C%20Linux-lightgray.svg?style=flat" alt="Platforms macOS 12+ | Linux">
    <a href="LICENSE" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache%202.0-lightgrey.svg?style=flat" alt="License Apache 2.0">
    </a>
</p>

A small, dependency-free parser for [INI](https://en.wikipedia.org/wiki/INI_file) configuration
files. It reads a file, `Data` or a `String` into a dictionary of sections, and accepts `\n`,
`\r\n` (Windows) and `\r` line endings. `INIParser` is `Sendable`, so a parsed configuration can
be shared across tasks.

The pre-Swift-6 version (4.0.0) is preserved on the [`legacy`](../../tree/legacy) branch; see
[Migrating from 4.x](#migrating-from-4x).

## Requirements

- Swift 6.2 or later (`swift-tools-version: 6.2`, Swift 6 language mode).
- macOS 12 or later, or Linux. CI covers Swift 6.2 and 6.4 on Ubuntu 24.04 and Xcode 26.0.1
  and 26.6 on macOS, in debug and release, with warnings as errors.
- No package dependencies.

## Using in your project

```swift
.package(url: "https://github.com/PerfectlySoft/Perfect-INIParser.git", from: "5.0.0"),
```

```swift
.product(name: "INIParser", package: "Perfect-INIParser"),
```

## Usage

```swift
import INIParser

let ini = try INIParser("/path/to/settings.ini")   // or INIParser(data:), INIParser(string:)

let port = ini.sections["database"]?["port"]        // "143"
let debug = ini.anonymousSection["debug"]           // a variable before any section
```

Given this file:

```ini
; comments start with ; or #
debug = true

[database]
server = 192.0.2.42   ; a trailing comment
port = 143
name = Main Database
password = "a;b#c"
```

`ini.anonymousSection` is `["debug": "true"]`, and `ini.sections["database"]` is
`["server": "192.0.2.42", "port": "143", "name": "Main Database", "password": "\"a;b#c\""]`.

### Syntax

- **Comments:** `;` or `#` starts a comment, on a line of its own or after a value. Inside quotes
  they're part of the value.
- **Sections:** `[name]` starts a section. Variables before the first section go in
  `anonymousSection`. A repeated section is merged into the earlier one, and a section with no
  variables doesn't appear in `sections`.
- **Assignments:** `key = value`. Keys, values and section names are trimmed of surrounding spaces
  and tabs; spaces inside them are kept. A value can contain `=`, `[` and `]`, and can be empty.
  A later assignment to the same key in the same section replaces the earlier one.
- **Quotes:** a value in `"…"` or `'…'` keeps its quotes, so `password = "a;b#c"` gives
  `"a;b#c"` with the quote marks. Strip them yourself if you don't want them.
- **Lines:** blank lines are ignored, and a UTF-8 byte order mark at the start of the file is skipped.

### Errors

`INIParser.Exception.InvalidSyntax` is thrown when:
- a line isn't blank, a comment, a section or an assignment (a key with no `=`, say);
- a quote or a `[` isn't closed.

`INIParser.Exception.InvalidFile` is thrown when the data isn't UTF-8. Errors from reading the file
itself are passed through unchanged.

## Migrating from 4.x

5.0 is the Swift 6 version. The API is the same: `INIParser(_:)`, `init(data:)`, `init(string:)`,
`sections`, `anonymousSection` and `INIParser.Exception`. Call sites keep compiling, apart from
the first item below. Some files now parse differently:

- **`INIParser` is a `final class` and `Sendable`.** Its properties are immutable. *Upgrade:* you
  can no longer subclass it.
- **The public `Stack<T>` helper is gone.** It was an internal detail. *Upgrade:* use an array.
- **Windows (`\r\n`) and classic Mac (`\r`) line endings work.** Before, such a file came back as a
  single garbled value (thanks to Ilia Sazonov, #5).
- **Spaces inside values, keys and section names are kept.** `name = John Smith` used to give
  `JohnSmith`, and `[My Section]` gave `MySection`. *Upgrade:* if you looked up keys or sections
  with the spaces removed, use the names as written in the file.
- **`[` and `]` inside a value are kept.** `list = [1,2]` used to give `1,2`.
- **`;` and `#` inside quotes are part of the value.** Such a line used to be dropped silently, or
  to throw `InvalidSyntax`.
- **Lines of only spaces or tabs are ignored.** They used to throw `InvalidSyntax`.
- **A leading UTF-8 byte order mark is skipped** when the text is passed as a `String`. It used
  to become part of the first key.

Everything else is unchanged.

## Legacy

The pre-Swift-6 code (4.0.0) is on the [`legacy`](../../tree/legacy) branch. Stay on 4.x if you
can't move to Swift 6.2.

## License

Apache 2.0. See [LICENSE](LICENSE).
