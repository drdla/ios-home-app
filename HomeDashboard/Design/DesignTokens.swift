import SwiftUI

// MARK: - Color Tokens
// Extracted directly from Sketch file "Home App iOS.sketch" (artboard: Home App iPad 6, 1536×2048px @2x)

extension Color {
    // Panel background – used for all section tiles
    static let surface      = Color(hex: 0x2E3C41)
    // Secondary text (time digits, "Heute", "Morgen", icon labels)
    static let textSecondary = Color(hex: 0x717677)
    // Tertiary text (grid lines, transit destination text, station names)
    static let textTertiary  = Color(hex: 0x9BA1A3)
    // Primary text (temperature, precipitation %)
    static let textPrimary   = Color.white
    // Precipitation / alert highlight
    static let highlight     = Color(hex: 0xF7E81C)
    // Transit direction strip
    static let directionStrip = Color(hex: 0x37494F)

    // Calendar event fill colors (34% alpha)
    static let calendarPurple = Color(hex: 0x8F12FD).opacity(0.34)
    static let calendarGreen  = Color(hex: 0x7ED221).opacity(0.34)
    static let calendarTeal   = Color(hex: 0x4BC5E3).opacity(0.34)

    // Door action buttons
    static let buttonSpeak = Color(hex: 0x6ED102).opacity(0.84)
    static let buttonOpen  = Color(red: 1, green: 0, blue: 0).opacity(0.49)

    // S-Bahn line badge
    static let sBahnS2  = Color(hex: 0x3A7D44)
    static let sBahnRB  = Color(hex: 0x4A6FA5)

    init(hex: UInt32) {
        self.init(
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255
        )
    }
}

// MARK: - Typography Tokens
// Replacement for PorscheNextTT: Panamera by NoirBlancRouge (OFL 1.1).
// Named after the Porsche Panamera – same premium automotive aesthetic, same weight range.
// Download Panamera-Thin.otf + Panamera-Regular.otf from:
//   https://github.com/noirblancrouge/Panamera  (fonts/otf/ folder)
// Add both .otf files to the Xcode target, then add to Info.plist:
//   <key>UIAppFonts</key>
//   <array>
//     <string>Panamera-Thin.otf</string>
//     <string>Panamera-Regular.otf</string>
//   </array>
// Without the files the app falls back to the system thin/regular weight.

enum DashboardFont {
    static func thin(_ size: CGFloat) -> Font {
        if UIFont.familyNames.contains("Panamera") {
            return .custom("Panamera-Thin", size: size)
        }
        return .system(size: size, weight: .thin, design: .default)
    }

    static func regular(_ size: CGFloat) -> Font {
        if UIFont.familyNames.contains("Panamera") {
            return .custom("Panamera-Regular", size: size)
        }
        return .system(size: size, weight: .regular, design: .default)
    }
}

// MARK: - Layout Tokens
// All values in SwiftUI points (Sketch px ÷ 2).

enum Layout {
    // Artboard is exactly the 6th-gen iPad @2x: 1536×2048px → 768×1024pt portrait
    static let screenWidth:  CGFloat = 768
    static let screenHeight: CGFloat = 1024

    // Section heights
    static let weatherSectionHeight:     CGFloat = 179
    static let tasksSectionHeight:       CGFloat = 491
    static let automationSectionHeight:  CGFloat = 360

    // Separator height
    static let separatorHeight: CGFloat = 1.5

    // Within Weather section
    static let todayPanelWidth:     CGFloat = 384   // 768÷2
    static let tomorrowPanelWidth:  CGFloat = 192   // 384÷2
    static let dateTimePanelWidth:  CGFloat = 192   // 384÷2

    // Within Tasks section
    static let calendarPanelWidth:  CGFloat = 256.5
    static let tasksPanelWidth:     CGFloat = 256
    static let transitPanelWidth:   CGFloat = 256

    // Calendar grid
    static let calendarHourRowHeight: CGFloat = 980 / 23 / 2  // 23 rows in 980px @2x
    static let calendarLabelWidth:    CGFloat = 26

    // Within Automation section
    static let shortcutTileWidth:   CGFloat = 405.5
    static let doorPanelWidth:      CGFloat = 360.5

    // Typography (Sketch sizes ÷ 2)
    static let fontSizeXLarge:  CGFloat = 56   // time digits (112 ÷ 2)
    static let fontSizeLarge:   CGFloat = 35   // date/day (70 ÷ 2)
    static let fontSizeSmall:   CGFloat = 14   // labels (28 ÷ 2)

    // Insets
    static let panelPadding: CGFloat = 16
}
