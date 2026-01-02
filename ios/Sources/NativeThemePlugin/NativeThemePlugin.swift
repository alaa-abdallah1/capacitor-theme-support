import Foundation
import Capacitor
import UIKit

/**
 * SystemUI - Capacitor plugin for native system UI control on iOS
 *
 * This plugin provides comprehensive control over:
 * - Edge-to-edge display mode (WebView inside safe area, colored margins)
 * - Status bar appearance and visibility
 * - Safe area insets
 * - System color scheme (dark mode) detection
 * - Landscape orientation support
 *
 * @author Payiano
 * @version 2.2.0
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
    private var isKeyboardVisible: Bool = false
    
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
    // Container View (wraps WebView)
    // ============================================
    
    private var containerView: UIView?
    private var hasSetupContainer: Bool = false
    
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
        
        // Listen for app becoming active to re-check color scheme
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
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
        
        observerView.frame = CGRect(x: -1, y: -1, width: 1, height: 1)
        observerView.backgroundColor = .clear
        observerView.isUserInteractionEnabled = false
        viewController.view.addSubview(observerView)
        traitObserverView = observerView
    }
    
    @objc private func handleAppBecameActive() {
        let newScheme = getSystemColorScheme()
        if newScheme != currentColorScheme {
            currentColorScheme = newScheme
            notifyColorSchemeChanged(newScheme)
        }
    }
    
    @objc private func handleOrientationChange() {
        if isEdgeToEdgeEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateWebViewFrame()
            }
        }
    }
    
    @objc private func keyboardWillShow() {
        isKeyboardVisible = true
    }
    
    @objc private func keyboardWillHide() {
        isKeyboardVisible = false
        if isEdgeToEdgeEnabled {
            DispatchQueue.main.async { [weak self] in
                self?.updateWebViewFrame()
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
            
            // Parse and store colors FIRST
            self.parseAndStoreColors(
                contentBg: contentBg,
                statusBarBg: statusBarBg,
                navigationBarBg: navigationBarBg,
                navigationBarLeftBg: navigationBarLeftBg,
                navigationBarRightBg: navigationBarRightBg,
                cutoutBg: cutoutBg
            )
            
            // Handle edge-to-edge mode
            if let enabled = edgeToEdge {
                self.configureEdgeToEdge(enabled: enabled)
            }
            
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
            
            result["statusBarHeight"] = Int(safeAreaInsets.top)
            result["navigationBarHeight"] = Int(safeAreaInsets.bottom)
            result["leftInset"] = Int(safeAreaInsets.left)
            result["rightInset"] = Int(safeAreaInsets.right)
            result["cutoutTop"] = Int(safeAreaInsets.top)
            result["cutoutLeft"] = Int(safeAreaInsets.left)
            result["cutoutRight"] = Int(safeAreaInsets.right)
            result["isEdgeToEdgeEnabled"] = self.isEdgeToEdgeEnabled
            result["isSafeAreaEnabled"] = self.isSafeAreaEnabled
            result["isStatusBarVisible"] = self.isStatusBarVisible
            result["isNavigationBarVisible"] = self.isNavigationBarVisible
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
    
    /**
     * Configure edge-to-edge mode using container approach (like AppViewController)
     * - Container fills entire screen with background color
     * - WebView is placed INSIDE the safe area
     * - Container background shows through in safe area margins
     */
    private func configureEdgeToEdge(enabled: Bool) {
        isEdgeToEdgeEnabled = enabled
        
        guard let webView = bridge?.webView,
              let viewController = bridge?.viewController else { return }
        
        if enabled {
            setupContainerView()
            
            // Configure WebView
            webView.scrollView.contentInsetAdjustmentBehavior = .never
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
            webView.scrollView.bounces = false
            webView.scrollView.alwaysBounceVertical = false
            webView.scrollView.alwaysBounceHorizontal = false
            
            // Update frame to fit inside safe area
            updateWebViewFrame()
            
        } else {
            // Restore normal behavior
            webView.scrollView.contentInsetAdjustmentBehavior = .automatic
            webView.scrollView.bounces = true
            
            // Reset WebView to fill entire view
            webView.frame = viewController.view.bounds
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // Restore container/webview hierarchy
            restoreOriginalHierarchy()
        }
    }
    
    /**
     * Setup container view that wraps the WebView
     * Container fills entire screen, WebView is placed inside safe area
     */
    private func setupContainerView() {
        guard let webView = bridge?.webView,
              let viewController = bridge?.viewController else { return }
        
        // Only setup once
        if hasSetupContainer { return }
        
        // Check if WebView is the root view
        if webView === viewController.view {
            // Create container and wrap WebView
            let container = UIView(frame: UIScreen.main.bounds)
            container.backgroundColor = contentBackgroundColor ?? .systemBackground
            container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // Replace view controller's view with container
            viewController.view = container
            container.addSubview(webView)
            
            containerView = container
            hasSetupContainer = true
        } else if let existingSuperview = webView.superview {
            // WebView is already in a container
            containerView = existingSuperview
            existingSuperview.backgroundColor = contentBackgroundColor ?? .systemBackground
            hasSetupContainer = true
        }
        
        // Re-add trait observer to new view hierarchy
        if let observer = traitObserverView {
            observer.removeFromSuperview()
            viewController.view.addSubview(observer)
        }
    }
    
    /**
     * Restore original view hierarchy when disabling edge-to-edge
     */
    private func restoreOriginalHierarchy() {
        // In most cases, we don't need to restore - just reset the frame
        hasSetupContainer = false
    }
    
    /**
     * Update WebView frame to fit inside safe area
     * This is called on orientation changes and keyboard events
     */
    private func updateWebViewFrame() {
        guard isEdgeToEdgeEnabled,
              let webView = bridge?.webView,
              let viewController = bridge?.viewController,
              !isKeyboardVisible else { return }
        
        // Use safeAreaLayoutGuide to get correct frame
        let safeFrame = viewController.view.safeAreaLayoutGuide.layoutFrame
        
        if webView.frame != safeFrame {
            webView.frame = safeFrame
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
        
        if let color = parsedContentBg {
            contentBackgroundColor = color
        }
        
        if let color = parsedStatusBarBg {
            statusBarBackgroundColor = color
        } else if let content = parsedContentBg {
            statusBarBackgroundColor = content
        }
        
        if let color = parsedNavBarBg {
            navigationBarBackgroundColor = color
        } else if let left = parsedNavBarLeftBg {
            navigationBarBackgroundColor = left
        } else if let right = parsedNavBarRightBg {
            navigationBarBackgroundColor = right
        } else if let content = parsedContentBg {
            navigationBarBackgroundColor = content
        }
        
        if let color = parsedNavBarLeftBg {
            navigationBarLeftBackgroundColor = color
        } else if let right = parsedNavBarRightBg {
            navigationBarLeftBackgroundColor = right
        } else if let navBar = parsedNavBarBg {
            navigationBarLeftBackgroundColor = navBar
        } else if let content = parsedContentBg {
            navigationBarLeftBackgroundColor = content
        }
        
        if let color = parsedNavBarRightBg {
            navigationBarRightBackgroundColor = color
        } else if let left = parsedNavBarLeftBg {
            navigationBarRightBackgroundColor = left
        } else if let navBar = parsedNavBarBg {
            navigationBarRightBackgroundColor = navBar
        } else if let content = parsedContentBg {
            navigationBarRightBackgroundColor = content
        }
        
        if let color = parsedCutoutBg {
            cutoutBackgroundColor = color
        } else if let statusBar = parsedStatusBarBg {
            cutoutBackgroundColor = statusBar
        } else if let content = parsedContentBg {
            cutoutBackgroundColor = content
        }
    }
    
    /**
     * Apply background colors to container and window
     * The container background shows through in safe area margins
     */
    private func applyBackgroundColors() {
        guard let viewController = bridge?.viewController else { return }
        
        // Set container/view background - this shows in safe area margins
        if let color = contentBackgroundColor {
            viewController.view.backgroundColor = color
            containerView?.backgroundColor = color
            getKeyWindow()?.backgroundColor = color
            
            // Keep WebView transparent so container shows through
            bridge?.webView?.backgroundColor = .clear
            bridge?.webView?.scrollView.backgroundColor = .clear
        }
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
    // COLOR SCHEME (DARK MODE) HELPERS
    // ============================================
    
    private func getSystemColorScheme() -> String {
        if let viewController = bridge?.viewController {
            let style = viewController.traitCollection.userInterfaceStyle
            return style == .dark ? "dark" : "light"
        }
        
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
