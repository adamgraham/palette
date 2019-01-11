//
//  main.swift
//  color-tools
//
//  Created by Adam Graham on 1/9/19.
//  Copyright © 2019 Adam Graham. All rights reserved.
//

import AppKit
import Foundation

let args = CommandLine.arguments

guard args.count > 1 else {
    print("[Error]: No arguments provided")
    print("[Usage]: ./color-tools {input_file_path} {output_file_name}")
    exit(1)
}

let filePath = args[1]
let colors: [Color]

do {
    print("[Working]: Parsing colors at path \"\(filePath)\"")

    switch filePath {
    case _ where filePath.contains(".txt"):
        colors = try parseColors(txt: filePath)
    case _ where filePath.contains(".plist"):
        colors = try parseColors(plist: filePath)
    case _ where filePath.contains(".swift"):
        colors = try parseColors(swift: filePath)
    default:
        print("[Error]: Invalid file path - must include .txt, .plist, or .swift extension")
        exit(1)
    }
} catch let error {
    print("[Error]: \(error)")
    exit(1)
}

guard colors.count > 0 else {
    print("[Error]: No colors found")
    exit(1)
}

print("[Working]: Generating color list")

let outputName = args.count > 2 ? args[2] : "Unnamed"
let colorList = NSColorList(name: outputName)

for color in colors {
    print("[Working]: Adding color \(color.name, color.nsColor)")
    colorList.setColor(color.nsColor, forKey: color.name)
}

do {
    print("[Working]: Writing colors to .clr file")
    try colorList.write(to: nil)
    print("[Success]: Color palette created at \"~/Library/Colors/\(outputName).clr\"")
    exit(0)
} catch let error {
    print("[Error]: \(error)")
    exit(1)
}
