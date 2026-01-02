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
 * @version 2.1.0
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
    private var isNavigationBarVisible: Bool = true
    private var currentColorScheme: String = "light"
    
    // ============================================
    // Color Configuration
    // ============================================
    
    private var contentBackgroundColor: UIColor?
    private var statusBarBackgroundColor: UIColor?
    private var navigationBarBackgroundColor: UIColor?
    private var navigationBarLeftBackgroundColor: UIColor?
    private var navigationBarRightBackgroundColor: UIColor?
    private var cutoutBackgroundColor: UIColor?
    
    // ============================================
    // Container and Overlay Views
    // ============================================
    
    private var containerView: UIView?
    private var statusBarOverlay: UIView?
    private var bottomOverlay: UIView?
    private var leftOverlay: UIView?
    private var rightOverlay: UIView?
    
    // ============================================
    // Trait Collection Observer
    // ============================================
    
    private var traitObserverView: TraitObserverView?
    
    // ============================================
    // LIFECYCLE METHODS
    // ============================================
    
    public override func load() {
        super.load()
        
        // Initialize color scheme from view controller's trait collection
        DispatchQueue.main.async { [weak self] in
            self?.initializeColorScheme()
            self?.setupTraitObserver()
        }
        
        // Listen for orientation changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        // Also listen for app becoming active to re-check color scheme
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        traitObserverView?.removeFromSuperview()
    }
    
    private func initializeColorScheme() {
        currentColorScheme = getSystemColorScheme()
    }
    
    private func setupTraitObserver() {
        guard let viewController = bridge?.viewController else { return }
        
        // Remove existing observer if any
        traitObserverView?.removeFromSuperview()
        
        // Create observer view that properly detects trait changes
        let observerView = TraitObserverView { [weak self] in
            guard let self = self else { return }
            let newScheme = self.getSystemColorScheme()
            if newScheme != self.currentColorScheme {
                self.currentColorScheme = newScheme
                self.notifyColorSchemeChanged(newScheme)
            }
        }
        
        // The observer must be visible in the view hierarchy to receive trait changes
        observerView.frame = CGRect(x: -1, y: -1, width: 1, height: 1)
        observerView.backgroundColor = .clear
        observerView.isUserInteractionEnabled = false
        viewController.view.addSubview(observerView)
        traitObserverView = observerView
    }
    
    @objc private func handleAppBecameActive() {
        // Re-check color scheme when app becomes active
        let newScheme = getSystemColorScheme()
        if newScheme != currentColorScheme {
            currentColorScheme = newScheme
            notifyColorSchemeChanged(newScheme)
        }
    }
    
    @objc private func handleOrientationChange() {
        if isEdgeToEdgeEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateOverlayFrames()
            }
        }
    }
    
    // ============================================
    // PUBLIC API METHODS
    // ============================================
    
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
                navigationBarLeftBg: navigationBarLeftBg,
                navigationBarRightBg: navigationBarRightBg,
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
    
    @objc func setNavigationBarVisibility(_ call: CAPPluginCall) {
        // iOS doesn't have a navigation bar like Android
        call.resolve()
    }
    
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
            
            // Cutout values
            result["cutoutTop"] = Int(safeAreaInsets.top)
            result["cutoutLeft"] = Int(safeAreaInsets.left)
            result["cutoutRight"] = Int(safeAreaInsets.right)
            
            // State
            result["isEdgeToEdgeEnabled"] = self.isEdgeToEdgeEnabled
            result["isSafeAreaEnabled"] = self.isSafeAreaEnabled
            result["isStatusBarVisible"] = self.isStatusBarVisible
            result["isNavigationBarVisible"] = self.isNavigationBarVisible
            
            // Color scheme - get fresh value
            result["colorScheme"] = self.getSystemColorScheme()
            
            call.resolve(result)
        }
    }
    
    @objc func getColorScheme(_ call: CAPPluginCall) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance not available")
                return
            }
            
            // Always get fresh color scheme from view controller
            let colorScheme = self.getSystemColorScheme()
            self.currentColorScheme = colorScheme
            
            var result = JSObject()
            result["colorScheme"] = colorScheme
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
        
        guard let webView = bridge?.webView,
              let viewController = bridge?.viewController else { return }
        
        if enabled {
            // Disable automatic content inset adjustment
            webView.scrollView.contentInsetAdjustmentBehavior = .never
            
            // Make WebView transparent to show window background
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
            
            // Disable bounce
            webView.scrollView.bounces = false
            webView.scrollView.alwaysBounceVertical = false
            webView.scrollView.alwaysBounceHorizontal = false
            
            // Set the window/view controller background
            if let color = contentBackgroundColor {
                viewController.view.backgroundColor = color
                getKeyWindow()?.backgroundColor = color
            }
            
            // Setup overlay views for safe area coloring
            setupOverlayViews()
            
            // Make sure WebView fills the entire screen
            webView.frame = viewController.view.bounds
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        } else {
            // Restore normal behavior
            webView.scrollView.contentInsetAdjustmentBehavior = .automatic
            webView.scrollView.bounces = true
            
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
        
        // Navigation bar (bottom)
        if let color = parsedNavBarBg {
            navigationBarBackgroundColor = color
        } else if let left = parsedNavBarLeftBg {
            navigationBarBackgroundColor = left
        } else if let right = parsedNavBarRightBg {
            navigationBarBackgroundColor = right
        } else if let content = parsedContentBg {
            navigationBarBackgroundColor = content
        }
        
        // Navigation bar left
        if let color = parsedNavBarLeftBg {
            navigationBarLeftBackgroundColor = color
        } else if let right = parsedNavBarRightBg {
            navigationBarLeftBackgroundColor = right
        } else if let navBar = parsedNavBarBg {
            navigationBarLeftBackgroundColor = navBar
        } else if let content = parsedContentBg {
            navigationBarLeftBackgroundColor = content
        }
        
        // Navigation bar right
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
        
        // Set main content background on both view controller and window
        if let color = contentBackgroundColor {
            viewController.view.backgroundColor = color
            getKeyWindow()?.backgroundColor = color
            bridge?.webView?.backgroundColor = .clear
            bridge?.webView?.scrollView.backgroundColor = .clear
        }
        
        // Update overlay colors
        updateOverlayColors()
    }
    
    private func applyBarStyles(statusBarStyle: String?, navigationBarStyle: String?) {
        if let style = statusBarStyle {
            let uiStyle: UIStatusBarStyle = style.lowercased() == "light" ? .darkContent : .lightContent
            bridge?.statusBarStyle = uiStyle
        }
    }
    
    private func setStatusBarHidden(_ hidden: Bool) {
        bridge?.statusBarVisible = !hidden
    }
    
    // ============================================
    // OVERLAY VIEW MANAGEMENT
    // ============================================
    
    private func setupOverlayViews() {
        removeOverlayViews()
        
        guard let viewController = bridge?.viewController,
              let window = getKeyWindow() else { return }
        
        let parentView = viewController.view!
        let safeAreaInsets = window.safeAreaInsets
        let bounds = parentView.bounds
        
        // Status bar overlay (top)
        if safeAreaInsets.top > 0 {
            let overlay = UIView()
            overlay.backgroundColor = statusBarBackgroundColor ?? .clear
            overlay.frame = CGRect(x: 0, y: 0, width: bounds.width, height: safeAreaInsets.top)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            parentView.addSubview(overlay)
            statusBarOverlay = overlay
        }
        
        // Bottom overlay (home indicator area)
        if safeAreaInsets.bottom > 0 {
            let overlay = UIView()
            overlay.backgroundColor = navigationBarBackgroundColor ?? .clear
            overlay.frame = CGRect(x: 0, y: bounds.height - safeAreaInsets.bottom, width: bounds.width, height: safeAreaInsets.bottom)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
            parentView.addSubview(overlay)
            bottomOverlay = overlay
        }
        
        // Left overlay (landscape)
        if safeAreaInsets.left > 0 {
            let overlay = UIView()
            overlay.backgroundColor = navigationBarLeftBackgroundColor ?? .clear
            overlay.frame = CGRect(x: 0, y: 0, width: safeAreaInsets.left, height: bounds.height)
            overlay.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
            parentView.addSubview(overlay)
            leftOverlay = overlay
        }
        
        // Right overlay (landscape)
        if safeAreaInsets.right > 0 {
            let overlay = UIView()
            overlay.backgroundColor = navigationBarRightBackgroundColor ?? .clear
            overlay.frame = CGRect(x: bounds.width - safeAreaInsets.right, y: 0, width: safeAreaInsets.right, height: bounds.height)
            overlay.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
            parentView.addSubview(overlay)
            rightOverlay = overlay
        }
        
        // Bring WebView to front so overlays are behind it
        if let webView = bridge?.webView {
            parentView.bringSubviewToFront(webView)
        }
        
        // Bring trait observer to front
        if let observer = traitObserverView {
            parentView.bringSubviewToFront(observer)
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
    
    private func updateOverlayFrames() {
        guard let window = getKeyWindow(),
              let parentView = bridge?.viewController?.view else { return }
        
        let safeAreaInsets = window.safeAreaInsets
        let bounds = parentView.bounds
        
        // Update or create overlays based on current safe area insets
        if safeAreaInsets.top > 0 {
            if statusBarOverlay == nil {
                let overlay = UIView()
                overlay.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
                parentView.addSubview(overlay)
                statusBarOverlay = overlay
            }
            statusBarOverlay?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: safeAreaInsets.top)
        } else {
            statusBarOverlay?.removeFromSuperview()
            statusBarOverlay = nil
        }
        
        if safeAreaInsets.bottom > 0 {
            if bottomOverlay == nil {
                let overlay = UIView()
                overlay.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
                parentView.addSubview(overlay)
                bottomOverlay = overlay
            }
            bottomOverlay?.frame = CGRect(x: 0, y: bounds.height - safeAreaInsets.bottom, width: bounds.width, height: safeAreaInsets.bottom)
        } else {
            bottomOverlay?.removeFromSuperview()
            bottomOverlay = nil
        }
        
        if safeAreaInsets.left > 0 {
            if leftOverlay == nil {
                let overlay = UIView()
                overlay.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                parentView.addSubview(overlay)
                leftOverlay = overlay
            }
            leftOverlay?.frame = CGRect(x: 0, y: 0, width: safeAreaInsets.left, height: bounds.height)
        } else {
            leftOverlay?.removeFromSuperview()
            leftOverlay = nil
        }
        
        if safeAreaInsets.right > 0 {
            if rightOverlay == nil {
                let overlay = UIView()
                overlay.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
                parentView.addSubview(overlay)
                rightOverlay = overlay
            }
            rightOverlay?.frame = CGRect(x: bounds.width - safeAreaInsets.right, y: 0, width: safeAreaInsets.right, height: bounds.height)
        } else {
            rightOverlay?.removeFromSuperview()
            rightOverlay = nil
        }
        
        updateOverlayColors()
        
        // Ensure proper z-order
        if let webView = bridge?.webView {
            parentView.bringSubviewToFront(webView)
        }
        if let observer = traitObserverView {
            parentView.bringSubviewToFront(observer)
        }
    }
    
    private func updateOverlayColors() {
        let effectiveCutoutColor = cutoutBackgroundColor ?? contentBackgroundColor ?? .clear
        
        let window = getKeyWindow()
        let safeAreaInsets = window?.safeAreaInsets ?? UIEdgeInsets.zero
        let hasLeftCutout = safeAreaInsets.left > 0
        let hasRightCutout = safeAreaInsets.right > 0
        
        statusBarOverlay?.backgroundColor = statusBarBackgroundColor ?? .clear
        bottomOverlay?.backgroundColor = navigationBarBackgroundColor ?? .clear
        
        if hasLeftCutout {
            leftOverlay?.backgroundColor = effectiveCutoutColor
        } else {
            leftOverlay?.backgroundColor = navigationBarLeftBackgroundColor ?? navigationBarBackgroundColor ?? .clear
        }
        
        if hasRightCutout {
            rightOverlay?.backgroundColor = effectiveCutoutColor
        } else {
            rightOverlay?.backgroundColor = navigationBarRightBackgroundColor ?? navigationBarBackgroundColor ?? .clear
        }
    }
    
    // ============================================
    // COLOR SCHEME (DARK MODE) HELPERS
    // ============================================
    
    /**
     * Get the current system color scheme from the view controller's trait collection.
     * This is the reliable way to get the current color scheme.
     */
    private func getSystemColorScheme() -> String {
        // Must use the view controller's trait collection, not UITraitCollection.current
        if let viewController = bridge?.viewController {
            let style = viewController.traitCollection.userInterfaceStyle
            return style == .dark ? "dark" : "light"
        }
        
        // Fallback to window
        if let window = getKeyWindow() {
            let style = window.traitCollection.userInterfaceStyle
            return style == .dark ? "dark" : "light"
        }
        
        return "light"
    }
    
    private func notifyColorSchemeChanged(_ colorScheme: String) {
        var data = JSObject()
        data["colorScheme"] = colorScheme
        notifyListeners(EVENT_COLOR_SCHEME_CHANGED, data: data)
    }
}

// ============================================
// TraitObserverView - Detects system theme changes
// ============================================

/**
 * A UIView that observes trait collection changes.
 * This is the reliable way to detect dark mode changes in iOS.
 */
private class TraitObserverView: UIView {
    private var onTraitChange: (() -> Void)?
    
    init(onTraitChange: @escaping () -> Void) {
        self.onTraitChange = onTraitChange
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                onTraitChange?()
            }
        }
    }
}

// ============================================
// UIColor Extension for Hex String Parsing
// ============================================

extension UIColor {
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
