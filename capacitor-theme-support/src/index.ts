import { registerPlugin } from '@capacitor/core';

import type { SystemUIPlugin } from './definitions';

/**
 * SystemUI - Capacitor plugin for native system UI control
 *
 * Provides comprehensive control over the system UI on Android and iOS:
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
 *   contentBackgroundColor: '#1a1a2e'
 * });
 *
 * // Listen for dark mode changes
 * SystemUI.addListener('colorSchemeChanged', (event) => {
 *   if (event.colorScheme === ColorScheme.Dark) {
 *     applyDarkTheme();
 *   }
 * });
 * ```
 */
const SystemUI = registerPlugin<SystemUIPlugin>('SystemUI', {
  web: () => import('./web').then(m => new m.SystemUIWeb()),
});

export * from './definitions';
export { SystemUI };
