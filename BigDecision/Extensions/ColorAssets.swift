import SwiftUI

extension Color {
    struct CustomColors {
        static let primary = Color("AppPrimary")
        static let secondary = Color("AppSecondary")
    }
    
    static var custom: CustomColors.Type {
        return CustomColors.self
    }
}

#if canImport(UIKit)
import UIKit

extension UIColor {
    struct CustomColors {
        static let primary = UIColor(named: "AppPrimary")!
        static let secondary = UIColor(named: "AppSecondary")!
    }
    
    static var custom: CustomColors.Type {
        return CustomColors.self
    }
}
#endif

#if canImport(AppKit)
import AppKit

extension NSColor {
    struct CustomColors {
        static let primary = NSColor(named: "AppPrimary")!
        static let secondary = NSColor(named: "AppSecondary")!
    }
    
    static var custom: CustomColors.Type {
        return CustomColors.self
    }
}
#endif
