//
//  composing.swift
//  color-tools
//
//  Created by Adam Graham on 1/23/19.
//  Copyright © 2019 Adam Graham. All rights reserved.
//

import AppKit

func composePalette(from colors: [Color], type: OutputType, name: String) throws -> WritableFileContents {
    switch type {
    case .clr:
        return try compose(clr: colors, name: name)
    case .colorset:
        return try compose(colorset: colors, name: name)
    case .plist:
        return try compose(plist: colors, name: name)
    case .swift:
        return try compose(swift: colors, name: name)
    case .swiftLiteral:
        return try compose(swiftLiteral: colors, name: name)
    case .txt:
        return try compose(txt: colors, name: name)
    }
}

private func compose(clr colors: [Color], name: String) throws -> WritableFileContents {
    let colorList = NSColorList(name: name)
    for color in colors {
        colorList.setColor(color.nsColor, forKey: color.name)
    }
    return colorList
}

private func compose(colorset colors: [Color], name: String) throws -> WritableFileContents {
    let rootContents = """
        {
            "info" : {
                "version" : 1,
                "author" : "xcode"
            }
        }
        """
    let root = (name: name, contents: rootContents)
    return ColorsetContents(root: root, colors: colors.map({
        var contents = """
            {
                "info" : {
                    "version" : 1,
                    "author" : "xcode"
                },
                "colors" : [
                    {
                        "idiom" : "universal",
                        "color" : {
                            "color-space" : "srgb",
                            "components" : {
                                "red" : "${RED}",
                                "green" : "${GREEN}",
                                "blue" : "${BLUE}",
                                "alpha" : "${ALPHA}"
                            }
                        }
                    }
                ]
            }
            """
        contents = contents.replacingOccurrences(of: "${RED}", with: "\($0.nsColor.redComponent)")
        contents = contents.replacingOccurrences(of: "${GREEN}", with: "\($0.nsColor.greenComponent)")
        contents = contents.replacingOccurrences(of: "${BLUE}", with: "\($0.nsColor.blueComponent)")
        contents = contents.replacingOccurrences(of: "${ALPHA}", with: "\($0.nsColor.alphaComponent)")
        return (name: $0.name, contents: contents)
    }))
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
        $0 + "<key>\($1.name)</key>\n        <string>\($1.hex)</string>\n        "
    }

    return contents.replacingOccurrences(of: "{NAME}", with: name)
                   .replacingOccurrences(of: "{COLORS}", with: colorContents)
}

private func compose(swift colors: [Color], name: String) throws -> WritableFileContents {
    let contents = """
        extension UIColor {

            struct {NAME} {

                {COLORS}
                private init() {}

            }

        }

        """

    let colorContents = colors.reduce("") {
        let color = $1.nsColor
        let rgba = (r: color.redComponent, g: color.greenComponent, b: color.blueComponent, a: color.alphaComponent)
        return $0 + "/// `\($1.hex)`\n        static let \($1.name.lowerCamelCased()) = UIColor(red: \(rgba.r), green: \(rgba.g), blue: \(rgba.b), alpha: \(rgba.a))\n        "
    }

    return contents.replacingOccurrences(of: "{NAME}", with: name.upperCamelCased())
                   .replacingOccurrences(of: "{COLORS}", with: colorContents)
}

private func compose(swiftLiteral colors: [Color], name: String) throws -> WritableFileContents {
    let contents = """
        extension UIColor {

            struct {NAME} {

                {COLORS}
                private init() {}

            }

        }

        """

    let colorContents = colors.reduce("") {
        $0 + "/// `\($1.hex)`\n        static let \($1.name.lowerCamelCased()) = \($1.literal)\n        "
    }

    return contents.replacingOccurrences(of: "{NAME}", with: name.upperCamelCased())
        .replacingOccurrences(of: "{COLORS}", with: colorContents)
}

private func compose(txt colors: [Color], name: String) throws -> WritableFileContents {
    return colors.reduce("") { $0 + "\($1.name) \($1.hex)\n" }
}

// MARK: -

protocol WritableFileContents {

    func write(to url: URL?) throws

}

extension String: WritableFileContents {

    func write(to url: URL?) throws {
        let fileURL = url ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        try self.write(to: fileURL, atomically: true, encoding: .utf8)
        print(fileURL)
    }

}

extension NSColorList: WritableFileContents {}

struct ColorsetContents: WritableFileContents {

    let root: (name: String, contents: String)
    let colors: [(name: String, contents: String)]

    func write(to url: URL?) throws {
        // create a directory to organize all of the colors
        var directoryURL = url?.deletingPathExtension().deletingLastPathComponent() ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        directoryURL.appendPathComponent(self.root.name)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes:nil)
        let directoryPath = directoryURL.path
        print(directoryURL)

        // write contents for the parent directory
        var contentsURL = URL(fileURLWithPath: "\(directoryPath)/Contents.json")
        try self.root.contents.write(to: contentsURL, atomically: true, encoding: .utf8)
        print(contentsURL)

        // write each color into the parent directory
        for color in self.colors {
            // create a .colorset directory
            let colorURL = URL(fileURLWithPath: "\(directoryPath)/\(color.name).colorset", isDirectory: true)
            try FileManager.default.createDirectory(at: colorURL, withIntermediateDirectories: true, attributes: nil)
            print(colorURL)

            // write contents with color data
            contentsURL = URL(fileURLWithPath: "\(colorURL.path)/Contents.json")
            try color.contents.write(to: contentsURL, atomically: true, encoding: .utf8)
            print(contentsURL)
        }
    }

}

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
