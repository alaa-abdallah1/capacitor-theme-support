import { WebPlugin } from '@capacitor/core';

import type {
  SystemUIPlugin,
  SystemUIConfiguration,
  BackgroundColorsOptions,
  BarStylesOptions,
  StatusBarVisibilityOptions,
  NavigationBarVisibilityOptions,
  EdgeToEdgeOptions,
  SystemUIInfo,
  ColorSchemeResult,
  ColorSchemeChangeEvent
} from './definitions';
import {
  ColorScheme
} from './definitions';

/**
 * Web implementation of the SystemUI plugin.
 *
 * Provides fallback functionality for web browsers:
 * - Color scheme detection using CSS media queries
 * - Background color application to document body
 * - Theme-color meta tag updates for mobile browsers
 */
export class SystemUIWeb extends WebPlugin implements SystemUIPlugin {
  private contentBackgroundColor: string | null = null;
  private isEdgeToEdgeEnabled = false;
  private colorSchemeMediaQuery: MediaQueryList | null = null;

  constructor() {
    super();
    this.setupColorSchemeListener();
  }

  /**
   * Setup listener for CSS prefers-color-scheme changes.
   */
  private setupColorSchemeListener(): void {
    if (typeof window !== 'undefined' && window.matchMedia) {
      this.colorSchemeMediaQuery = window.matchMedia(
        '(prefers-color-scheme: dark)',
      );

      const handler = (event: MediaQueryListEvent) => {
        const colorScheme = event.matches ? ColorScheme.Dark : ColorScheme.Light;
        this.notifyListeners('colorSchemeChanged', {
          colorScheme,
        } as ColorSchemeChangeEvent);
      };

      // Modern browsers
      if (this.colorSchemeMediaQuery.addEventListener) {
        this.colorSchemeMediaQuery.addEventListener('change', handler);
      } else {
        // Fallback for older browsers
        this.colorSchemeMediaQuery.addListener(handler);
      }
    }
  }

  /**
   * Get the current color scheme from CSS media query.
   */
  private getCurrentColorScheme(): ColorScheme {
    if (typeof window !== 'undefined' && window.matchMedia) {
      const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      return isDark ? ColorScheme.Dark : ColorScheme.Light;
    }
    return ColorScheme.Light;
  }

  /**
   * Configure the system UI (web fallback).
   * Only applies background color to the document body.
   */
  async configure(options: SystemUIConfiguration): Promise<void> {
    console.log('SystemUI: configure', options);

    if (options.edgeToEdge !== undefined) {
      this.isEdgeToEdgeEnabled = options.edgeToEdge;
    }

    if (options.contentBackgroundColor) {
      this.contentBackgroundColor = options.contentBackgroundColor;
      document.body.style.backgroundColor = options.contentBackgroundColor;
    }

    // Update meta theme-color for mobile browsers
    this.updateThemeColorMeta(
      options.statusBarBackgroundColor ||
        options.contentBackgroundColor ||
        null,
    );
  }

  /**
   * Set background colors (web fallback).
   * Applies content background to document body.
   */
  async setBackgroundColors(options: BackgroundColorsOptions): Promise<void> {
    console.log('SystemUI: setBackgroundColors', options);

    if (options.contentBackgroundColor) {
      this.contentBackgroundColor = options.contentBackgroundColor;
      document.body.style.backgroundColor = options.contentBackgroundColor;
    }

    this.updateThemeColorMeta(
      options.statusBarBackgroundColor ||
        options.contentBackgroundColor ||
        null,
    );
  }

  /**
   * Set bar styles (web fallback).
   * No-op on web as there are no native system bars.
   */
  async setBarStyles(options: BarStylesOptions): Promise<void> {
    console.log('SystemUI: setBarStyles', options);
    // No-op on web
  }

  /**
   * Set status bar visibility (web fallback).
   * No-op on web as there is no native status bar.
   */
  async setStatusBarVisibility(
    options: StatusBarVisibilityOptions,
  ): Promise<void> {
    console.log('SystemUI: setStatusBarVisibility', options);
    // No-op on web
  }

  /**
   * Set navigation bar visibility (web fallback).
   * No-op on web as there is no native navigation bar.
   */
  async setNavigationBarVisibility(
    options: NavigationBarVisibilityOptions,
  ): Promise<void> {
    console.log('SystemUI: setNavigationBarVisibility', options);
    // No-op on web
  }

  /**
   * Enable or disable edge-to-edge mode (web fallback).
   * Stores the state but has no visual effect.
   */
  async setEdgeToEdge(options: EdgeToEdgeOptions): Promise<void> {
    console.log('SystemUI: setEdgeToEdge', options);
    this.isEdgeToEdgeEnabled = options.enabled;
  }

  /**
   * Get the current system color scheme (web fallback).
   * Uses CSS prefers-color-scheme media query.
   */
  async getColorScheme(): Promise<ColorSchemeResult> {
    return {
      colorScheme: this.getCurrentColorScheme(),
    };
  }

  /**
   * Get system UI information (web fallback).
   * Returns zero values for insets, uses CSS env() for safe areas.
   */
  async getInfo(): Promise<SystemUIInfo> {
    return {
      statusBarHeight: 0,
      navigationBarHeight: 0,
      leftInset: 0,
      rightInset: 0,
      cutoutTop: 0,
      cutoutLeft: 0,
      cutoutRight: 0,
      isEdgeToEdgeEnabled: this.isEdgeToEdgeEnabled,
      isSafeAreaEnabled: true,
      isStatusBarVisible: true,
      isNavigationBarVisible: true,
      colorScheme: this.getCurrentColorScheme(),
    };
  }

  /**
   * Updates the theme-color meta tag for mobile browsers.
   * This affects the browser's UI color in mobile Chrome, Safari, etc.
   */
  private updateThemeColorMeta(color: string | null): void {
    if (!color) return;

    let metaThemeColor = document.querySelector('meta[name="theme-color"]');

    if (!metaThemeColor) {
      metaThemeColor = document.createElement('meta');
      metaThemeColor.setAttribute('name', 'theme-color');
      document.head.appendChild(metaThemeColor);
    }

    metaThemeColor.setAttribute('content', color);
  }
}
