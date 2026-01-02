/**
 * SystemUI - Capacitor plugin for native system UI control
 *
 * This plugin provides comprehensive control over the system UI on Android and iOS,
 * including status bar, navigation bar, edge-to-edge display mode, and color scheme detection.
 *
 * Features:
 * - Edge-to-edge display mode
 * - Status bar and navigation bar styling
 * - System color scheme (dark/light mode) detection
 * - Landscape orientation support with separate controls
 * - Display cutout (notch/Dynamic Island) handling
 *
 * @module capacitor-theme-support
 * @version 1.0.0
 */

import type { PluginListenerHandle } from '@capacitor/core';

// ============================================
// ENUMS
// ============================================

/**
 * Available styles for system bar icons and content.
 *
 * Use this enum to control the appearance of icons in the status bar and navigation bar.
 *
 * @example
 * ```typescript
 * import { SystemUI, BarStyle } from 'capacitor-theme-support';
 *
 * await SystemUI.configure({
 *   statusBarStyle: BarStyle.Light,
 *   navigationBarStyle: BarStyle.Dark
 * });
 * ```
 */
export enum BarStyle {
  /**
   * Light icons/content - use on DARK backgrounds.
   * The icons will be white/light colored for visibility on dark surfaces.
   */
  Light = 'light',

  /**
   * Dark icons/content - use on LIGHT backgrounds.
   * The icons will be black/dark colored for visibility on light surfaces.
   */
  Dark = 'dark',
}

/**
 * System color scheme (appearance mode).
 *
 * Represents the current system-wide color scheme preference.
 *
 * @example
 * ```typescript
 * import { SystemUI, ColorScheme } from 'capacitor-theme-support';
 *
 * const { colorScheme } = await SystemUI.getColorScheme();
 * if (colorScheme === ColorScheme.Dark) {
 *   // Apply dark theme
 * }
 * ```
 */
export enum ColorScheme {
  /**
   * Light color scheme (light mode).
   * System prefers light backgrounds with dark text.
   */
  Light = 'light',

  /**
   * Dark color scheme (dark mode).
   * System prefers dark backgrounds with light text.
   */
  Dark = 'dark',
}

// ============================================
// CONFIGURATION INTERFACES
// ============================================

/**
 * Configuration options for the entire system UI.
 *
 * Use with the `configure()` method for comprehensive setup in a single call.
 * All properties are optional - only provided values will be applied.
 */
export interface SystemUIConfiguration {
  // ---- Display Mode ----

  /**
   * Enable edge-to-edge display mode.
   *
   * When enabled, content extends behind the status bar and navigation bar,
   * giving you full control over the entire screen area.
   *
   * @default false
   */
  edgeToEdge?: boolean;

  // ---- Visibility ----

  /**
   * Show or hide the status bar.
   * @default true
   */
  statusBarVisible?: boolean;

  /**
   * Show or hide the navigation bar (Android only).
   *
   * When hidden, user can swipe from bottom/side edge to temporarily reveal it.
   * On iOS, this has no effect as the home indicator is system-controlled.
   *
   * @default true
   */
  navigationBarVisible?: boolean;

  // ---- Bar Styles (Icon Colors) ----

  /**
   * Style of the status bar icons/content.
   *
   * - `BarStyle.Light` - Light icons (use on DARK backgrounds)
   * - `BarStyle.Dark` - Dark icons (use on LIGHT backgrounds)
   */
  statusBarStyle?: BarStyle;

  /**
   * Style of the navigation bar icons/buttons (Android only).
   *
   * - `BarStyle.Light` - Light icons (use on DARK backgrounds)
   * - `BarStyle.Dark` - Dark icons (use on LIGHT backgrounds)
   */
  navigationBarStyle?: BarStyle;

  // ---- Background Colors (Portrait) ----

  /**
   * Background color for the main content area.
   *
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   *
   * If this is the only color provided, it will cascade to all other areas
   * (status bar, navigation bar, cutout, and landscape bars).
   */
  contentBackgroundColor?: string;

  /**
   * Background color for the status bar area (top of screen).
   *
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   *
   * If not provided, defaults to `contentBackgroundColor`.
   */
  statusBarBackgroundColor?: string;

  /**
   * Background color for the navigation bar area (bottom of screen).
   *
   * On iOS, this affects the home indicator area.
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   *
   * If not provided, defaults to `contentBackgroundColor`.
   */
  navigationBarBackgroundColor?: string;

  // ---- Background Colors (Landscape) ----

  /**
   * Background color for the LEFT system bar area in landscape orientation.
   *
   * On Android, the navigation bar may appear on the left in landscape mode.
   * This also covers any left-side display cutout.
   *
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   *
   * Cascade order: `navigationBarRightBackgroundColor` → `navigationBarBackgroundColor` → `contentBackgroundColor`
   */
  navigationBarLeftBackgroundColor?: string;

  /**
   * Background color for the RIGHT system bar area in landscape orientation.
   *
   * On Android, the navigation bar may appear on the right in landscape mode.
   * This also covers any right-side display cutout.
   *
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   *
   * Cascade order: `navigationBarLeftBackgroundColor` → `navigationBarBackgroundColor` → `contentBackgroundColor`
   */
  navigationBarRightBackgroundColor?: string;

  // ---- Display Cutout ----

  /**
   * Background color for the display cutout (notch/Dynamic Island) area.
   *
   * This specifically targets the cutout region, separate from the status bar.
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   *
   * If not provided, defaults to `statusBarBackgroundColor`, then `contentBackgroundColor`.
   */
  cutoutBackgroundColor?: string;
}

/**
 * Options for setting background colors of UI areas.
 */
export interface BackgroundColorsOptions {
  /**
   * Background color for the main content area.
   * This is the base color that cascades to all other areas if not specified.
   */
  contentBackgroundColor?: string;

  /**
   * Background color for the status bar area.
   * Cascade: `contentBackgroundColor`
   */
  statusBarBackgroundColor?: string;

  /**
   * Background color for the navigation bar area (bottom).
   * Cascade: `navigationBarLeftBackgroundColor` → `navigationBarRightBackgroundColor` → `contentBackgroundColor`
   */
  navigationBarBackgroundColor?: string;

  /**
   * Background color for the left system bar (landscape).
   * Cascade: `navigationBarRightBackgroundColor` → `navigationBarBackgroundColor` → `contentBackgroundColor`
   */
  navigationBarLeftBackgroundColor?: string;

  /**
   * Background color for the right system bar (landscape).
   * Cascade: `navigationBarLeftBackgroundColor` → `navigationBarBackgroundColor` → `contentBackgroundColor`
   */
  navigationBarRightBackgroundColor?: string;

  /**
   * Background color for the display cutout area.
   * Cascade: `statusBarBackgroundColor` → `contentBackgroundColor`
   */
  cutoutBackgroundColor?: string;
}

/**
 * Options for setting bar icon/content styles.
 */
export interface BarStylesOptions {
  /**
   * Style of the status bar icons/content.
   */
  statusBarStyle?: BarStyle;

  /**
   * Style of the navigation bar icons/buttons (Android only).
   */
  navigationBarStyle?: BarStyle;
}

/**
 * Options for setting status bar visibility.
 */
export interface StatusBarVisibilityOptions {
  /**
   * Whether the status bar should be visible.
   */
  visible: boolean;
}

/**
 * Options for setting navigation bar visibility.
 */
export interface NavigationBarVisibilityOptions {
  /**
   * Whether the navigation bar should be visible.
   *
   * On Android, when hidden, user can swipe from bottom/side to temporarily reveal.
   * On iOS, this option has no effect.
   */
  visible: boolean;
}

/**
 * Options for setting edge-to-edge mode.
 */
export interface EdgeToEdgeOptions {
  /**
   * Whether edge-to-edge mode should be enabled.
   *
   * When enabled, content extends behind system bars.
   */
  enabled: boolean;
}

// ============================================
// COLOR SCHEME (DARK MODE) INTERFACES
// ============================================

/**
 * Result from `getColorScheme()` containing the current system color scheme.
 */
export interface ColorSchemeResult {
  /**
   * The current system color scheme (light or dark).
   */
  colorScheme: ColorScheme;
}

/**
 * Event data emitted when the system color scheme changes.
 *
 * Listen to this event to react to dark/light mode changes.
 *
 * @example
 * ```typescript
 * SystemUI.addListener('colorSchemeChanged', (event) => {
 *   console.log('Color scheme changed to:', event.colorScheme);
 *   if (event.colorScheme === ColorScheme.Dark) {
 *     applyDarkTheme();
 *   } else {
 *     applyLightTheme();
 *   }
 * });
 * ```
 */
export interface ColorSchemeChangeEvent {
  /**
   * The new color scheme after the change.
   */
  colorScheme: ColorScheme;
}

// ============================================
// SYSTEM INFO INTERFACE
// ============================================

/**
 * System UI information returned by `getInfo()`.
 *
 * Contains inset values (in pixels) and current state of the system UI.
 */
export interface SystemUIInfo {
  // ---- Inset Values (pixels) ----

  /**
   * Height of the status bar in pixels.
   */
  statusBarHeight: number;

  /**
   * Height of the navigation bar in pixels.
   *
   * On iOS, this represents the home indicator area height.
   */
  navigationBarHeight: number;

  /**
   * Left system inset in pixels.
   *
   * Used in landscape mode when navigation bar is on the left,
   * or for left-side display cutouts.
   */
  leftInset: number;

  /**
   * Right system inset in pixels.
   *
   * Used in landscape mode when navigation bar is on the right,
   * or for right-side display cutouts.
   */
  rightInset: number;

  // ---- Display Cutout Values (pixels) ----

  /**
   * Height of the display cutout at the top in pixels.
   *
   * Represents notch, Dynamic Island, or camera cutout height.
   */
  cutoutTop: number;

  /**
   * Width of the display cutout at the left in pixels.
   */
  cutoutLeft: number;

  /**
   * Width of the display cutout at the right in pixels.
   */
  cutoutRight: number;

  // ---- State ----

  /**
   * Whether edge-to-edge mode is currently enabled.
   */
  isEdgeToEdgeEnabled: boolean;

  /**
   * Whether safe area avoidance is enabled.
   */
  isSafeAreaEnabled: boolean;

  /**
   * Whether the status bar is currently visible.
   */
  isStatusBarVisible: boolean;

  /**
   * Whether the navigation bar is currently visible (Android only).
   */
  isNavigationBarVisible: boolean;

  /**
   * Current system color scheme.
   */
  colorScheme: ColorScheme;
}

// ============================================
// PLUGIN INTERFACE
// ============================================

/**
 * SystemUI plugin interface.
 *
 * Provides methods for controlling the native system UI including:
 * - Status bar and navigation bar appearance
 * - Edge-to-edge display mode
 * - System color scheme (dark mode) detection
 * - Landscape orientation support
 *
 * @example
 * ```typescript
 * import { SystemUI, BarStyle, ColorScheme } from 'capacitor-theme-support';
 *
 * // Configure everything at once
 * await SystemUI.configure({
 *   edgeToEdge: true,
 *   statusBarStyle: BarStyle.Light,
 *   contentBackgroundColor: '#1a1a2e',
 *   statusBarBackgroundColor: '#16213e',
 *   navigationBarBackgroundColor: '#0f3460'
 * });
 *
 * // Listen for color scheme changes
 * SystemUI.addListener('colorSchemeChanged', (event) => {
 *   console.log('Theme changed to:', event.colorScheme);
 * });
 *
 * // Get current color scheme
 * const { colorScheme } = await SystemUI.getColorScheme();
 * ```
 */
export interface SystemUIPlugin {
  // ============================================
  // CONFIGURATION METHODS
  // ============================================

  /**
   * Configure the entire system UI in a single call.
   *
   * This is the recommended way to set up the system UI as it allows
   * configuring all aspects at once, reducing potential visual glitches.
   *
   * @param options - Configuration options for the system UI
   * @returns Promise that resolves when configuration is applied
   *
   * @example
   * ```typescript
   * await SystemUI.configure({
   *   edgeToEdge: true,
   *   statusBarVisible: true,
   *   statusBarStyle: BarStyle.Light,
   *   navigationBarStyle: BarStyle.Light,
   *   contentBackgroundColor: '#121212',
   *   statusBarBackgroundColor: '#121212',
   *   navigationBarBackgroundColor: '#121212',
   *   navigationBarLeftBackgroundColor: '#0a0a0a',
   *   navigationBarRightBackgroundColor: '#0a0a0a'
   * });
   * ```
   */
  configure(options: SystemUIConfiguration): Promise<void>;

  /**
   * Set background colors for different UI areas.
   *
   * Colors cascade from content to other areas if not specified:
   * - If only `contentBackgroundColor` is set, it applies to all areas
   * - Other areas default to their parent color if not explicitly set
   *
   * @param options - Background color options
   * @returns Promise that resolves when colors are applied
   *
   * @example
   * ```typescript
   * // Set all areas to the same color
   * await SystemUI.setBackgroundColors({
   *   contentBackgroundColor: '#ffffff'
   * });
   *
   * // Set different colors for portrait and landscape
   * await SystemUI.setBackgroundColors({
   *   contentBackgroundColor: '#ffffff',
   *   statusBarBackgroundColor: '#f5f5f5',
   *   navigationBarBackgroundColor: '#e0e0e0',
   *   navigationBarLeftBackgroundColor: '#d0d0d0',
   *   navigationBarRightBackgroundColor: '#d0d0d0'
   * });
   * ```
   */
  setBackgroundColors(options: BackgroundColorsOptions): Promise<void>;

  /**
   * Set the style (icon/content color) for system bars.
   *
   * Use `BarStyle.Light` when your bar has a DARK background.
   * Use `BarStyle.Dark` when your bar has a LIGHT background.
   *
   * @param options - Bar style options
   * @returns Promise that resolves when styles are applied
   *
   * @example
   * ```typescript
   * // Dark theme: light icons on dark background
   * await SystemUI.setBarStyles({
   *   statusBarStyle: BarStyle.Light,
   *   navigationBarStyle: BarStyle.Light
   * });
   * ```
   */
  setBarStyles(options: BarStylesOptions): Promise<void>;

  // ============================================
  // VISIBILITY METHODS
  // ============================================

  /**
   * Show or hide the status bar.
   *
   * When hidden, content extends into the status bar area.
   *
   * @param options - Visibility options
   * @returns Promise that resolves when visibility is changed
   */
  setStatusBarVisibility(options: StatusBarVisibilityOptions): Promise<void>;

  /**
   * Show or hide the navigation bar (Android only).
   *
   * When hidden on Android, the user can swipe from the bottom/side edge
   * to temporarily reveal the navigation bar.
   *
   * On iOS, this method has no effect as there's no equivalent
   * navigation bar - the home indicator is controlled by the system.
   *
   * @param options - Visibility options
   * @returns Promise that resolves when visibility is changed
   */
  setNavigationBarVisibility(
    options: NavigationBarVisibilityOptions,
  ): Promise<void>;

  /**
   * Enable or disable edge-to-edge display mode.
   *
   * When enabled:
   * - Content extends behind the status bar and navigation bar
   * - You need to handle safe area insets in your app
   * - Use overlay views or CSS env() variables for proper padding
   *
   * When disabled:
   * - System bars take their own space
   * - Content is automatically inset to avoid overlapping
   *
   * @param options - Edge-to-edge options
   * @returns Promise that resolves when mode is changed
   */
  setEdgeToEdge(options: EdgeToEdgeOptions): Promise<void>;

  // ============================================
  // COLOR SCHEME (DARK MODE) METHODS
  // ============================================

  /**
   * Get the current system color scheme (dark/light mode).
   *
   * This returns the system-wide color scheme preference, which corresponds
   * to the CSS `prefers-color-scheme` media query on the web.
   *
   * @returns Promise that resolves with the current color scheme
   *
   * @example
   * ```typescript
   * const { colorScheme } = await SystemUI.getColorScheme();
   *
   * if (colorScheme === ColorScheme.Dark) {
   *   applyDarkTheme();
   * } else {
   *   applyLightTheme();
   * }
   * ```
   */
  getColorScheme(): Promise<ColorSchemeResult>;

  // ============================================
  // INFO METHODS
  // ============================================

  /**
   * Get current system UI information.
   *
   * Returns inset values and current state of the system UI.
   * Useful for calculating proper padding in your app.
   *
   * @returns Promise that resolves with system UI information
   *
   * @example
   * ```typescript
   * const info = await SystemUI.getInfo();
   * console.log('Status bar height:', info.statusBarHeight);
   * console.log('Is dark mode:', info.colorScheme === ColorScheme.Dark);
   * ```
   */
  getInfo(): Promise<SystemUIInfo>;

  // ============================================
  // EVENT LISTENERS
  // ============================================

  /**
   * Add a listener for color scheme (dark mode) changes.
   *
   * This fires whenever the system switches between light and dark mode.
   * Use this to update your app's theme in real-time.
   *
   * @param eventName - The event name: 'colorSchemeChanged'
   * @param listenerFunc - Callback function receiving the new color scheme
   * @returns Promise resolving to a handle for removing the listener
   *
   * @example
   * ```typescript
   * const handle = await SystemUI.addListener('colorSchemeChanged', (event) => {
   *   console.log('Color scheme changed to:', event.colorScheme);
   *
   *   if (event.colorScheme === ColorScheme.Dark) {
   *     document.body.classList.add('dark');
   *   } else {
   *     document.body.classList.remove('dark');
   *   }
   * });
   *
   * // Later, to remove the listener:
   * handle.remove();
   * ```
   */
  addListener(
    eventName: 'colorSchemeChanged',
    listenerFunc: (event: ColorSchemeChangeEvent) => void,
  ): Promise<PluginListenerHandle>;

  /**
   * Remove all listeners for a specific event or all events.
   *
   * @param eventName - Optional event name to remove listeners for
   */
  removeAllListeners(eventName?: 'colorSchemeChanged'): Promise<void>;
}
