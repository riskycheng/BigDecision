import SwiftUI

struct AppColors {
    // MARK: - Primary Colors
    
    // Primary color - purple blue
    static let primaryLight = Color(red: 0.310, green: 0.275, blue: 0.898)
    static let primaryDark = Color(red: 0.435, green: 0.400, blue: 0.980)
    
    // Secondary color - blue
    static let secondaryLight = Color(red: 0.200, green: 0.400, blue: 0.980)
    static let secondaryDark = Color(red: 0.300, green: 0.500, blue: 1.000)
    
    // MARK: - Computed Properties
    
    static var primary: Color {
        #if os(iOS)
        return UITraitCollection.current.userInterfaceStyle == .dark ? primaryDark : primaryLight
        #else
        let isDarkMode = NSAppearance.current.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        return isDarkMode ? primaryDark : primaryLight
        #endif
    }
    
    static var secondary: Color {
        #if os(iOS)
        return UITraitCollection.current.userInterfaceStyle == .dark ? secondaryDark : secondaryLight
        #else
        let isDarkMode = NSAppearance.current.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        return isDarkMode ? secondaryDark : secondaryLight
        #endif
    }
    
    // MARK: - UIKit/AppKit Colors
    
    #if os(iOS)
    static var primaryUIColor: UIColor {
        UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.435, green: 0.400, blue: 0.980, alpha: 1.0) :
                UIColor(red: 0.310, green: 0.275, blue: 0.898, alpha: 1.0)
        }
    }
    
    static var secondaryUIColor: UIColor {
        UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(red: 0.300, green: 0.500, blue: 1.000, alpha: 1.0) :
                UIColor(red: 0.200, green: 0.400, blue: 0.980, alpha: 1.0)
        }
    }
    #endif
    
    #if os(macOS)
    static var primaryNSColor: NSColor {
        NSColor(name: nil) { appearance in
            let isDarkMode = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return isDarkMode ? 
                NSColor(red: 0.435, green: 0.400, blue: 0.980, alpha: 1.0) :
                NSColor(red: 0.310, green: 0.275, blue: 0.898, alpha: 1.0)
        }
    }
    
    static var secondaryNSColor: NSColor {
        NSColor(name: nil) { appearance in
            let isDarkMode = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return isDarkMode ? 
                NSColor(red: 0.300, green: 0.500, blue: 1.000, alpha: 1.0) :
                NSColor(red: 0.200, green: 0.400, blue: 0.980, alpha: 1.0)
        }
    }
    #endif
}
