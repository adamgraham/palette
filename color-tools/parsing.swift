//
//  parsing.swift
//  color-tools
//
//  Created by Adam Graham on 1/9/19.
//  Copyright © 2019 Adam Graham. All rights reserved.
//

import Foundation

enum ParsingError: Error, CustomStringConvertible {

    case fileNotFound(path: String)
    case readingContents(path: String, error: Error)

    var description: String {
        switch self {
        case .fileNotFound(let path):
            return "No file exists at path \"\(path)\""
        case .readingContents(let path, let error):
            return "Could not read contents of \"\(path)\" - \(error)"
        }
    }

}

private func fileContents(atPath path: String) throws -> String {
    guard FileManager.default.fileExists(atPath: path) else {
        throw ParsingError.fileNotFound(path: path)
    }

    let url = URL(fileURLWithPath: path)
    do {
        return try String(contentsOf: url, encoding: .utf8)
    } catch let error {
        throw ParsingError.readingContents(path: path, error: error)
    }
}

func parseColors(txt path: String) throws -> [Color] {
    let contents = try fileContents(atPath: path)
    let lines = contents.components(separatedBy: .newlines)

    var colors: [Color] = []

    for line in lines where line.count > 0 {
        var components = line.components(separatedBy: " ")
        if components.count > 0, let color = Color(hex: components.removeFirst(), name: components.joined(separator: " ")) {
            colors.append(color)
        } else {
            print("[Warning]: Could not parse \"\(line)\", skipped")
        }
    }

    return colors
}

func parseColors(plist path: String) throws -> [Color] {
    let contents = try fileContents(atPath: path)
    let regex = try NSRegularExpression(pattern: "<key>(\\w*)<\\/key>\\s*<string>((?:#|0x)[0-9a-fA-F]*)<\\/string>")
    let matches = regex.matches(in: contents, options: [], range: NSRange(location: 0, length: contents.count))
    var colors: [Color] = []

    for match in matches {
        guard let hexCapture = Range(match.range(at: 2), in: contents) else { continue }
        let nameCapture = Range(match.range(at: 1), in: contents) ?? hexCapture
        guard let color = Color(hex: String(contents[hexCapture]), name: String(contents[nameCapture])) else { continue }
        colors.append(color)
    }

    return colors
}

func parseColors(swift path: String) throws -> [Color] {
    let contents = try fileContents(atPath: path)
    let regex = try NSRegularExpression(pattern: "(?:var|let)\\s*(\\w+)\\s*(?::\\s*UIColor)?\\s*(?:=|\\{)\\s*UIColor\\((?:\\w+:)\\s*\"?((?:#|0x)[0-9a-fA-F]*)\"?")
    let matches = regex.matches(in: contents, options: [], range: NSRange(location: 0, length: contents.count))
    var colors: [Color] = []

    for match in matches {
        guard let hexCapture = Range(match.range(at: 2), in: contents) else { continue }
        let nameCapture = Range(match.range(at: 1), in: contents) ?? hexCapture
        guard let color = Color(hex: String(contents[hexCapture]), name: String(contents[nameCapture])) else { continue }
        colors.append(color)
    }

    return colors
}
