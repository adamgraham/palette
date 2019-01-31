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

func printUsage() {
    let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
    print("[Usage]: \(executableName) {input_file} {output_name} {output_dir}? --clr")
    print("[Usage]: \(executableName) {input_file} {output_name} {output_dir}? --colorset")
    print("[Usage]: \(executableName) {input_file} {output_name} {output_dir}? --plist")
    print("[Usage]: \(executableName) {input_file} {output_name} {output_dir}? --swift")
    print("[Usage]: \(executableName) {input_file} {output_name} {output_dir}? --txt")
}

guard args.count >= 4 else {
    print("[Error]: Missing required arguments")
    printUsage()
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

enum OutputType: String {

    case clr = "--clr"
    case colorset = "--colorset"
    case plist = "--plist"
    case swift = "--swift"
    case txt = "--txt"

    var fileExtension: String {
        return self.rawValue.replacingOccurrences(of: "--", with: ".")
    }

}

let outputType = OutputType(rawValue: args.last!) ?? .clr
let outputName = args[2]
let outputDirectory = args.count == 5 ? args[3] : FileManager.default.currentDirectoryPath
let outputURL = URL(fileURLWithPath: "\(outputDirectory)/\(outputName)\(outputType.fileExtension)")

do {
    print("[Working]: Generating color palette")
    let colorPalette = try composePalette(from: colors, type: outputType, name: outputName)
    print("[Working]: Writing colors to file")
    try colorPalette.write(to: outputURL)
    print("[Success]: Color palette '\(outputName)\' created at \(outputDirectory)/")
    exit(0)
} catch let error {
    print("[Error]: \(error)")
    exit(1)
}
