//
//  color.swift
//  color-tools
//
//  Created by Adam Graham on 1/9/19.
//  Copyright © 2019 Adam Graham. All rights reserved.
//

import AppKit

struct Color {

    // MARK: Properties

    let nsColor: NSColor
    let name: String

    var hex: String {
        return self.nsColor.hexString
    }

    var literal: String {
        return "#colorLiteral(red: \(self.nsColor.redComponent), green: \(self.nsColor.greenComponent), blue: \(self.nsColor.blueComponent), alpha: \(self.nsColor.alphaComponent))"
    }

    // MARK: Initializers

    init(nsColor: NSColor, name: String? = nil) {
        self.nsColor = nsColor
        self.name = name ?? nsColor.hexString
    }

    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat? = nil, name: String? = nil) {
        let nsColor = NSColor(red: red, green: green, blue: blue, alpha: alpha ?? 1.0)
        self.nsColor = nsColor
        self.name = name ?? nsColor.hexString
    }

    init?(hex: String, name: String? = nil) {
        guard let nsColor = NSColor(hex: hex) else {
            return nil
        }

        self.nsColor = nsColor
        self.name = name ?? hex
    }

}

// MARK: - Helpers

private extension NSColor {

    convenience init?(hex: String) {
        guard let value = Int(hex: hex) else {
            return nil
        }

        let red = CGFloat((value >> 16) & 0xff) / 0xff
        let green = CGFloat((value >> 8) & 0xff) / 0xff
        let blue = CGFloat((value >> 0) & 0xff) / 0xff

        self.init(srgbRed: red, green: green, blue: blue, alpha: 1.0)
    }

    var hex: Int {
        return (Int(round(self.redComponent * 0xff)) << 16) |
               (Int(round(self.greenComponent * 0xff)) << 8) |
               (Int(round(self.blueComponent * 0xff)) << 0)
    }

    var hexString: String {
        return "#\(String(format: "%06x", self.hex))"
    }

}

private extension Int {

    init?(hex: String) {
        self.init(hex.trimmedHex, radix: 16)
    }

}

private extension String {

    var trimmedHex: String {
        return self.replacingOccurrences(of: "0x", with: "").replacingOccurrences(of: "#", with: "")
    }

}
