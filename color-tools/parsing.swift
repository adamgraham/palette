//
//  parsing.swift
//  color-tools
//
//  Created by Adam Graham on 1/9/19.
//  Copyright © 2019 Adam Graham. All rights reserved.
//

import Foundation

enum ParsingError: Error, CustomStringConvertible {

    case invalidExtension
    case readingContents(url: URL, error: Error)

    var description: String {
        switch self {
        case .invalidExtension:
            return "File path must include .txt, .plist, or .swift extension"
        case .readingContents(let url, let error):
            return "Could not read contents of \"\(url)\" - \(error)"
        }
    }

}

func parseColors(at url: URL) throws -> [Color] {
    switch url.pathExtension {
    case "txt":
        return try parse(txt: url)
    case "plist":
        return try parse(plist: url)
    case "swift":
        return try parse(swift: url)
    default:
        throw ParsingError.invalidExtension
    }
}

private func parse(txt url: URL) throws -> [Color] {
    let contents = try fileContents(atPath: url)
    let lines = contents.components(separatedBy: .newlines)

    var colors: [Color] = []

    for line in lines where line.count > 0 {
        var components = line.components(separatedBy: " ")
        if components.count > 0, let color = Color(hex: components.removeFirst(), name: components.joined(separator: " ")) {
            colors.append(color)
        }
    }

    return colors
}

private func parse(plist url: URL) throws -> [Color] {
    let contents = try fileContents(atPath: url)
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

private func parse(swift url: URL) throws -> [Color] {
    let contents = try fileContents(atPath: url)
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

private func fileContents(atPath url: URL) throws -> String {
    do {
        return try String(contentsOf: url, encoding: .utf8)
    } catch let error {
        throw ParsingError.readingContents(url: url, error: error)
    }
}
