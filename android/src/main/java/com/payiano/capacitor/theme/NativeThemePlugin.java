package com.payiano.capacitor.theme;

import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Build;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

/**
 * SystemUI - Capacitor plugin for native system UI control
 *
 * This plugin provides comprehensive control over:
 * - Edge-to-edge display mode
 * - Status bar appearance and visibility
 * - Navigation bar appearance and visibility
 * - Safe area insets
 * - Display cutout (notch) handling
 * - System color scheme (dark mode) detection
 * - Landscape orientation support
 *
 * @author Payiano
 * @version 1.0.0
 */
@CapacitorPlugin(name = "SystemUI")
public class NativeThemePlugin extends Plugin {

    // ============================================
    // Constants
    // ============================================

    /** Event name for color scheme changes */
    private static final String EVENT_COLOR_SCHEME_CHANGED = "colorSchemeChanged";

    // ============================================
    // Configuration State
    // ============================================

    /** Whether edge-to-edge mode is currently active */
    private boolean isEdgeToEdgeEnabled = false;

    /** Whether content should respect safe area insets */
    private boolean isSafeAreaEnabled = true;

    /** Current visibility state of the status bar */
    private boolean isStatusBarVisible = true;

    /** Current visibility state of the navigation bar */
    private boolean isNavigationBarVisible = true;

    /** Current system color scheme */
    private String currentColorScheme = "light";

    // ============================================
    // Inset Values (in pixels)
    // ============================================

    private int statusBarHeight = 0;
    private int navigationBarHeight = 0;
    private int leftInset = 0;
    private int rightInset = 0;

    // Display cutout tracking
    private int cutoutTop = 0;
    private int cutoutLeft = 0;
    private int cutoutRight = 0;

    // ============================================
    // Color Configuration
    // ============================================

    /** Background color for the main content area */
    private Integer contentBackgroundColor = null;

    /** Background color for the status bar area */
    private Integer statusBarBackgroundColor = null;

    /** Background color for the navigation bar area (bottom) */
    private Integer navigationBarBackgroundColor = null;

    /** Background color for the left navigation bar area (landscape) */
    private Integer navigationBarLeftBackgroundColor = null;

    /** Background color for the right navigation bar area (landscape) */
    private Integer navigationBarRightBackgroundColor = null;

    /** Background color for display cutout areas */
    private Integer cutoutBackgroundColor = null;

    // ============================================
    // Overlay Views for System Bar Colors
    // ============================================

    private View statusBarOverlay;
    private View navBarBottomOverlay;
    private View navBarLeftOverlay;
    private View navBarRightOverlay;

    private static final int STATUS_BAR_OVERLAY_ID = View.generateViewId();
    private static final int NAV_BAR_BOTTOM_OVERLAY_ID = View.generateViewId();
    private static final int NAV_BAR_LEFT_OVERLAY_ID = View.generateViewId();
    private static final int NAV_BAR_RIGHT_OVERLAY_ID = View.generateViewId();

    // ============================================
    // LIFECYCLE METHODS
    // ============================================

    @Override
    public void load() {
        super.load();
        // Initialize color scheme on plugin load
        currentColorScheme = getSystemColorScheme();
    }

    @Override
    public void handleOnConfigurationChanged(Configuration newConfig) {
        super.handleOnConfigurationChanged(newConfig);

        // Check for color scheme changes
        String newColorScheme = getSystemColorScheme();
        if (!newColorScheme.equals(currentColorScheme)) {
            currentColorScheme = newColorScheme;
            notifyColorSchemeChanged(newColorScheme);
        }
    }

    // ============================================
    // PUBLIC API METHODS
    // ============================================

    /**
     * Configure the entire system UI in a single call.
     *
     * This is the recommended method for most use cases as it allows you to
     * configure all aspects of the system UI at once, ensuring consistent behavior.
     *
     * Options:
     * - edgeToEdge: Enable/disable edge-to-edge mode (content behind system bars)
     * - statusBarVisible: Show/hide the status bar
     * - navigationBarVisible: Show/hide the navigation bar
     * - statusBarStyle: 'light' (dark icons) or 'dark' (light icons)
     * - navigationBarStyle: 'light' (dark icons) or 'dark' (light icons)
     * - contentBackgroundColor: Main app background color (hex string)
     * - statusBarBackgroundColor: Status bar background (hex string)
     * - navigationBarBackgroundColor: Navigation bar background (hex string)
     * - navigationBarLeftBackgroundColor: Left bar background in landscape (hex string)
     * - navigationBarRightBackgroundColor: Right bar background in landscape (hex string)
     * - cutoutBackgroundColor: Display cutout area background (hex string)
     *
     * @param call Plugin call containing configuration options
     */
    @PluginMethod
    public void configure(PluginCall call) {
        // Get all configuration options
        Boolean edgeToEdge = call.getBoolean("edgeToEdge");
        Boolean statusBarVisible = call.getBoolean("statusBarVisible");
        Boolean navigationBarVisible = call.getBoolean("navigationBarVisible");
        String statusBarStyle = call.getString("statusBarStyle");
        String navigationBarStyle = call.getString("navigationBarStyle");
        String contentBg = call.getString("contentBackgroundColor");
        String statusBarBg = call.getString("statusBarBackgroundColor");
        String navigationBarBg = call.getString("navigationBarBackgroundColor");
        String navigationBarLeftBg = call.getString("navigationBarLeftBackgroundColor");
        String navigationBarRightBg = call.getString("navigationBarRightBackgroundColor");
        String cutoutBg = call.getString("cutoutBackgroundColor");

        runOnUI(
            () -> {
                try {
                    Window window = getWindow();

                    // Handle edge-to-edge mode
                    if (edgeToEdge != null) {
                        configureEdgeToEdge(window, edgeToEdge);
                    }

                    // Parse and store colors
                    parseAndStoreColors(contentBg, statusBarBg, navigationBarBg, navigationBarLeftBg, navigationBarRightBg, cutoutBg);

                    // Apply background colors
                    applyBackgroundColors(window);

                    // Handle visibility
                    if (statusBarVisible != null) {
                        setBarVisibility(window, true, statusBarVisible);
                        isStatusBarVisible = statusBarVisible;
                    }
                    if (navigationBarVisible != null) {
                        setBarVisibility(window, false, navigationBarVisible);
                        isNavigationBarVisible = navigationBarVisible;
                    }

                    // Handle styles (icon colors)
                    applyBarStyles(window, statusBarStyle, navigationBarStyle);

                    call.resolve();
                } catch (Exception e) {
                    call.reject("Configuration failed: " + e.getMessage());
                }
            }
        );
    }

    /**
     * Set background colors for different UI areas.
     *
     * Color Behavior:
     * - If only contentBackgroundColor is set: fills entire screen
     * - If navigationBarLeftBackgroundColor not set: uses navigationBarBackgroundColor
     * - If navigationBarRightBackgroundColor not set: uses navigationBarBackgroundColor
     * - If no color is set for an area: defaults to transparent
     *
     * @param call Plugin call with color options
     */
    @PluginMethod
    public void setBackgroundColors(PluginCall call) {
        String contentBg = call.getString("contentBackgroundColor");
        String statusBarBg = call.getString("statusBarBackgroundColor");
        String navigationBarBg = call.getString("navigationBarBackgroundColor");
        String navigationBarLeftBg = call.getString("navigationBarLeftBackgroundColor");
        String navigationBarRightBg = call.getString("navigationBarRightBackgroundColor");
        String cutoutBg = call.getString("cutoutBackgroundColor");

        runOnUI(
            () -> {
                try {
                    parseAndStoreColors(contentBg, statusBarBg, navigationBarBg, navigationBarLeftBg, navigationBarRightBg, cutoutBg);
                    applyBackgroundColors(getWindow());
                    call.resolve();
                } catch (Exception e) {
                    call.reject("Failed to set colors: " + e.getMessage());
                }
            }
        );
    }

    /**
     * Set the style (icon color) for system bars.
     *
     * Styles:
     * - 'light': Dark icons/text (for light backgrounds)
     * - 'dark': Light icons/text (for dark backgrounds)
     *
     * @param call Plugin call with style options
     */
    @PluginMethod
    public void setBarStyles(PluginCall call) {
        String statusBarStyle = call.getString("statusBarStyle");
        String navigationBarStyle = call.getString("navigationBarStyle");

        runOnUI(
            () -> {
                try {
                    applyBarStyles(getWindow(), statusBarStyle, navigationBarStyle);
                    call.resolve();
                } catch (Exception e) {
                    call.reject("Failed to set styles: " + e.getMessage());
                }
            }
        );
    }

    /**
     * Show or hide the status bar.
     *
     * When hidden, the status bar can be revealed by swiping from the top edge.
     *
     * @param call Plugin call with 'visible' boolean
     */
    @PluginMethod
    public void setStatusBarVisibility(PluginCall call) {
        boolean visible = call.getBoolean("visible", true);

        runOnUI(
            () -> {
                try {
                    isStatusBarVisible = visible;
                    setBarVisibility(getWindow(), true, visible);
                    call.resolve();
                } catch (Exception e) {
                    call.reject("Failed to set status bar visibility: " + e.getMessage());
                }
            }
        );
    }

    /**
     * Show or hide the navigation bar.
     *
     * When hidden, the navigation bar can be revealed by swiping from the bottom edge.
     *
     * @param call Plugin call with 'visible' boolean
     */
    @PluginMethod
    public void setNavigationBarVisibility(PluginCall call) {
        boolean visible = call.getBoolean("visible", true);

        runOnUI(
            () -> {
                try {
                    isNavigationBarVisible = visible;
                    setBarVisibility(getWindow(), false, visible);
                    call.resolve();
                } catch (Exception e) {
                    call.reject("Failed to set navigation bar visibility: " + e.getMessage());
                }
            }
        );
    }

    /**
     * Enable or disable edge-to-edge mode.
     *
     * When enabled:
     * - Content draws behind system bars
     * - You have full control over system bar backgrounds
     * - Safe area insets are available for content positioning
     *
     * When disabled:
     * - System bars are handled normally by the OS
     * - Content does not draw behind system bars
     *
     * @param call Plugin call with 'enabled' boolean
     */
    @PluginMethod
    public void setEdgeToEdge(PluginCall call) {
        boolean enabled = call.getBoolean("enabled", true);

        runOnUI(
            () -> {
                try {
                    configureEdgeToEdge(getWindow(), enabled);
                    call.resolve();
                } catch (Exception e) {
                    call.reject("Failed to set edge-to-edge: " + e.getMessage());
                }
            }
        );
    }

    /**
     * Get current system UI state and inset values.
     *
     * Returns:
     * - statusBarHeight: Height of status bar in pixels
     * - navigationBarHeight: Height of navigation bar in pixels
     * - leftInset: Left safe area inset in pixels
     * - rightInset: Right safe area inset in pixels
     * - cutoutTop/Left/Right: Display cutout dimensions
     * - isEdgeToEdgeEnabled: Current edge-to-edge state
     * - isSafeAreaEnabled: Current safe area state
     * - isStatusBarVisible: Current status bar visibility
     * - isNavigationBarVisible: Current navigation bar visibility
     * - colorScheme: Current system color scheme ('light' or 'dark')
     *
     * @param call Plugin call
     */
    @PluginMethod
    public void getInfo(PluginCall call) {
        JSObject result = new JSObject();

        // Inset values
        result.put("statusBarHeight", statusBarHeight);
        result.put("navigationBarHeight", navigationBarHeight);
        result.put("leftInset", leftInset);
        result.put("rightInset", rightInset);

        // Cutout values
        result.put("cutoutTop", cutoutTop);
        result.put("cutoutLeft", cutoutLeft);
        result.put("cutoutRight", cutoutRight);

        // State
        result.put("isEdgeToEdgeEnabled", isEdgeToEdgeEnabled);
        result.put("isSafeAreaEnabled", isSafeAreaEnabled);
        result.put("isStatusBarVisible", isStatusBarVisible);
        result.put("isNavigationBarVisible", isNavigationBarVisible);

        // Color scheme
        result.put("colorScheme", currentColorScheme);

        call.resolve(result);
    }

    /**
     * Get the current system color scheme (dark/light mode).
     *
     * Returns:
     * - colorScheme: 'light' or 'dark'
     *
     * @param call Plugin call
     */
    @PluginMethod
    public void getColorScheme(PluginCall call) {
        JSObject result = new JSObject();
        result.put("colorScheme", currentColorScheme);
        call.resolve(result);
    }

    // ============================================
    // PRIVATE HELPER METHODS
    // ============================================

    private Window getWindow() {
        return getActivity().getWindow();
    }

    private WindowInsetsControllerCompat getInsetsController(Window window) {
        return WindowCompat.getInsetsController(window, window.getDecorView());
    }

    private void runOnUI(Runnable action) {
        getActivity().runOnUiThread(action);
    }

    private void configureEdgeToEdge(Window window, boolean enabled) {
        isEdgeToEdgeEnabled = enabled;

        if (enabled) {
            // Enable edge-to-edge layout
            WindowCompat.setDecorFitsSystemWindows(window, false);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);

            // Disable contrast enforcement (Android 10+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                window.setStatusBarContrastEnforced(false);
                window.setNavigationBarContrastEnforced(false);
            }

            // Make system bars transparent
            window.setStatusBarColor(Color.TRANSPARENT);
            window.setNavigationBarColor(Color.TRANSPARENT);

            // Setup overlays and insets
            setupOverlayViews(window);
            setupInsetsListener(window);
        } else {
            // Disable edge-to-edge
            isSafeAreaEnabled = true;
            WindowCompat.setDecorFitsSystemWindows(window, true);

            // Clean up
            removeOverlayViews(window);
            removeInsetsListener(window);

            // Apply colors via standard APIs
            applyStandardBarColors(window);
        }
    }

    private void parseAndStoreColors(
        String contentBg,
        String statusBarBg,
        String navigationBarBg,
        String navigationBarLeftBg,
        String navigationBarRightBg,
        String cutoutBg
    ) {
        // Parse all colors first
        Integer parsedContentBg = isValidColor(contentBg) ? Color.parseColor(contentBg) : null;
        Integer parsedStatusBarBg = isValidColor(statusBarBg) ? Color.parseColor(statusBarBg) : null;
        Integer parsedNavBarBg = isValidColor(navigationBarBg) ? Color.parseColor(navigationBarBg) : null;
        Integer parsedNavBarLeftBg = isValidColor(navigationBarLeftBg) ? Color.parseColor(navigationBarLeftBg) : null;
        Integer parsedNavBarRightBg = isValidColor(navigationBarRightBg) ? Color.parseColor(navigationBarRightBg) : null;
        Integer parsedCutoutBg = isValidColor(cutoutBg) ? Color.parseColor(cutoutBg) : null;

        // Update content background if provided
        if (parsedContentBg != null) {
            contentBackgroundColor = parsedContentBg;
        }

        // Status bar: use provided value, or cascade from content
        if (parsedStatusBarBg != null) {
            statusBarBackgroundColor = parsedStatusBarBg;
        } else if (parsedContentBg != null) {
            statusBarBackgroundColor = parsedContentBg;
        }

        // Navigation bar (bottom): use provided, or cascade from left/right -> content
        if (parsedNavBarBg != null) {
            navigationBarBackgroundColor = parsedNavBarBg;
        } else if (parsedNavBarLeftBg != null) {
            navigationBarBackgroundColor = parsedNavBarLeftBg;
        } else if (parsedNavBarRightBg != null) {
            navigationBarBackgroundColor = parsedNavBarRightBg;
        } else if (parsedContentBg != null) {
            navigationBarBackgroundColor = parsedContentBg;
        }

        // Navigation bar left: use provided, or cascade from right -> navBar -> content
        if (parsedNavBarLeftBg != null) {
            navigationBarLeftBackgroundColor = parsedNavBarLeftBg;
        } else if (parsedNavBarRightBg != null) {
            navigationBarLeftBackgroundColor = parsedNavBarRightBg;
        } else if (parsedNavBarBg != null) {
            navigationBarLeftBackgroundColor = parsedNavBarBg;
        } else if (parsedContentBg != null) {
            navigationBarLeftBackgroundColor = parsedContentBg;
        }

        // Navigation bar right: use provided, or cascade from left -> navBar -> content
        if (parsedNavBarRightBg != null) {
            navigationBarRightBackgroundColor = parsedNavBarRightBg;
        } else if (parsedNavBarLeftBg != null) {
            navigationBarRightBackgroundColor = parsedNavBarLeftBg;
        } else if (parsedNavBarBg != null) {
            navigationBarRightBackgroundColor = parsedNavBarBg;
        } else if (parsedContentBg != null) {
            navigationBarRightBackgroundColor = parsedContentBg;
        }

        // Cutout: use provided, or cascade from status bar -> content
        if (parsedCutoutBg != null) {
            cutoutBackgroundColor = parsedCutoutBg;
        } else if (parsedStatusBarBg != null) {
            cutoutBackgroundColor = parsedStatusBarBg;
        } else if (parsedContentBg != null) {
            cutoutBackgroundColor = parsedContentBg;
        }
    }

    private void applyBackgroundColors(Window window) {
        // Set main window/content background
        if (contentBackgroundColor != null) {
            window.getDecorView().setBackgroundColor(contentBackgroundColor);
        }

        if (isEdgeToEdgeEnabled) {
            // Update overlay views with colors
            updateOverlayColors();
            updateOverlaySizes(window);
        } else {
            // Use standard APIs
            applyStandardBarColors(window);
        }
    }

    private void applyStandardBarColors(Window window) {
        if (statusBarBackgroundColor != null) {
            window.setStatusBarColor(statusBarBackgroundColor);
        }
        if (navigationBarBackgroundColor != null) {
            window.setNavigationBarColor(navigationBarBackgroundColor);
        }
    }

    private void applyBarStyles(Window window, String statusBarStyle, String navigationBarStyle) {
        WindowInsetsControllerCompat controller = getInsetsController(window);

        if (statusBarStyle != null) {
            // 'light' = dark icons (for light backgrounds)
            // 'dark' = light icons (for dark backgrounds)
            controller.setAppearanceLightStatusBars("light".equalsIgnoreCase(statusBarStyle));
        }

        if (navigationBarStyle != null) {
            controller.setAppearanceLightNavigationBars("light".equalsIgnoreCase(navigationBarStyle));
        }
    }

    private void setBarVisibility(Window window, boolean isStatusBar, boolean visible) {
        WindowInsetsControllerCompat controller = getInsetsController(window);
        int type = isStatusBar ? WindowInsetsCompat.Type.statusBars() : WindowInsetsCompat.Type.navigationBars();

        if (visible) {
            controller.show(type);
        } else {
            controller.hide(type);
            controller.setSystemBarsBehavior(WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
        }
    }

    private boolean isValidColor(String color) {
        return color != null && !color.isEmpty();
    }

    // ============================================
    // OVERLAY VIEW MANAGEMENT
    // ============================================

    private void setupOverlayViews(Window window) {
        ViewGroup decorView = (ViewGroup) window.getDecorView();

        // Create overlay views
        statusBarOverlay = createOverlayView(STATUS_BAR_OVERLAY_ID);
        navBarBottomOverlay = createOverlayView(NAV_BAR_BOTTOM_OVERLAY_ID);
        navBarLeftOverlay = createOverlayView(NAV_BAR_LEFT_OVERLAY_ID);
        navBarRightOverlay = createOverlayView(NAV_BAR_RIGHT_OVERLAY_ID);

        // Remove any existing overlays
        removeViewById(decorView, STATUS_BAR_OVERLAY_ID);
        removeViewById(decorView, NAV_BAR_BOTTOM_OVERLAY_ID);
        removeViewById(decorView, NAV_BAR_LEFT_OVERLAY_ID);
        removeViewById(decorView, NAV_BAR_RIGHT_OVERLAY_ID);

        // Add overlays to decor view
        decorView.addView(statusBarOverlay);
        decorView.addView(navBarBottomOverlay);
        decorView.addView(navBarLeftOverlay);
        decorView.addView(navBarRightOverlay);
    }

    private View createOverlayView(int id) {
        View view = new View(getContext());
        view.setId(id);
        view.setBackgroundColor(Color.TRANSPARENT);
        return view;
    }

    private void removeOverlayViews(Window window) {
        ViewGroup decorView = (ViewGroup) window.getDecorView();

        removeViewById(decorView, STATUS_BAR_OVERLAY_ID);
        removeViewById(decorView, NAV_BAR_BOTTOM_OVERLAY_ID);
        removeViewById(decorView, NAV_BAR_LEFT_OVERLAY_ID);
        removeViewById(decorView, NAV_BAR_RIGHT_OVERLAY_ID);

        statusBarOverlay = null;
        navBarBottomOverlay = null;
        navBarLeftOverlay = null;
        navBarRightOverlay = null;
    }

    private void removeViewById(ViewGroup parent, int viewId) {
        View view = parent.findViewById(viewId);
        if (view != null) {
            parent.removeView(view);
        }
    }

    private void updateOverlayColors() {
        int effectiveCutoutColor = cutoutBackgroundColor != null
            ? cutoutBackgroundColor
            : (contentBackgroundColor != null ? contentBackgroundColor : Color.TRANSPARENT);

        boolean hasLeftCutout = cutoutLeft > 0;
        boolean hasRightCutout = cutoutRight > 0;

        if (statusBarOverlay != null) {
            statusBarOverlay.setBackgroundColor(statusBarBackgroundColor != null ? statusBarBackgroundColor : Color.TRANSPARENT);
        }

        if (navBarBottomOverlay != null) {
            navBarBottomOverlay.setBackgroundColor(navigationBarBackgroundColor != null ? navigationBarBackgroundColor : Color.TRANSPARENT);
        }

        // Left bar: use cutout color if there's a cutout, otherwise use the left-specific color
        if (navBarLeftOverlay != null) {
            int leftColor;
            if (hasLeftCutout) {
                leftColor = effectiveCutoutColor;
            } else if (navigationBarLeftBackgroundColor != null) {
                leftColor = navigationBarLeftBackgroundColor;
            } else if (navigationBarBackgroundColor != null) {
                leftColor = navigationBarBackgroundColor;
            } else {
                leftColor = Color.TRANSPARENT;
            }
            navBarLeftOverlay.setBackgroundColor(leftColor);
        }

        // Right bar: use cutout color if there's a cutout, otherwise use the right-specific color
        if (navBarRightOverlay != null) {
            int rightColor;
            if (hasRightCutout) {
                rightColor = effectiveCutoutColor;
            } else if (navigationBarRightBackgroundColor != null) {
                rightColor = navigationBarRightBackgroundColor;
            } else if (navigationBarBackgroundColor != null) {
                rightColor = navigationBarBackgroundColor;
            } else {
                rightColor = Color.TRANSPARENT;
            }
            navBarRightOverlay.setBackgroundColor(rightColor);
        }
    }

    private void updateOverlaySizes(Window window) {
        setOverlayLayout(statusBarOverlay, FrameLayout.LayoutParams.MATCH_PARENT, statusBarHeight, Gravity.TOP);
        setOverlayLayout(navBarBottomOverlay, FrameLayout.LayoutParams.MATCH_PARENT, navigationBarHeight, Gravity.BOTTOM);
        setOverlayLayout(navBarLeftOverlay, leftInset, FrameLayout.LayoutParams.MATCH_PARENT, Gravity.LEFT);
        setOverlayLayout(navBarRightOverlay, rightInset, FrameLayout.LayoutParams.MATCH_PARENT, Gravity.RIGHT);

        updateOverlayColors();
    }

    private void setOverlayLayout(View view, int width, int height, int gravity) {
        if (view == null) return;

        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(width, height);
        params.gravity = gravity;
        view.setLayoutParams(params);
    }

    // ============================================
    // INSETS HANDLING
    // ============================================

    private void setupInsetsListener(Window window) {
        View contentView = window.findViewById(android.R.id.content);

        ViewCompat.setOnApplyWindowInsetsListener(
            contentView,
            (view, insets) -> {
                Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars() | WindowInsetsCompat.Type.displayCutout());
                Insets cutoutInsets = insets.getInsets(WindowInsetsCompat.Type.displayCutout());

                // Store inset values
                statusBarHeight = systemBars.top;
                navigationBarHeight = systemBars.bottom;
                leftInset = systemBars.left;
                rightInset = systemBars.right;

                // Track cutout separately
                cutoutTop = cutoutInsets.top;
                cutoutLeft = cutoutInsets.left;
                cutoutRight = cutoutInsets.right;

                // Update content padding and overlays
                updateContentPadding(window);
                updateOverlaySizes(window);

                return WindowInsetsCompat.CONSUMED;
            }
        );

        ViewCompat.requestApplyInsets(contentView);
    }

    private void removeInsetsListener(Window window) {
        View contentView = window.findViewById(android.R.id.content);
        ViewCompat.setOnApplyWindowInsetsListener(contentView, null);
        contentView.setPadding(0, 0, 0, 0);
    }

    private void updateContentPadding(Window window) {
        View contentView = window.findViewById(android.R.id.content);

        if (isSafeAreaEnabled) {
            contentView.setPadding(leftInset, statusBarHeight, rightInset, navigationBarHeight);
        } else {
            contentView.setPadding(0, 0, 0, 0);
        }
    }

    // ============================================
    // COLOR SCHEME (DARK MODE) HELPERS
    // ============================================

    /**
     * Get the current system color scheme.
     *
     * @return "dark" or "light"
     */
    private String getSystemColorScheme() {
        int nightModeFlags = getContext().getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK;

        switch (nightModeFlags) {
            case Configuration.UI_MODE_NIGHT_YES:
                return "dark";
            case Configuration.UI_MODE_NIGHT_NO:
            default:
                return "light";
        }
    }

    /**
     * Notify JavaScript listeners of a color scheme change.
     *
     * @param colorScheme The new color scheme ("dark" or "light")
     */
    private void notifyColorSchemeChanged(String colorScheme) {
        JSObject data = new JSObject();
        data.put("colorScheme", colorScheme);
        notifyListeners(EVENT_COLOR_SCHEME_CHANGED, data);
    }
}
