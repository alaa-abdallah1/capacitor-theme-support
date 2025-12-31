import { registerPlugin } from '@capacitor/core';

import type { NativeThemePlugin } from './definitions';

const NativeTheme = registerPlugin<NativeThemePlugin>('NativeTheme', {
  web: () => import('./web').then(m => new m.NativeThemeWeb()),
});

export * from './definitions';
export { NativeTheme };
