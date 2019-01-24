//
//  composing.swift
//  color-tools
//
//  Created by Adam Graham on 1/23/19.
//  Copyright © 2019 Adam Graham. All rights reserved.
//

import AppKit

func composePalette(from colors: [Color], at url: URL?) throws -> WritableFileContents {
    let name = url?.deletingPathExtension().lastPathComponent ?? "Unnamed"
    switch url?.pathExtension {
    case .some("txt"):
        return try compose(txt: colors, name: name)
    case .some("plist"):
        return try compose(plist: colors, name: name)
    case .some("swift"):
        return try compose(swift: colors, name: name)
    default:
        return try compose(clr: colors, name: name)
    }
}

private func compose(clr colors: [Color], name: String) throws -> WritableFileContents {
    let colorList = NSColorList(name: name)
    for color in colors {
        colorList.setColor(color.nsColor, forKey: color.name)
    }
    return colorList
}

private func compose(txt colors: [Color], name: String) throws -> WritableFileContents {
    return colors.reduce("") { $0 + "\($1.name) \($1.hex)\n" }
}

private func compose(plist colors: [Color], name: String) throws -> WritableFileContents {
    let contents = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Name</key>
            <string>{NAME}</string>
            <key>Colors</key>
            <dict>
                {COLORS}
            </dict>
        </dict>
        </plist>

        """

    let colorContents = colors.reduce("") {
        $0 + "<key>\($1.name)</key>\n\t\t<string>\($1.hex)</string>\n\t\t"
    }

    return contents.replacingOccurrences(of: "{NAME}", with: name)
                   .replacingOccurrences(of: "{COLORS}", with: colorContents)
}

private func compose(swift colors: [Color], name: String) throws -> WritableFileContents {
    let contents = """
        extension UIColor {

            public struct {NAME} {

                {COLORS}
                private init() {}

            }

        }

        """

    let colorContents = colors.reduce("") {
        $0 + "/// `\($1.hex)`\n\t\tpublic static let \($1.name.lowerCamelCased()) = \($1.literal)\n\t\t"
    }

    return contents.replacingOccurrences(of: "{NAME}", with: name.upperCamelCased())
                   .replacingOccurrences(of: "{COLORS}", with: colorContents)
}

// MARK: -

protocol WritableFileContents {

    func write(to url: URL?) throws

}

extension String: WritableFileContents {

    func write(to url: URL?) throws {
        try self.write(to: url ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath),
                       atomically: true,
                       encoding: .utf8)
    }

}

extension NSColorList: WritableFileContents {}

// MARK: -

private extension String {

    var words: [String] {
        return components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
    }

    func lowercasedFirst() -> String {
        return prefix(1).lowercased() + dropFirst()
    }

    func lowerCamelCased() -> String {
        guard !self.isEmpty else {
            return ""
        }

        let words = self.words
        let first = words.first!.lowercasedFirst()
        let rest = words.dropFirst().map { $0.capitalized }
        return ([first] + rest).joined()
    }

    func upperCamelCased() -> String {
        return self.words.map({ $0.capitalized }).joined()
    }

}
