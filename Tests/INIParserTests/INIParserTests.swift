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
    func testExample() {
      let raw = "; last modified 1 April 2017 by Rockford Wei \t   \n ## This is another comment \n  freeVar1 = 1 \n freeVar2 = 2;  \n [owner]  \n " +
        "name =  Rocky \n  organization = PerfectlySoft \n     ; \n   [database] \n " +
        "\t\t server = 192.0.2.42 ; use IP address in case network name resolution is not working \n \n\n\n " +
      " port = 143 \n file = \"中文.dat\" \n      [汉化] \n    变量1 = 🇨🇳 ;使用utf8 \n   变量2 = 加拿大。   ~ \n  [ bad sec \n even worse ] \n [ 乱死了 ] \n = 没变量 \n novalue =  \n"
      let path = "/tmp/a.ini"
      let f = fopen(path, "w")
      fwrite(raw, 1, raw.utf8.count, f)
      fclose(f)
      do {
        let ini = try INIParser(path)
        XCTAssertEqual(ini.anonymousSection["freeVar1"] ?? "", "1")
        XCTAssertEqual(ini.anonymousSection["freeVar2"] ?? "", "2")
        XCTAssertEqual(ini.sections["[owner]"]?["name"] ?? "", "Rocky")
        XCTAssertEqual(ini.sections["[owner]"]?["organization"] ?? "", "PerfectlySoft")
        XCTAssertEqual(ini.sections["[database]"]?["server"] ?? "", "192.0.2.42")
        XCTAssertEqual(ini.sections["[database]"]?["port"] ?? "", "143")
        XCTAssertEqual(ini.sections["[database]"]?["file"] ?? "", "\"中文.dat\"")
        XCTAssertEqual(ini.sections["[汉化]"]?["变量1"] ?? "", "🇨🇳")
        XCTAssertEqual(ini.sections["[汉化]"]?["变量2"] ?? "", "加拿大。   ~")
      }catch (let err) {
        XCTFail(err.localizedDescription)
      }
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
