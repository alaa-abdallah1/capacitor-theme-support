export interface NativeThemeOptions {
  /**
   * The background color of the window (visible in overscroll/notch areas).
   * Hex color string (e.g. #FFFFFF).
   */
  windowBackgroundColor?: string;

  /**
   * The background color of the status bar.
   * Hex color string (e.g. #FFFFFF) or #00000000 for transparent.
   */
  statusBarColor?: string;

  /**
   * The background color of the navigation bar.
   * Hex color string (e.g. #FFFFFF) or #00000000 for transparent.
   */
  navigationBarColor?: string;

  /**
   * Whether the status bar should be light (Dark Icons).
   * true = Dark Icons (Light Background)
   * false = Light Icons (Dark Background)
   */
  isStatusBarLight?: boolean;

  /**
   * Whether the navigation bar should be light (Dark Icons).
   * true = Dark Icons (Light Background)
   * false = Light Icons (Dark Background)
   */
  isNavigationBarLight?: boolean;
}

export interface NativeThemePlugin {
  /**
   * Enables Edge-to-Edge mode for the Android application.
   * This allows the app content to draw behind the system bars.
   */
  enableEdgeToEdge(): Promise<void>;

  /**
   * Sets the application theme, including window background, system bar colors, and icon styles.
   * @param options Theme configuration options
   */
  setAppTheme(options: NativeThemeOptions): Promise<void>;
}
