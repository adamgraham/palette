//
//  main.swift
//  color-tools
//
//  Created by Adam Graham on 1/9/19.
//  Copyright © 2019 Adam Graham. All rights reserved.
//

import AppKit
import Foundation

// MARK: Validation

let args = CommandLine.arguments

guard args.count > 1 else {
    print("[Error]: No arguments provided")
    print("[Usage]: ./color-tools {input_path} {output_path}")
    exit(1)
}

// MARK: Parse Input

let colors: [Color]

do {
    let inputURL = URL(fileURLWithPath: args[1])
    print("[Working]: Parsing colors at \(inputURL)")
    colors = try parseColors(at: inputURL)
} catch let error {
    print("[Error]: \(error)")
    exit(1)
}

guard colors.count > 0 else {
    print("[Error]: No colors found")
    exit(1)
}

// MARK: Compose Output

do {
    let outputURL = args.count > 2 ? URL(fileURLWithPath: args[2]) : nil
    let outputName = outputURL?.deletingPathExtension().lastPathComponent ?? "Unnamed"
    print("[Working]: Generating color palette")
    let colorPalette = try composePalette(from: colors, at: outputURL)
    print("[Working]: Writing colors to file")
    try colorPalette.write(to: outputURL)
    print("[Success]: Color palette '\(outputName)\' created at \(outputURL ?? URL(fileURLWithPath: "~/Library/Colors/\(outputName).clr"))")
    exit(0)
} catch let error {
    print("[Error]: \(error)")
    exit(1)
}
