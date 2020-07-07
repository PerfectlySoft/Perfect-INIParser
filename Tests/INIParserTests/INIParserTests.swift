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
// Copyright (c) 2017 - 2018 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import XCTest
@testable import INIParser

class INIParserTests: XCTestCase {

  let path = "/tmp/a.ini"

  override func setUp() {
    let raw =
    """
    ; last modified 1 April 2017 by Rockford Wei
    ## This is another comment
      freeVar1 = 1
      freeVar2 = 2;
      url = http://example.com/results?limit=10
      [owner]
      name =  Rocky
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
    do {
      try raw.write(to: URL.init(fileURLWithPath: path), atomically: true, encoding: .utf8)
    }catch (let err) {
      XCTFail(err.localizedDescription)
    }
  }

  func validate(ini: INIParser) {
    XCTAssertEqual(ini.anonymousSection["freeVar1"] ?? "", "1")
    XCTAssertEqual(ini.anonymousSection["freeVar2"] ?? "", "2")
    XCTAssertEqual(ini.anonymousSection["url"] ?? "", "http://example.com/results?limit=10")
    XCTAssertEqual(ini.sections["owner"]?["name"] ?? "", "Rocky")
    XCTAssertEqual(ini.sections["owner"]?["organization"] ?? "", "PerfectlySoft")
    XCTAssertEqual(ini.sections["database"]?["server"] ?? "", "192.0.2.42")
    XCTAssertEqual(ini.sections["database"]?["port"] ?? "", "143")
    XCTAssertEqual(ini.sections["database"]?["file"] ?? "", "\"中文.dat  \' \' \"")
    XCTAssertEqual(ini.sections["汉化"]?["变量1"] ?? "", "🇨🇳")
    XCTAssertEqual(ini.sections["汉化"]?["变量2"] ?? "", "加拿大。")
  }

  func testExample() {
    do {
      let ini = try INIParser(path)
      validate(ini: ini)
    }catch (let err) {
      XCTFail(err.localizedDescription)
    }
  }

  func testData() {
    do {
      let url = URL(fileURLWithPath: path)
      let data = try Data(contentsOf: url)
      let ini = try INIParser(data: data)
      validate(ini: ini)
    }catch (let err) {
      XCTFail(err.localizedDescription)
    }
  }

  func testString() {
    do {
      let url = URL(fileURLWithPath: path)
      let data = try Data(contentsOf: url)
      let string = String(data: data, encoding: .utf8) ?? "fault"
      let ini = try INIParser(string: string)
      validate(ini: ini)
    }catch (let err) {
      XCTFail(err.localizedDescription)
    }
  }

  override func tearDown() {
    unlink(path)
  }

  static var allTests = [
    ("testExample", testExample),
    ("testData", testData),
    ("testString", testString)
  ]
}
