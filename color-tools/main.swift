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
    let usage = """

        [Usage]: \(executableName) {input_file} {output_name} {output_dir}? {output_type}

            {input_file}
              - A path to a file to parse colors from
              - Supported file types: .plist, .swift, .txt
              - The file extension must be included in the path

            {output_name}
              - The desired name of the color palette

            {output_dir}?
              - A path to a directory at which the color palette is outputted
              - If not provided, the color palette is outputted at the current working directory

            {output_type}
              - The format of the outputted color palette
              - Options: --clr, --colorset, --plist, --swift, --txt

        """
    print(usage)
}

if args.contains("-h") || args.contains("--help") {
    printUsage()
    exit(0)
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

    case clr = "clr"
    case colorset = "colorset"
    case plist = "plist"
    case swift = "swift"
    case txt = "txt"

    init?(type: String) {
        self.init(rawValue: type.lowercased()
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "--", with: ""))
    }

    var fileExtension: String {
        return ".\(self.rawValue)"
    }

}

let outputType = OutputType(rawValue: args.last!) ?? OutputType(type: args.last!) ?? .clr
let outputName = args[2]
let outputDirectory = args.count == 5 ? args[3] : FileManager.default.currentDirectoryPath
print("TEST: \(FileManager.default.currentDirectoryPath)")
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
