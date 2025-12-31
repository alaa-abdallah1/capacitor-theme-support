import { WebPlugin } from '@capacitor/core';

import type { NativeThemePlugin, NativeThemeOptions } from './definitions';

export class NativeThemeWeb extends WebPlugin implements NativeThemePlugin {
  async enableEdgeToEdge(): Promise<void> {
    console.warn('NativeTheme: enableEdgeToEdge is not implemented on web.');
  }

  async setAppTheme(options: NativeThemeOptions): Promise<void> {
    console.log('NativeTheme: setAppTheme', options);
    if (options.windowBackgroundColor) {
      document.body.style.backgroundColor = options.windowBackgroundColor;
    }
  }
}
