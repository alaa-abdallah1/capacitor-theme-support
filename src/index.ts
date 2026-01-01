import { registerPlugin } from '@capacitor/core';

import type { SystemUIPlugin } from './definitions';

/**
 * SystemUI - Capacitor plugin for native system UI control
 *
 * Provides comprehensive control over the system UI on Android and iOS,
 * including status bar, navigation bar, and edge-to-edge display mode.
 *
 * @example
 * ```typescript
 * import { SystemUI } from '@aspect/capacitor-theme-support';
 *
 * // Configure everything at once
 * await SystemUI.configure({
 *   edgeToEdge: true,
 *   statusBarStyle: 'light',
 *   contentBackgroundColor: '#1a1a2e'
 * });
 * ```
 */
const SystemUI = registerPlugin<SystemUIPlugin>('SystemUI', {
  web: () => import('./web').then(m => new m.SystemUIWeb()),
});

export * from './definitions';
export { SystemUI };
