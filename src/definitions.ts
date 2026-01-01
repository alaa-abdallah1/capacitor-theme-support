/**
 * SystemUI - Capacitor plugin for native system UI control
 *
 * This plugin provides comprehensive control over the system UI on Android and iOS,
 * including status bar, navigation bar, and edge-to-edge display mode.
 *
 * @module @aspect/capacitor-theme-support
 */

/**
 * Available bar styles for status bar and navigation bar icons/content.
 *
 * - `'light'` - Light icons/content on dark background
 * - `'dark'` - Dark icons/content on light background
 */
export type BarStyle = 'light' | 'dark';

/**
 * Configuration options for the entire system UI.
 * Use with the `configure()` method for comprehensive setup in a single call.
 */
export interface SystemUIConfiguration {
  /**
   * Enable edge-to-edge display mode.
   * When enabled, content extends behind the status bar and navigation bar.
   * @default false
   */
  edgeToEdge?: boolean;

  /**
   * Show or hide the status bar.
   * @default true
   */
  statusBarVisible?: boolean;

  /**
   * Show or hide the navigation bar (Android only).
   * When hidden, user can swipe from bottom edge to temporarily reveal.
   * @default true
   */
  navigationBarVisible?: boolean;

  /**
   * Style of the status bar icons/content.
   * - `'light'` - Light icons (use on dark backgrounds)
   * - `'dark'` - Dark icons (use on light backgrounds)
   */
  statusBarStyle?: BarStyle;

  /**
   * Style of the navigation bar icons/buttons (Android only).
   * - `'light'` - Light icons (use on dark backgrounds)
   * - `'dark'` - Dark icons (use on light backgrounds)
   */
  navigationBarStyle?: BarStyle;

  /**
   * Background color for the main content area.
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   *
   * If only this color is provided, it will be used for status bar,
   * navigation bar, and cutout areas as well.
   */
  contentBackgroundColor?: string;

  /**
   * Background color for the status bar area.
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   *
   * If not provided, defaults to `contentBackgroundColor` value.
   */
  statusBarBackgroundColor?: string;

  /**
   * Background color for the navigation bar area.
   * On iOS, this affects the home indicator area.
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   *
   * If not provided, defaults to `contentBackgroundColor` value.
   */
  navigationBarBackgroundColor?: string;

  /**
   * Background color for the display cutout (notch/Dynamic Island) area.
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   *
   * If not provided, defaults to `contentBackgroundColor` value.
   */
  cutoutBackgroundColor?: string;
}

/**
 * Options for setting background colors of UI areas.
 */
export interface BackgroundColorsOptions {
  /**
   * Background color for the main content area.
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   */
  contentBackgroundColor?: string;

  /**
   * Background color for the status bar area.
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   */
  statusBarBackgroundColor?: string;

  /**
   * Background color for the navigation bar area.
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
   */
  navigationBarBackgroundColor?: string;

  /**
   * Background color for the display cutout area.
   * Accepts hex color strings: `'#RRGGBB'` or `'#RRGGBBAA'`
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
   * On Android, when hidden, user can swipe from bottom to temporarily reveal.
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
   * When enabled, content extends behind system bars.
   */
  enabled: boolean;
}

/**
 * System UI information returned by `getInfo()`.
 */
export interface SystemUIInfo {
  /**
   * Height of the status bar in pixels.
   */
  statusBarHeight: number;

  /**
   * Height of the navigation bar in pixels.
   * On iOS, this represents the home indicator area height.
   */
  navigationBarHeight: number;

  /**
   * Left system inset in pixels.
   * Used in landscape mode when navigation bar is on the left.
   */
  leftInset: number;

  /**
   * Right system inset in pixels.
   * Used in landscape mode when navigation bar is on the right.
   */
  rightInset: number;

  /**
   * Height of the display cutout at the top in pixels.
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
}

/**
 * SystemUI plugin interface.
 *
 * Provides methods for controlling the native system UI including status bar,
 * navigation bar, and edge-to-edge display mode.
 *
 * @example
 * ```typescript
 * import { SystemUI } from '@aspect/capacitor-theme-support';
 *
 * // Configure everything at once
 * await SystemUI.configure({
 *   edgeToEdge: true,
 *   statusBarStyle: 'light',
 *   contentBackgroundColor: '#1a1a2e',
 *   statusBarBackgroundColor: '#16213e',
 *   navigationBarBackgroundColor: '#0f3460'
 * });
 *
 * // Or configure individual aspects
 * await SystemUI.setEdgeToEdge({ enabled: true });
 * await SystemUI.setBackgroundColors({
 *   contentBackgroundColor: '#ffffff'
 * });
 * ```
 */
export interface SystemUIPlugin {
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
   *   statusBarStyle: 'light',
   *   navigationBarStyle: 'light',
   *   contentBackgroundColor: '#121212',
   *   statusBarBackgroundColor: '#121212',
   *   navigationBarBackgroundColor: '#121212'
   * });
   * ```
   */
  configure(options: SystemUIConfiguration): Promise<void>;

  /**
   * Set background colors for different UI areas.
   *
   * Colors cascade from content to other areas if not specified:
   * - If only `contentBackgroundColor` is set, it applies to all areas
   * - If `statusBarBackgroundColor` is not set, uses `contentBackgroundColor`
   * - If `navigationBarBackgroundColor` is not set, uses `contentBackgroundColor`
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
   * // Set different colors for each area
   * await SystemUI.setBackgroundColors({
   *   contentBackgroundColor: '#ffffff',
   *   statusBarBackgroundColor: '#f5f5f5',
   *   navigationBarBackgroundColor: '#e0e0e0'
   * });
   * ```
   */
  setBackgroundColors(options: BackgroundColorsOptions): Promise<void>;

  /**
   * Set the style (icon/content color) for system bars.
   *
   * Use `'light'` style when your bar has a dark background.
   * Use `'dark'` style when your bar has a light background.
   *
   * @param options - Bar style options
   * @returns Promise that resolves when styles are applied
   *
   * @example
   * ```typescript
   * // Dark theme: light icons on dark background
   * await SystemUI.setBarStyles({
   *   statusBarStyle: 'light',
   *   navigationBarStyle: 'light'
   * });
   *
   * // Light theme: dark icons on light background
   * await SystemUI.setBarStyles({
   *   statusBarStyle: 'dark',
   *   navigationBarStyle: 'dark'
   * });
   * ```
   */
  setBarStyles(options: BarStylesOptions): Promise<void>;

  /**
   * Show or hide the status bar.
   *
   * When hidden, content extends into the status bar area.
   *
   * @param options - Visibility options
   * @returns Promise that resolves when visibility is changed
   *
   * @example
   * ```typescript
   * // Hide status bar
   * await SystemUI.setStatusBarVisibility({ visible: false });
   *
   * // Show status bar
   * await SystemUI.setStatusBarVisibility({ visible: true });
   * ```
   */
  setStatusBarVisibility(options: StatusBarVisibilityOptions): Promise<void>;

  /**
   * Show or hide the navigation bar (Android only).
   *
   * When hidden on Android, the user can swipe from the bottom edge
   * to temporarily reveal the navigation bar.
   *
   * On iOS, this method has no effect as there's no equivalent
   * navigation bar - the home indicator is controlled by the system.
   *
   * @param options - Visibility options
   * @returns Promise that resolves when visibility is changed
   *
   * @example
   * ```typescript
   * // Hide navigation bar (Android only)
   * await SystemUI.setNavigationBarVisibility({ visible: false });
   * ```
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
   *
   * @example
   * ```typescript
   * // Enable edge-to-edge mode
   * await SystemUI.setEdgeToEdge({ enabled: true });
   * ```
   */
  setEdgeToEdge(options: EdgeToEdgeOptions): Promise<void>;

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
   * console.log('Is edge-to-edge:', info.isEdgeToEdgeEnabled);
   * ```
   */
  getInfo(): Promise<SystemUIInfo>;
}
