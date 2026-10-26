//
//  INIParser.swift
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

import Foundation

/// INI Configuration File Reader
///
/// Lines may end in `\n`, `\r\n` or `\r`. On each line, `;` or `#` starts a comment (outside
/// quotes), `[name]` starts a section, and `key = value` assigns a value. Keys, values and section
/// names are trimmed of surrounding spaces and tabs; spaces inside them are kept. A quoted value
/// keeps its quotes, and `;`, `#`, `[`, `]` and `=` inside quotes are part of the value. A variable
/// that appears before any section goes in `anonymousSection`. A later assignment to the same
/// variable in the same section replaces the earlier one, and repeated sections are merged.
public final class INIParser: Sendable {

  /// Variables by section name, then variable name. Sections with no variables are left out.
  public let sections: [String: [String: String]]
  /// Variables that appear before the first section.
  public let anonymousSection: [String: String]

  public enum Exception: Error, Sendable {
    /// A line isn't a comment, a section or an assignment, or a quote or `[` isn't closed.
    case InvalidSyntax
    /// The data isn't UTF-8 text.
    case InvalidFile
  }

  enum State {
    case Title, Variable, Value, SingleQuotation, DoubleQuotation
  }

  enum ContentType: Equatable {
    case Section(String)
    case Assignment(String, String)
  }

  internal static func parse(line: String) throws -> ContentType? {
    var cache = ""
    var state = State.Variable
    // The state to return to when a quotation closes.
    var beforeQuotation = State.Variable

    var variable: String? = nil
    for c in line {
      switch c {
      case "[" where state == .Variable && cache.isBlank:
        cache = ""
        state = .Title
      case "]" where state == .Title:
        return ContentType.Section(cache.trimmed)
      case "=" where state == .Variable:
        variable = cache.trimmed
        cache = ""
        state = .Value
      case "#", ";":
        if state == .SingleQuotation || state == .DoubleQuotation {
          cache.append(c)
        } else if state == .Value, let v = variable {
          return ContentType.Assignment(v, cache.trimmed)
        } else {
          return nil
        }
      case "\"" where state != .SingleQuotation && state != .Title:
        if state == .DoubleQuotation {
          state = beforeQuotation
        } else {
          beforeQuotation = state
          state = .DoubleQuotation
        }
        cache.append(c)
      case "\'" where state != .DoubleQuotation && state != .Title:
        if state == .SingleQuotation {
          state = beforeQuotation
        } else {
          beforeQuotation = state
          state = .SingleQuotation
        }
        cache.append(c)
      default:
        cache.append(c)
      }
    }
    guard state == .Value, let v = variable else {
      throw Exception.InvalidSyntax
    }
    return ContentType.Assignment(v, cache.trimmed)
  }

  /// Convenience constructor
  /// - parameters:
  ///   - path: path of INI file to load
  /// - throws:
  ///   Exception
  public convenience init(_ path: String) throws {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    try self.init(data: data)
  }

  /// Convenience constructor
  /// - parameters:
  ///   - data: Data of an INI file, in UTF-8 (a leading byte order mark is skipped)
  /// - throws:
  ///   Exception
  public convenience init(data: Data) throws {
    guard let text = String(bytes: data, encoding: .utf8) else {
      throw Exception.InvalidFile
    }
    try self.init(string: text)
  }

  /// Constructor
  /// - parameters:
  ///   - string: String content of an INI file
  /// - throws:
  ///   Exception
  public init(string: String) throws {
    var text = Substring(string)
    if text.first == "\u{FEFF}" { text = text.dropFirst() }
    // Swift treats "\r\n" as one Character, so splitting on "\n" alone leaves CRLF files unsplit.
    let lines = text.split(omittingEmptySubsequences: true) { $0.isNewline }
    var sections: [String: [String: String]] = [:]
    var anonymousSection: [String: String] = [:]
    var title: String? = nil
    for line in lines where !String(line).isBlank {
      switch try Self.parse(line: String(line)) {
      case .Section(let newTitle):
        title = newTitle
      case .Assignment(let variable, let value):
        if let currentTitle = title {
          sections[currentTitle, default: [:]][variable] = value
        } else {
          anonymousSection[variable] = value
        }
      case nil:
        break
      }
    }
    self.sections = sections
    self.anonymousSection = anonymousSection
  }
}

extension String {
  /// Without leading and trailing spaces and tabs.
  var trimmed: String { trimmingCharacters(in: CharacterSet(charactersIn: " \t")) }
  /// Empty, or only spaces and tabs.
  var isBlank: Bool { allSatisfy { $0 == " " || $0 == "\t" } }
}
