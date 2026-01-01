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
} from './definitions';

/**
 * Web implementation of the SystemUI plugin.
 *
 * Provides basic fallback functionality for web browsers.
 * Most features are no-ops since web browsers don't have native system bars.
 */
export class SystemUIWeb extends WebPlugin implements SystemUIPlugin {
  private contentBackgroundColor: string | null = null;
  private isEdgeToEdgeEnabled: boolean = false;

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
   * Get system UI information (web fallback).
   * Returns zero values for all insets since web has no system bars.
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
