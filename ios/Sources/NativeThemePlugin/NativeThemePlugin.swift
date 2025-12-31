import Foundation
import Capacitor
import UIKit

@objc(NativeThemePlugin)
public class NativeThemePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "NativeThemePlugin"
    public let jsName = "NativeTheme"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "enableEdgeToEdge", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setAppTheme", returnType: CAPPluginReturnPromise)
    ]
    
    private var statusBarView: UIView?
    
    @objc func enableEdgeToEdge(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let webView = self.bridge?.webView else {
                call.reject("WebView not found")
                return
            }
            
            // Enable Edge-to-Edge by disabling automatic content inset adjustment
            webView.scrollView.contentInsetAdjustmentBehavior = .never
            
            // Make WebView transparent to show window background if needed
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
            
            call.resolve()
        }
    }
    
    @objc func setAppTheme(_ call: CAPPluginCall) {
        let windowBg = call.getString("windowBackgroundColor")
        let statusBarColor = call.getString("statusBarColor")
        // navigationBarColor is ignored on iOS as it doesn't have a dedicated nav bar area like Android
        
        let isStatusBarLight = call.getBool("isStatusBarLight")
        // isNavigationBarLight is ignored on iOS
        
        DispatchQueue.main.async {
            // 1. Handle Window Background
            if let bg = windowBg, let color = UIColor.capacitorColor(hex: bg) {
                self.bridge?.viewController?.view.backgroundColor = color
                self.bridge?.webView?.backgroundColor = .clear
                self.bridge?.webView?.scrollView.backgroundColor = .clear
            }
            
            // 2. Handle Status Bar Style (Icons)
            if let isLight = isStatusBarLight {
                // true = Dark Icons (Light Background) -> .darkContent
                // false = Light Icons (Dark Background) -> .lightContent
                let style: UIStatusBarStyle = isLight ? .darkContent : .lightContent
                self.bridge?.statusBarStyle = style
            }
            
            // 3. Handle Status Bar Background Color
            if let sbColor = statusBarColor, let color = UIColor.capacitorColor(hex: sbColor) {
                self.setStatusBarColor(color)
            } else if statusBarColor == "#00000000" {
                self.removeStatusBarView()
            }
            
            call.resolve()
        }
    }
    
    private func setStatusBarColor(_ color: UIColor) {
        removeStatusBarView()
        
        if color == .clear { return }
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        
        let statusBarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: topPadding)
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = color
        statusBarView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        
        // Add to the webview's superview (the view controller's view) to sit on top
        if let parentView = self.bridge?.webView?.superview {
            parentView.addSubview(statusBarView)
            parentView.bringSubviewToFront(statusBarView)
            self.statusBarView = statusBarView
        }
    }
    
    private func removeStatusBarView() {
        self.statusBarView?.removeFromSuperview()
        self.statusBarView = nil
    }
}

extension UIColor {
    static func capacitorColor(hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
