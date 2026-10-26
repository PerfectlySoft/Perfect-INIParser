//
//  INIParserTests.swift
//  Perfect-INIParser
//
//  Created by Rockford Wei on 2017-04-25.
//  Copyright © 2017 PerfectlySoft. All rights reserved.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2017 - 2026 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import Testing
import Foundation
@testable import INIParser

/// The original sample file. Two of its lines end in "\r\n" (from PR #5).
private let sample =
  """
  ; last modified 1 April 2017 by Rockford Wei
  ## This is another comment
    freeVar1 = 1
    freeVar2 = 2;
    url = http://example.com/results?limit=10
    [owner]\r
    name =  Rocky\r
    organization = PerfectlySoft
    ;
    [database]
        server = 192.0.2.42 ; use IP address in case network name resolution is not working

        port = 143
        file = \"中文.dat  ' ' \"
    [汉化]
    变量1 = 🇨🇳 ;使用utf8
    变量2 = 加拿大。
    [ 乱死了 ]
  """

private func validate(_ ini: INIParser) {
  #expect(ini.anonymousSection["freeVar1"] == "1")
  #expect(ini.anonymousSection["freeVar2"] == "2")
  #expect(ini.anonymousSection["url"] == "http://example.com/results?limit=10")
  #expect(ini.sections["owner"]?["name"] == "Rocky")
  #expect(ini.sections["owner"]?["organization"] == "PerfectlySoft")
  #expect(ini.sections["database"]?["server"] == "192.0.2.42")
  #expect(ini.sections["database"]?["port"] == "143")
  #expect(ini.sections["database"]?["file"] == "\"中文.dat  \' \' \"")
  #expect(ini.sections["汉化"]?["变量1"] == "🇨🇳")
  #expect(ini.sections["汉化"]?["变量2"] == "加拿大。")
  // A section with no variables isn't listed.
  #expect(ini.sections["乱死了"] == nil)
  #expect(ini.sections.count == 3)
}

@Suite("INIParser")
struct INIParserTests {

  @Test func file() throws {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("INIParserTests-\(UUID().uuidString).ini")
    try sample.write(to: url, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(at: url) }
    validate(try INIParser(url.path))
  }

  @Test func data() throws {
    validate(try INIParser(data: Data(sample.utf8)))
  }

  @Test func string() throws {
    validate(try INIParser(string: sample))
  }

  /// Swift treats "\r\n" as one Character, so CRLF files used to come back as a single,
  /// garbled value: `a` was "1\r\ns\r\nb=2\r\n" and the rest was lost.
  @Test(arguments: ["\r\n", "\r", "\n"])
  func lineEndings(_ newline: String) throws {
    let ini = try INIParser(string: ["a = 1", "[s]", "b = 2", ""].joined(separator: newline))
    #expect(ini.anonymousSection == ["a": "1"])
    #expect(ini.sections == ["s": ["b": "2"]])
  }

  /// Windows editors often start UTF-8 files with a byte order mark. It used to become part of
  /// the first key when the text was passed as a String.
  @Test func byteOrderMarkIsSkipped() throws {
    #expect(try INIParser(data: Data("\u{FEFF}a = 1\r\n".utf8)).anonymousSection == ["a": "1"])
    #expect(try INIParser(string: "\u{FEFF}a = 1\r\n").anonymousSection == ["a": "1"])
  }

  /// A line of spaces used to throw InvalidSyntax.
  @Test func blankLinesAreIgnored() throws {
    let ini = try INIParser(string: "a = 1\n   \n\t\nb = 2")
    #expect(ini.anonymousSection == ["a": "1", "b": "2"])
  }

  /// Spaces inside a value, key or section name used to be removed ("John Smith" became
  /// "JohnSmith"). Only the surrounding spaces are trimmed now.
  @Test func innerSpacesAreKept() throws {
    let ini = try INIParser(string: "full name =  John Smith \n[ My Section ]\nkey = a b\tc")
    #expect(ini.anonymousSection == ["full name": "John Smith"])
    #expect(ini.sections == ["My Section": ["key": "a b\tc"]])
  }

  /// `[` and `]` in a value used to be dropped ("[1,2]" became "1,2").
  @Test func bracketsInValuesAreKept() throws {
    let ini = try INIParser(string: "list = [1,2]\nmap = a[b]c")
    #expect(ini.anonymousSection == ["list": "[1,2]", "map": "a[b]c"])
  }

  /// A `;` or `#` inside quotes used to drop the whole line, or throw InvalidSyntax.
  @Test func commentCharactersInsideQuotes() throws {
    let ini = try INIParser(string: """
      password = "a;b#c" ; the comment
      greeting = 'it''s; fine'
      mixed = "it's = ok"
      """)
    #expect(ini.anonymousSection["password"] == "\"a;b#c\"")
    #expect(ini.anonymousSection["greeting"] == "'it''s; fine'")
    #expect(ini.anonymousSection["mixed"] == "\"it's = ok\"")
  }

  @Test func equalsInValuesAndEmptyValues() throws {
    let ini = try INIParser(string: "query = a=1&b=2\nempty =\nalso =  ; nothing")
    #expect(ini.anonymousSection == ["query": "a=1&b=2", "empty": "", "also": ""])
  }

  @Test func laterValuesWinAndSectionsMerge() throws {
    let ini = try INIParser(string: "[s]\na = 1\n[t]\nx = 0\n[s]\na = 2\nb = 3")
    #expect(ini.sections == ["s": ["a": "2", "b": "3"], "t": ["x": "0"]])
  }

  @Test func commentsAreIgnored() throws {
    let ini = try INIParser(string: "; one\n# two\n   ; indented\na = 1 # trailing")
    #expect(ini.anonymousSection == ["a": "1"])
  }

  @Test(arguments: ["no equals sign", "a = \"unclosed", "a = 'unclosed", "[unclosed", "a = 1\nb"])
  func invalidSyntaxThrows(_ text: String) {
    #expect(throws: INIParser.Exception.InvalidSyntax) { try INIParser(string: text) }
  }

  @Test func invalidUTF8Throws() {
    #expect(throws: INIParser.Exception.InvalidFile) { try INIParser(data: Data([0x61, 0x20, 0x3D, 0xFF, 0xFE])) }
  }

  @Test func missingFileThrows() {
    #expect(throws: (any Error).self) { try INIParser("/nonexistent/\(UUID().uuidString).ini") }
  }

  @Test func isSendable() async throws {
    let ini = try INIParser(string: "a = 1")
    let value = await Task.detached { ini.anonymousSection["a"] }.value
    #expect(value == "1")
  }
}
