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
 * - System color scheme (dark mode) detection
 * - Landscape orientation support
 *
 * Note: iOS does not have a dedicated navigation bar like Android.
 * The home indicator area is handled automatically by iOS.
 *
 * @author Payiano
 * @version 2.0.0
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
        CAPPluginMethod(name: "getInfo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getColorScheme", returnType: CAPPluginReturnPromise)
    ]
    
    // ============================================
    // Constants
    // ============================================
    
    private let EVENT_COLOR_SCHEME_CHANGED = "colorSchemeChanged"
    
    // ============================================
    // Configuration State
    // ============================================
    
    private var isEdgeToEdgeEnabled: Bool = false
    private var isSafeAreaEnabled: Bool = true
    private var isStatusBarVisible: Bool = true
    private var isNavigationBarVisible: Bool = true // Always true on iOS (no equivalent)
    private var currentColorScheme: String = "light"
    
    // ============================================
    // Color Configuration
    // ============================================
    
    private var contentBackgroundColor: UIColor?
    private var statusBarBackgroundColor: UIColor?
    private var navigationBarBackgroundColor: UIColor? // Home indicator area on iOS
    private var navigationBarLeftBackgroundColor: UIColor? // Left inset in landscape
    private var navigationBarRightBackgroundColor: UIColor? // Right inset in landscape
    
    // ============================================
    // Corner Radius Configuration
    // ============================================
    
    /// Content corner radius in points. -1 means use device default, 0 means disabled.
    private var contentCornerRadius: CGFloat = -1
    
    /// Device display corner radius in points. Detected from device screen.
    private var deviceCornerRadius: CGFloat = 0
    private var cutoutBackgroundColor: UIColor? // Dynamic Island/Notch area
    
    // ============================================
    // Overlay Views
    // ============================================
    
    private var statusBarOverlay: UIView?
    private var bottomOverlay: UIView? // For home indicator area
    private var leftOverlay: UIView? // For landscape left inset
    private var rightOverlay: UIView? // For landscape right inset
    
    // ============================================
    // LIFECYCLE METHODS
    // ============================================
    
    public override func load() {
        super.load()
        
        // Initialize color scheme
        currentColorScheme = getSystemColorScheme()
        
        // Detect device corner radius
        detectDeviceCornerRadius()
        
        // Listen for trait changes (including dark mode)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTraitCollectionChange),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleTraitCollectionChange() {
        let newColorScheme = getSystemColorScheme()
        if newColorScheme != currentColorScheme {
            currentColorScheme = newColorScheme
            notifyColorSchemeChanged(newColorScheme)
        }
    }
    
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
        let navigationBarLeftBg = call.getString("navigationBarLeftBackgroundColor")
        let navigationBarRightBg = call.getString("navigationBarRightBackgroundColor")
        let cutoutBg = call.getString("cutoutBackgroundColor")
        let cornerRadius = call.getFloat("contentCornerRadius")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance not available")
                return
            }
            
            // Handle edge-to-edge mode
            if let enabled = edgeToEdge {
                self.configureEdgeToEdge(enabled: enabled)
            }
            
            // Handle content corner radius
            if let radius = cornerRadius {
                self.contentCornerRadius = CGFloat(radius)
            }
            
            // Parse and store colors
            self.parseAndStoreColors(
                contentBg: contentBg,
                statusBarBg: statusBarBg,
                navigationBarBg: navigationBarBg,
                navigationBarLeftBg: navigationBarLeftBg,
                navigationBarRightBg: navigationBarRightBg,
                cutoutBg: cutoutBg
            )
            
            // Apply background colors
            self.applyBackgroundColors()
            
            // Apply content corner radius
            self.applyContentCornerRadius()
            
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
        let navigationBarLeftBg = call.getString("navigationBarLeftBackgroundColor")
        let navigationBarRightBg = call.getString("navigationBarRightBackgroundColor")
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
                navigationBarLeftBg: navigationBarLeftBg,
                navigationBarRightBg: navigationBarRightBg,
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
            
            // Color scheme
            result["colorScheme"] = self.currentColorScheme
            
            // Corner radius values
            result["contentCornerRadius"] = self.contentCornerRadius
            result["deviceCornerRadius"] = self.deviceCornerRadius
            
            call.resolve(result)
        }
    }
    
    /**
     * Get the current system color scheme.
     */
    @objc func getColorScheme(_ call: CAPPluginCall) {
        var result = JSObject()
        result["colorScheme"] = currentColorScheme
        call.resolve(result)
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
        navigationBarLeftBg: String?,
        navigationBarRightBg: String?,
        cutoutBg: String?
    ) {
        // Parse all colors first
        let parsedContentBg = contentBg.flatMap { UIColor.fromHex($0) }
        let parsedStatusBarBg = statusBarBg.flatMap { UIColor.fromHex($0) }
        let parsedNavBarBg = navigationBarBg.flatMap { UIColor.fromHex($0) }
        let parsedNavBarLeftBg = navigationBarLeftBg.flatMap { UIColor.fromHex($0) }
        let parsedNavBarRightBg = navigationBarRightBg.flatMap { UIColor.fromHex($0) }
        let parsedCutoutBg = cutoutBg.flatMap { UIColor.fromHex($0) }
        
        // Update content background if provided
        if let color = parsedContentBg {
            contentBackgroundColor = color
        }
        
        // Status bar: use provided value, or cascade from content
        if let color = parsedStatusBarBg {
            statusBarBackgroundColor = color
        } else if let content = parsedContentBg {
            statusBarBackgroundColor = content
        }
        
        // Navigation bar (bottom): use provided, or cascade from left/right -> content
        if let color = parsedNavBarBg {
            navigationBarBackgroundColor = color
        } else if let left = parsedNavBarLeftBg {
            navigationBarBackgroundColor = left
        } else if let right = parsedNavBarRightBg {
            navigationBarBackgroundColor = right
        } else if let content = parsedContentBg {
            navigationBarBackgroundColor = content
        }
        
        // Navigation bar left: use provided, or cascade from right -> navBar -> content
        if let color = parsedNavBarLeftBg {
            navigationBarLeftBackgroundColor = color
        } else if let right = parsedNavBarRightBg {
            navigationBarLeftBackgroundColor = right
        } else if let navBar = parsedNavBarBg {
            navigationBarLeftBackgroundColor = navBar
        } else if let content = parsedContentBg {
            navigationBarLeftBackgroundColor = content
        }
        
        // Navigation bar right: use provided, or cascade from left -> navBar -> content
        if let color = parsedNavBarRightBg {
            navigationBarRightBackgroundColor = color
        } else if let left = parsedNavBarLeftBg {
            navigationBarRightBackgroundColor = left
        } else if let navBar = parsedNavBarBg {
            navigationBarRightBackgroundColor = navBar
        } else if let content = parsedContentBg {
            navigationBarRightBackgroundColor = content
        }
        
        // Cutout: use provided, or cascade from status bar -> content
        if let color = parsedCutoutBg {
            cutoutBackgroundColor = color
        } else if let statusBar = parsedStatusBarBg {
            cutoutBackgroundColor = statusBar
        } else if let content = parsedContentBg {
            cutoutBackgroundColor = content
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
        let screenBounds = UIScreen.main.bounds
        
        // Create status bar overlay (top)
        if safeAreaInsets.top > 0 {
            let statusBarFrame = CGRect(
                x: 0,
                y: 0,
                width: screenBounds.width,
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
                y: screenBounds.height - safeAreaInsets.bottom,
                width: screenBounds.width,
                height: safeAreaInsets.bottom
            )
            let overlay = UIView(frame: bottomFrame)
            overlay.backgroundColor = navigationBarBackgroundColor ?? .clear
            overlay.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
            parentView.addSubview(overlay)
            parentView.bringSubviewToFront(overlay)
            bottomOverlay = overlay
        }
        
        // Create left overlay for landscape
        if safeAreaInsets.left > 0 {
            let leftFrame = CGRect(
                x: 0,
                y: 0,
                width: safeAreaInsets.left,
                height: screenBounds.height
            )
            let overlay = UIView(frame: leftFrame)
            overlay.backgroundColor = navigationBarLeftBackgroundColor ?? .clear
            overlay.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
            parentView.addSubview(overlay)
            parentView.bringSubviewToFront(overlay)
            leftOverlay = overlay
        }
        
        // Create right overlay for landscape
        if safeAreaInsets.right > 0 {
            let rightFrame = CGRect(
                x: screenBounds.width - safeAreaInsets.right,
                y: 0,
                width: safeAreaInsets.right,
                height: screenBounds.height
            )
            let overlay = UIView(frame: rightFrame)
            overlay.backgroundColor = navigationBarRightBackgroundColor ?? .clear
            overlay.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
            parentView.addSubview(overlay)
            parentView.bringSubviewToFront(overlay)
            rightOverlay = overlay
        }
    }
    
    private func removeOverlayViews() {
        statusBarOverlay?.removeFromSuperview()
        statusBarOverlay = nil
        
        bottomOverlay?.removeFromSuperview()
        bottomOverlay = nil
        
        leftOverlay?.removeFromSuperview()
        leftOverlay = nil
        
        rightOverlay?.removeFromSuperview()
        rightOverlay = nil
    }
    
    private func updateOverlayColors() {
        statusBarOverlay?.backgroundColor = statusBarBackgroundColor ?? .clear
        bottomOverlay?.backgroundColor = navigationBarBackgroundColor ?? .clear
        leftOverlay?.backgroundColor = navigationBarLeftBackgroundColor ?? .clear
        rightOverlay?.backgroundColor = navigationBarRightBackgroundColor ?? .clear
    }
    
    // ============================================
    // COLOR SCHEME (DARK MODE) HELPERS
    // ============================================
    
    /**
     * Get the current system color scheme.
     */
    private func getSystemColorScheme() -> String {
        if #available(iOS 13.0, *) {
            let style = UITraitCollection.current.userInterfaceStyle
            return style == .dark ? "dark" : "light"
        } else {
            return "light"
        }
    }
    
    /**
     * Notify JavaScript listeners of a color scheme change.
     */
    private func notifyColorSchemeChanged(_ colorScheme: String) {
        var data = JSObject()
        data["colorScheme"] = colorScheme
        notifyListeners(EVENT_COLOR_SCHEME_CHANGED, data: data)
    }
    
    // ============================================
    // CORNER RADIUS HELPERS
    // ============================================
    
    /**
     * Detect the device's display corner radius.
     * Uses private API on iOS to get actual screen corner radius.
     */
    private func detectDeviceCornerRadius() {
        if #available(iOS 13.0, *) {
            // Try to get corner radius from the display
            // iOS doesn't have a public API for this, so we use a known default
            // based on device type. Modern iPhones with notch/dynamic island have ~40pt corners.
            let window = getKeyWindow()
            let screen = window?.screen ?? UIScreen.main
            
            // Check if device has safe area (indicates modern iPhone with rounded corners)
            let safeAreaInsets = window?.safeAreaInsets ?? UIEdgeInsets.zero
            
            if safeAreaInsets.top > 20 {
                // Modern iPhone with notch/dynamic island - use 40pt
                deviceCornerRadius = 40
            } else if safeAreaInsets.bottom > 0 {
                // iPhone X-style home indicator - use 40pt
                deviceCornerRadius = 40
            } else {
                // Older device or iPad - no corner radius or minimal
                deviceCornerRadius = 0
            }
        } else {
            // Pre-iOS 13 devices don't have rounded corners
            deviceCornerRadius = 0
        }
    }
    
    /**
     * Apply corner radius to the content view.
     * Only applies in landscape mode when there are cutouts on the sides.
     */
    private func applyContentCornerRadius() {
        guard let webView = bridge?.webView else { return }
        
        // Determine effective radius
        let effectiveRadius: CGFloat
        if contentCornerRadius < 0 {
            // Use device corner radius
            effectiveRadius = deviceCornerRadius
        } else if contentCornerRadius == 0 {
            // Disabled
            webView.layer.cornerRadius = 0
            webView.layer.maskedCorners = []
            webView.clipsToBounds = false
            return
        } else {
            effectiveRadius = contentCornerRadius
        }
        
        // Skip if no radius
        if effectiveRadius <= 0 {
            webView.layer.cornerRadius = 0
            webView.layer.maskedCorners = []
            webView.clipsToBounds = false
            return
        }
        
        // Check orientation and cutouts
        let window = getKeyWindow()
        let safeAreaInsets = window?.safeAreaInsets ?? UIEdgeInsets.zero
        let isLandscape = UIDevice.current.orientation.isLandscape ||
                          (window?.frame.width ?? 0) > (window?.frame.height ?? 0)
        
        let hasLeftCutout = safeAreaInsets.left > 0
        let hasRightCutout = safeAreaInsets.right > 0
        
        if !isLandscape || (!hasLeftCutout && !hasRightCutout) {
            // Portrait or no cutouts - remove corner radius
            webView.layer.cornerRadius = 0
            webView.layer.maskedCorners = []
            webView.clipsToBounds = false
            return
        }
        
        // Apply corner radius only on cutout sides
        var maskedCorners: CACornerMask = []
        
        if hasLeftCutout {
            maskedCorners.insert(.layerMinXMinYCorner) // Top-left
            maskedCorners.insert(.layerMinXMaxYCorner) // Bottom-left
        }
        
        if hasRightCutout {
            maskedCorners.insert(.layerMaxXMinYCorner) // Top-right
            maskedCorners.insert(.layerMaxXMaxYCorner) // Bottom-right
        }
        
        webView.layer.cornerRadius = effectiveRadius
        webView.layer.maskedCorners = maskedCorners
        webView.clipsToBounds = true
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
