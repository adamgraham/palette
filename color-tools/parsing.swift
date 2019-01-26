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
    let regex = try NSRegularExpression(pattern: "(.*)((?:#|0x)[0-9a-fA-F]*)")
    let matches = regex.matches(in: contents, options: [], range: NSRange(location: 0, length: contents.count))
    var colors: [Color] = []

    for match in matches {
        guard let hexCapture = Range(match.range(at: 2), in: contents) else { continue }
        let nameCapture = Range(match.range(at: 1), in: contents) ?? hexCapture

        let hex = String(contents[hexCapture])
        var name = String(contents[nameCapture]).trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty { name = hex }

        guard let color = Color(hex: hex, name: name) else { continue }
        colors.append(color)
    }

    return colors
}

private func parse(plist url: URL) throws -> [Color] {
    let contents = try fileContents(atPath: url)
    let regex = try NSRegularExpression(pattern: "(?:<key>)?(\\w*)(?:<\\/key>)?\\s*<string>((?:#|0x)[0-9a-fA-F]*)<\\/string>")
    let matches = regex.matches(in: contents, options: [], range: NSRange(location: 0, length: contents.count))
    var colors: [Color] = []

    for match in matches {
        guard let hexCapture = Range(match.range(at: 2), in: contents) else { continue }
        let nameCapture = Range(match.range(at: 1), in: contents) ?? hexCapture

        let hex = String(contents[hexCapture])
        var name = String(contents[nameCapture]).trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty { name = hex }

        guard let color = Color(hex: hex, name: name) else { continue }
        colors.append(color)
    }

    return colors
}

private func parse(swift url: URL) throws -> [Color] {
    let contents = try fileContents(atPath: url)
    var colors: [Color] = []

    // match by hex values
    var regex = try NSRegularExpression(pattern: "(?:var|let)\\s*(\\w+)\\s*(?::\\s*UIColor)?\\s*(?:=|\\{)\\s*UIColor\\((?:\\w+:)\\s*\"?((?:#|0x)[0-9a-fA-F]*)\"?")
    var matches = regex.matches(in: contents, options: [], range: NSRange(location: 0, length: contents.count))

    for match in matches {
        guard let hexCapture = Range(match.range(at: 2), in: contents) else { continue }
        let nameCapture = Range(match.range(at: 1), in: contents) ?? hexCapture

        let hex = String(contents[hexCapture])
        var name = String(contents[nameCapture]).trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty { name = hex }

        guard let color = Color(hex: hex, name: name) else { continue }
        colors.append(color)
    }

    // match by rgb values
    regex = try NSRegularExpression(pattern: "(?:var|let)\\s*(\\w+)\\s*(?::\\s*UIColor)?\\s*(?:=|\\{)\\s*(?:#colorLiteral|UIColor|NSColor)\\(\\w*[Rr]ed:\\s*(\\d*.\\d*),\\s*green:\\s*(\\d*.\\d*),\\s*blue:\\s*(\\d*.\\d*),\\s*alpha:\\s*(\\d*.\\d*)\\)")
    matches = regex.matches(in: contents, options: [], range: NSRange(location: 0, length: contents.count))
    let numberFormatter = NumberFormatter()

    for match in matches {
        guard let nameCapture = Range(match.range(at: 1), in: contents),
              let redCapture = Range(match.range(at: 2), in: contents),
              let greenCapture = Range(match.range(at: 3), in: contents),
              let blueCapture = Range(match.range(at: 4), in: contents) else { continue }

        guard let red = numberFormatter.number(from: String(contents[redCapture]))?.doubleValue,
              let green = numberFormatter.number(from: String(contents[greenCapture]))?.doubleValue,
              let blue = numberFormatter.number(from: String(contents[blueCapture]))?.doubleValue else { continue }

        var alpha = 1.0
        if let alphaCapture = Range(match.range(at: 5), in: contents) {
            alpha = numberFormatter.number(from: String(contents[alphaCapture]))?.doubleValue ?? 1.0
        }

        let color = Color(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha), name: String(contents[nameCapture]))
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
