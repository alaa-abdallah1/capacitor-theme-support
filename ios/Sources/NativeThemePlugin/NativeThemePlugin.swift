import Foundation
import Capacitor
import UIKit

/**
 * SystemUI - Capacitor plugin for native system UI control on iOS
 *
 * This plugin provides comprehensive control over:
 * - Edge-to-edge display mode
 * - Status bar appearance and visibility
 * - Safe area insets
 *
 * Note: iOS does not have a dedicated navigation bar like Android.
 * The home indicator area is handled automatically by iOS.
 *
 * @author Payiano
 * @version 1.0.0
 */
@objc(NativeThemePlugin)
public class NativeThemePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "NativeThemePlugin"
    public let jsName = "SystemUI"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "configure", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setBackgroundColors", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setBarStyles", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setStatusBarVisibility", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setNavigationBarVisibility", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setEdgeToEdge", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getInfo", returnType: CAPPluginReturnPromise)
    ]
    
    // ============================================
    // Configuration State
    // ============================================
    
    private var isEdgeToEdgeEnabled: Bool = false
    private var isSafeAreaEnabled: Bool = true
    private var isStatusBarVisible: Bool = true
    private var isNavigationBarVisible: Bool = true // Always true on iOS (no equivalent)
    
    // ============================================
    // Color Configuration
    // ============================================
    
    private var contentBackgroundColor: UIColor?
    private var statusBarBackgroundColor: UIColor?
    private var navigationBarBackgroundColor: UIColor? // Home indicator area on iOS
    private var cutoutBackgroundColor: UIColor? // Dynamic Island/Notch area
    
    // ============================================
    // Overlay Views
    // ============================================
    
    private var statusBarOverlay: UIView?
    private var bottomOverlay: UIView? // For home indicator area
    
    // ============================================
    // PUBLIC API METHODS
    // ============================================
    
    /**
     * Configure the entire system UI in a single call.
     */
    @objc func configure(_ call: CAPPluginCall) {
        let edgeToEdge = call.getBool("edgeToEdge")
        let statusBarVisible = call.getBool("statusBarVisible")
        let statusBarStyle = call.getString("statusBarStyle")
        let navigationBarStyle = call.getString("navigationBarStyle")
        let contentBg = call.getString("contentBackgroundColor")
        let statusBarBg = call.getString("statusBarBackgroundColor")
        let navigationBarBg = call.getString("navigationBarBackgroundColor")
        let cutoutBg = call.getString("cutoutBackgroundColor")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance not available")
                return
            }
            
            // Handle edge-to-edge mode
            if let enabled = edgeToEdge {
                self.configureEdgeToEdge(enabled: enabled)
            }
            
            // Parse and store colors
            self.parseAndStoreColors(
                contentBg: contentBg,
                statusBarBg: statusBarBg,
                navigationBarBg: navigationBarBg,
                cutoutBg: cutoutBg
            )
            
            // Apply background colors
            self.applyBackgroundColors()
            
            // Handle visibility
            if let visible = statusBarVisible {
                self.isStatusBarVisible = visible
                self.setStatusBarHidden(!visible)
            }
            
            // Handle styles
            self.applyBarStyles(statusBarStyle: statusBarStyle, navigationBarStyle: navigationBarStyle)
            
            call.resolve()
        }
    }
    
    /**
     * Set background colors for different UI areas.
     */
    @objc func setBackgroundColors(_ call: CAPPluginCall) {
        let contentBg = call.getString("contentBackgroundColor")
        let statusBarBg = call.getString("statusBarBackgroundColor")
        let navigationBarBg = call.getString("navigationBarBackgroundColor")
        let cutoutBg = call.getString("cutoutBackgroundColor")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance not available")
                return
            }
            
            self.parseAndStoreColors(
                contentBg: contentBg,
                statusBarBg: statusBarBg,
                navigationBarBg: navigationBarBg,
                cutoutBg: cutoutBg
            )
            self.applyBackgroundColors()
            
            call.resolve()
        }
    }
    
    /**
     * Set the style (icon color) for system bars.
     */
    @objc func setBarStyles(_ call: CAPPluginCall) {
        let statusBarStyle = call.getString("statusBarStyle")
        let navigationBarStyle = call.getString("navigationBarStyle")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance not available")
                return
            }
            
            self.applyBarStyles(statusBarStyle: statusBarStyle, navigationBarStyle: navigationBarStyle)
            call.resolve()
        }
    }
    
    /**
     * Show or hide the status bar.
     */
    @objc func setStatusBarVisibility(_ call: CAPPluginCall) {
        let visible = call.getBool("visible") ?? true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance not available")
                return
            }
            
            self.isStatusBarVisible = visible
            self.setStatusBarHidden(!visible)
            call.resolve()
        }
    }
    
    /**
     * Show or hide the navigation bar.
     * Note: On iOS, this has no effect as there's no dedicated navigation bar.
     */
    @objc func setNavigationBarVisibility(_ call: CAPPluginCall) {
        // iOS doesn't have a navigation bar like Android
        // The home indicator is always controlled by the system
        call.resolve()
    }
    
    /**
     * Enable or disable edge-to-edge mode.
     */
    @objc func setEdgeToEdge(_ call: CAPPluginCall) {
        let enabled = call.getBool("enabled") ?? true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance not available")
                return
            }
            
            self.configureEdgeToEdge(enabled: enabled)
            call.resolve()
        }
    }
    
    /**
     * Get current system UI state and inset values.
     */
    @objc func getInfo(_ call: CAPPluginCall) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance not available")
                return
            }
            
            let window = self.getKeyWindow()
            let safeAreaInsets = window?.safeAreaInsets ?? UIEdgeInsets.zero
            
            var result = JSObject()
            
            // Inset values
            result["statusBarHeight"] = Int(safeAreaInsets.top)
            result["navigationBarHeight"] = Int(safeAreaInsets.bottom)
            result["leftInset"] = Int(safeAreaInsets.left)
            result["rightInset"] = Int(safeAreaInsets.right)
            
            // Cutout values (on iOS, top inset includes notch/dynamic island)
            result["cutoutTop"] = Int(safeAreaInsets.top)
            result["cutoutLeft"] = Int(safeAreaInsets.left)
            result["cutoutRight"] = Int(safeAreaInsets.right)
            
            // State
            result["isEdgeToEdgeEnabled"] = self.isEdgeToEdgeEnabled
            result["isSafeAreaEnabled"] = self.isSafeAreaEnabled
            result["isStatusBarVisible"] = self.isStatusBarVisible
            result["isNavigationBarVisible"] = self.isNavigationBarVisible
            
            call.resolve(result)
        }
    }
    
    // ============================================
    // PRIVATE HELPER METHODS
    // ============================================
    
    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        }
    }
    
    private func configureEdgeToEdge(enabled: Bool) {
        isEdgeToEdgeEnabled = enabled
        
        guard let webView = bridge?.webView else { return }
        
        if enabled {
            // Enable edge-to-edge by disabling automatic content inset adjustment
            webView.scrollView.contentInsetAdjustmentBehavior = .never
            
            // Make WebView transparent to show window background
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
            
            // Setup overlay views
            setupOverlayViews()
        } else {
            // Restore normal behavior
            webView.scrollView.contentInsetAdjustmentBehavior = .automatic
            
            // Remove overlays
            removeOverlayViews()
        }
    }
    
    private func parseAndStoreColors(
        contentBg: String?,
        statusBarBg: String?,
        navigationBarBg: String?,
        cutoutBg: String?
    ) {
        // Parse content background
        if let bg = contentBg, let color = UIColor.fromHex(bg) {
            contentBackgroundColor = color
        }
        
        // Status bar: if not provided but content is, use content color
        if let bg = statusBarBg, let color = UIColor.fromHex(bg) {
            statusBarBackgroundColor = color
        } else if statusBarBackgroundColor == nil && contentBackgroundColor != nil {
            statusBarBackgroundColor = contentBackgroundColor
        }
        
        // Navigation bar (home indicator area): if not provided but content is, use content color
        if let bg = navigationBarBg, let color = UIColor.fromHex(bg) {
            navigationBarBackgroundColor = color
        } else if navigationBarBackgroundColor == nil && contentBackgroundColor != nil {
            navigationBarBackgroundColor = contentBackgroundColor
        }
        
        // Cutout: if not provided, use content background
        if let bg = cutoutBg, let color = UIColor.fromHex(bg) {
            cutoutBackgroundColor = color
        } else {
            cutoutBackgroundColor = contentBackgroundColor
        }
    }
    
    private func applyBackgroundColors() {
        guard let viewController = bridge?.viewController else { return }
        
        // Set main content background
        if let color = contentBackgroundColor {
            viewController.view.backgroundColor = color
            bridge?.webView?.backgroundColor = .clear
            bridge?.webView?.scrollView.backgroundColor = .clear
        }
        
        // Update overlay colors
        updateOverlayColors()
    }
    
    private func applyBarStyles(statusBarStyle: String?, navigationBarStyle: String?) {
        if let style = statusBarStyle {
            // 'light' = dark icons (for light backgrounds)
            // 'dark' = light icons (for dark backgrounds)
            let uiStyle: UIStatusBarStyle = style.lowercased() == "light" ? .darkContent : .lightContent
            bridge?.statusBarStyle = uiStyle
        }
        
        // navigationBarStyle is ignored on iOS as there's no equivalent
    }
    
    private func setStatusBarHidden(_ hidden: Bool) {
        bridge?.statusBarVisible = !hidden
    }
    
    // ============================================
    // OVERLAY VIEW MANAGEMENT
    // ============================================
    
    private func setupOverlayViews() {
        removeOverlayViews()
        
        guard let parentView = bridge?.webView?.superview,
              let window = getKeyWindow() else { return }
        
        let safeAreaInsets = window.safeAreaInsets
        
        // Create status bar overlay
        if safeAreaInsets.top > 0 {
            let statusBarFrame = CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: safeAreaInsets.top
            )
            let overlay = UIView(frame: statusBarFrame)
            overlay.backgroundColor = statusBarBackgroundColor ?? .clear
            overlay.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            parentView.addSubview(overlay)
            parentView.bringSubviewToFront(overlay)
            statusBarOverlay = overlay
        }
        
        // Create bottom overlay for home indicator area
        if safeAreaInsets.bottom > 0 {
            let bottomFrame = CGRect(
                x: 0,
                y: UIScreen.main.bounds.height - safeAreaInsets.bottom,
                width: UIScreen.main.bounds.width,
                height: safeAreaInsets.bottom
            )
            let overlay = UIView(frame: bottomFrame)
            overlay.backgroundColor = navigationBarBackgroundColor ?? .clear
            overlay.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
            parentView.addSubview(overlay)
            parentView.bringSubviewToFront(overlay)
            bottomOverlay = overlay
        }
    }
    
    private func removeOverlayViews() {
        statusBarOverlay?.removeFromSuperview()
        statusBarOverlay = nil
        
        bottomOverlay?.removeFromSuperview()
        bottomOverlay = nil
    }
    
    private func updateOverlayColors() {
        statusBarOverlay?.backgroundColor = statusBarBackgroundColor ?? .clear
        bottomOverlay?.backgroundColor = navigationBarBackgroundColor ?? .clear
    }
}

// ============================================
// UIColor Extension for Hex String Parsing
// ============================================

extension UIColor {
    /**
     * Creates a UIColor from a hex string.
     * Supports formats: #RGB, #RRGGBB, #RRGGBBAA
     */
    static func fromHex(_ hex: String) -> UIColor? {
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
