import SwiftUI

enum ThemeManager {
    static func primaryColor() -> Color {
        Color("BD_Primary")
    }
    
    static func secondaryColor() -> Color {
        Color("BD_Secondary")
    }
    
    #if os(iOS)
    static func primaryUIColor() -> UIColor {
        UIColor(named: "BD_Primary") ?? .systemBlue
    }
    
    static func secondaryUIColor() -> UIColor {
        UIColor(named: "BD_Secondary") ?? .systemIndigo
    }
    #endif
    
    #if os(macOS)
    static func primaryNSColor() -> NSColor {
        NSColor(named: "BD_Primary") ?? .systemBlue
    }
    
    static func secondaryNSColor() -> NSColor {
        NSColor(named: "BD_Secondary") ?? .systemIndigo
    }
    #endif
}
