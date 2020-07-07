// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Package.swift
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

import PackageDescription

let package = Package(
    name: "INIParser",
    products: [
        .library(
            name: "INIParser",
            targets: ["INIParser"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "INIParser",
            dependencies: []),
        .testTarget(
            name: "INIParserTests",
            dependencies: ["INIParser"]),
    ]
)
