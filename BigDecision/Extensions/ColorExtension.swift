import SwiftUI

extension Color {
    static let primary = Color("CustomPrimary")
    static let secondary = Color("CustomSecondary")
}

#if canImport(UIKit)
import UIKit

extension UIColor {
    static let primary = UIColor(named: "CustomPrimary")!
    static let secondary = UIColor(named: "CustomSecondary")!
}
#endif

#if canImport(AppKit)
import AppKit

extension NSColor {
    static let primary = NSColor(named: "CustomPrimary")!
    static let secondary = NSColor(named: "CustomSecondary")!
}
#endif
