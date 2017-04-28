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
// Copyright (c) 2017 - 2018 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

#if os(Linux)
  import SwiftGlibc
#else
  import Darwin
#endif

/// INI Configuration File Reader
public class INIParser {

  internal var _sections: [String: [String: String]] = [:]
  internal var _anonymousSection: [String: String] = [:]

  public var sections: [String:[String:String]] { get { return _sections } }
  public var anonymousSection: [String: String] { get { return _anonymousSection } }

  public enum Exception: Error {
    case InvalidFile, IncompleteReading, RegexFault
  }//end enum

  private var reg_sec = regex_t()

  private func trim(_ word: String) -> String {
    var buf = [UInt8]()
    var trimming = true
    for c in word.utf8 {
      if trimming && c < 33 { continue }
      trimming = false
      buf.append(c)
    }//end ltrim
    while let last = buf.last, last < 33 {
      buf.removeLast()
    }//end rtrim
    buf.append(0)
    return String(cString: buf)
  }//end trim

  internal func parseSection(_ line: String) -> String? {
    var p = regmatch_t()
    guard 0 == regexec(&reg_sec, line, 1, &p, 0), let s = strdup(line) else {
      return nil
    }//end guard
    s.advanced(by: Int(p.rm_eo)).pointee = 0
    let section = trim(String(cString: s.advanced(by: Int(p.rm_so))))
    free(s)
    return section
  }//end parseSection

  internal func parseEquation(_ line: String) -> (key:String, value: String)? {
    if let word = strdup(line) {
      if let eq = strchr(word, 61) {
        if eq == word {
          free(word)
          return nil
        }//end if
        eq.pointee = 0
        let key = trim(String(cString: word))
        let value = trim(String(cString: eq.advanced(by: 1)))
        free(word)
        if key.isEmpty || value.isEmpty {
          return nil
        }else{
          return (key: key, value: value)
        }//end if
      }//end if
      free(word)
    }//end if
    return nil
  }//end parseEquation

  internal func decommented(line: String) -> String {
    guard let first = line.utf8.first, first != 59 && first != 35 else { return "" }
    return line
  }//end func

  deinit {
    regfree(&reg_sec)
  }//end deinit

  /// Constructor
  /// - parameters:
  ///   - path: path of INI file to load
  /// - throws:
  ///   Exception
  public init(_ path: String) throws {
    guard 0 == regcomp(&reg_sec, "\\[(.*)\\]", REG_EXTENDED) else {
      throw Exception.RegexFault
    }
    var st = stat()
    let r = lstat(path, &st)
    let size = Int(st.st_size)
    guard r == 0, size > 0, let f = fopen(path, "r") else {
      throw Exception.InvalidFile
    }
    let buf = UnsafeMutablePointer<Int8>.allocate(capacity: size + 1)
    let count = fread(buf, 1, size, f)
    guard count == size else {
      buf.deallocate(capacity: size + 1)
      throw Exception.IncompleteReading
    }//end guard
    buf.advanced(by: size).pointee = 0
    let content = String(cString: buf)
    buf.deallocate(capacity: size + 1)
    let lines = content.utf8.split(separator: 10)
      .map { decommented(line: trim(String(describing: $0))) }
      .filter { !$0.isEmpty }
    var section = ""
    for line in lines {
      if let title = parseSection(line) {
        section = title
        continue
      }else if let eq = parseEquation(line) {
        if section.isEmpty {
          _anonymousSection[eq.key] = eq.value
        }else {
          var sec = _sections[section] ?? [:]
          sec[eq.key] = eq.value
          _sections[section] = sec
        }//end if
      }//end if
    }//next
  }//end init
}//end INIReader
