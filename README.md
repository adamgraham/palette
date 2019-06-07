# palette
> An iOS command line tool to parse files and generate color palettes.

### Usage
`./palette` `{input_file}` `{output_name}` `{output_dir}?` `{output_type}`

#### Required Arguments:
- `{input_file}`
  - A path to a file to parse colors from
  - Supported file types: `.plist` `.swift` `.txt`
  - The file extension must be included in the path
- `{output_name}`
  - The desired name of the color palette
- `{output_type}`
  - The format of the outputted color palette
  - Options: `--clr` `--colorset` `--plist` `--swift` `--swift-literal` `--txt`
  - *See below for more information*

#### Optional Arguments:
- `{output_dir}`
  - A path to a directory at which the color palette is outputted
  - If not provided, the color palette is outputted at the current working directory
  
## Formats

🗺️ **Color Map** `.clr` `--clr` (Binary)
```
white 255 255 255
red 255 0 0
green 0 255 0
blue 0 0 255
cyan 0 255 255
magenta 255 0 255
yellow 255 255 0
black 0 0 0
```

🍭 **Color Set** `.colorset` `--colorset`
``` json
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
                    "red" : "1.0",
                    "green" : "1.0",
                    "blue" : "1.0",
                    "alpha" : "1.0"
                }
            }
        }
    ]
}
```

📑 **Property List** `.plist` `--plist`
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Name</key>
    <string>Sample</string>
    <key>Colors</key>
    <dict>
        <key>white</key>
        <string>#ffffff</string>
        <key>red</key>
        <string>#ff0000</string>
        <key>green</key>
        <string>#00ff00</string>
        <key>blue</key>
        <string>#0000ff</string>
        <key>cyan</key>
        <string>#00ffff</string>
        <key>magenta</key>
        <string>#ff00ff</string>
        <key>yellow</key>
        <string>#ffff00</string>
        <key>black</key>
        <string>#000000</string>
    </dict>
</dict>
</plist>
```

🏎️ **Swift File** `.swift` `--swift`
``` swift
extension UIColor {

    struct Sample {

        /// `#ffffff`
        static let white = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        /// `#ff0000`
        static let red = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        /// `#00ff00`
        static let green = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        /// `#0000ff`
        static let blue = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        /// `#00ffff`
        static let cyan = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        /// `#ff00ff`
        static let magenta = UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        /// `#ffff00`
        static let yellow = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        /// `#000000`
        static let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
        private init() {}

    }

}
```

🏎️ **Swift File (Color Literal)** `.swift` `--swift-literal`
``` swift
extension UIColor {

    struct Sample {

        /// `#ffffff`
        static let white = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        /// `#ff0000`
        static let red = #colorLiteral(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        /// `#00ff00`
        static let green = #colorLiteral(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        /// `#0000ff`
        static let blue = #colorLiteral(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        /// `#00ffff`
        static let cyan = #colorLiteral(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        /// `#ff00ff`
        static let magenta = #colorLiteral(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        /// `#ffff00`
        static let yellow = #colorLiteral(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        /// `#000000`
        static let black = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
        private init() {}

    }

}
```

📄 **Text File** `.txt` `--text`
```
white #ffffff
red #ff0000
green #00ff00
blue #0000ff
cyan #00ffff
magenta #ff00ff
yellow #ffff00
black #000000
```
