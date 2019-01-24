//
//  color.swift
//  color-tools
//
//  Created by Adam Graham on 1/9/19.
//  Copyright © 2019 Adam Graham. All rights reserved.
//

import AppKit

struct Color {

    let nsColor: NSColor
    let hex: String
    let name: String

    var literal: String {
        return "#colorLiteral(red: \(self.nsColor.redComponent), green: \(self.nsColor.greenComponent), blue: \(self.nsColor.blueComponent), alpha: 1.0)"
    }

    init(nsColor: NSColor, name: String) {
        self.nsColor = nsColor
        self.hex = nsColor.hexString
        self.name = name
    }

    init?(hex: String, name: String? = nil) {
        guard let nsColor = NSColor(hex: hex) else {
            return nil
        }

        self.nsColor = nsColor
        self.hex = hex
        self.name = name ?? hex
    }

}

private extension NSColor {

    convenience init?(hex: String) {
        guard let value = Int(hex: hex) else {
            return nil
        }

        let red = CGFloat((value >> 16) & 0xff) / 255
        let green = CGFloat((value >> 8) & 0xff) / 255
        let blue = CGFloat((value >> 0) & 0xff) / 255

        self.init(srgbRed: red, green: green, blue: blue, alpha: 1.0)
    }

    var hex: Int {
        return (Int(self.redComponent * 255) << 16) |
               (Int(self.greenComponent * 255) << 8) |
               (Int(self.blueComponent * 255) << 0)
    }

    var hexString: String {
        return "#\(String(self.hex, radix: 16))"
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
