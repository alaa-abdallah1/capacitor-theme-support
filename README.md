# 🎨 @payiano/capacitor-theme-support

[![GitHub release](https://img.shields.io/github/v/release/alaa-abdallah1/capacitor-theme.svg)](https://github.com/alaa-abdallah1/capacitor-theme/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue)](LICENSE)
[![NPM Package](https://img.shields.io/npm/v/@payiano/capacitor-theme-support?color=red)](https://www.npmjs.com/package/@payiano/capacitor-theme-support)
[![NPM downloads](https://img.shields.io/npm/dw/@payiano/capacitor-theme-support?color=limegreen)](https://www.npmjs.com/package/@payiano/capacitor-theme-support)

> **Powered by [Payiano Team](https://payiano.com) | [GitHub](https://github.com/payiano)**

A comprehensive **Capacitor plugin** for **native system UI control** on Android and iOS. Take full control of your app's appearance with edge-to-edge display, custom system bar colors, and seamless dark mode support! 🚀

⚡ This plugin solves the **common theming challenges** in hybrid mobile apps by providing direct native control over system UI elements that CSS alone cannot touch.

⚡ With **consistent behavior across Android and iOS**, you can create truly immersive experiences with content extending behind status bars and navigation bars.

⚡ The **smart color cascade system** lets you set one color and have it apply everywhere, or customize each area independently for complete creative freedom.

## ✨ Features

| Feature                       | Description                                                                  |
| ----------------------------- | ---------------------------------------------------------------------------- |
| 📱 **Edge-to-Edge Display**   | Content extends behind system bars for immersive full-screen experiences     |
| 🎨 **Background Colors**      | Independent control of content, status bar, navigation bar, and cutout areas |
| 👁️ **Visibility Control**     | Show/hide status bar and navigation bar programmatically                     |
| 🌗 **Bar Styles**             | Light/dark icon themes that adapt to your app's color scheme                 |
| 📐 **Inset Information**      | Get precise measurements for safe area handling                              |
| 🔄 **Orientation Support**    | Automatic handling of landscape mode and device rotation                     |
| 🌙 **Dark Mode Detection**    | Listen for system color scheme changes in real-time                          |
| 🔲 **Display Cutout Support** | Handle notches, Dynamic Island, and camera cutouts gracefully                |

## 🎯 Why This Plugin?

Hybrid apps built with Capacitor often struggle with:

- ❌ Status bar appearing as a solid block instead of blending with your app
- ❌ Navigation bar not matching your app's theme
- ❌ Inconsistent behavior between Android and iOS
- ❌ Display cutouts (notch/Dynamic Island) showing wrong colors
- ❌ Difficulty implementing true edge-to-edge layouts

**This plugin solves all of these!** ✅

## 📦 Compatibility

| Platform       | Version                            |
| -------------- | ---------------------------------- |
| **Capacitor**  | 6.x, 7.x                           |
| **Android**    | API 21+ (Android 5.0+)             |
| **iOS**        | iOS 13+                            |
| **TypeScript** | Full support with type definitions |

## 🚀 Installation

Install the plugin from [npm](https://www.npmjs.com/package/@payiano/capacitor-theme-support) with your preferred package manager:

```bash
# NPM
npm install @payiano/capacitor-theme-support

# Yarn
yarn add @payiano/capacitor-theme-support

# PNPM
pnpm add @payiano/capacitor-theme-support
```

Then sync your Capacitor project:

```bash
npx cap sync
```

[![NPM](https://nodei.co/npm/@payiano/capacitor-theme-support.png)](https://www.npmjs.com/package/@payiano/capacitor-theme-support)

## 📖 Quick Start

```typescript
import { SystemUI } from '@payiano/capacitor-theme-support';

// Configure everything in one call
await SystemUI.configure({
  edgeToEdge: true,
  statusBarStyle: 'light',
  navigationBarStyle: 'light',
  contentBackgroundColor: '#1a1a2e',
  statusBarBackgroundColor: '#16213e',
  navigationBarBackgroundColor: '#0f3460',
});
```

That's it! Your app now has a beautiful, consistent theme across both platforms. 🎉

---

## 📚 API Reference

### `configure(options)`

Configure the entire system UI in a single call. This is the **recommended method** as it applies all changes atomically, reducing visual glitches.

```typescript
await SystemUI.configure({
  // Edge-to-edge mode
  edgeToEdge: true,

  // Visibility
  statusBarVisible: true,
  navigationBarVisible: true,

  // Icon styles ('light' for dark backgrounds, 'dark' for light backgrounds)
  statusBarStyle: 'light',
  navigationBarStyle: 'light',

  // Background colors (hex format: #RRGGBB or #RRGGBBAA)
  contentBackgroundColor: '#121212',
  statusBarBackgroundColor: '#121212',
  navigationBarBackgroundColor: '#121212',
  cutoutBackgroundColor: '#121212',
});
```

#### Options

| Property                            | Type                | Description                                 |
| ----------------------------------- | ------------------- | ------------------------------------------- |
| `edgeToEdge`                        | `boolean`           | Enable edge-to-edge display mode            |
| `statusBarVisible`                  | `boolean`           | Show/hide the status bar                    |
| `navigationBarVisible`              | `boolean`           | Show/hide the navigation bar (Android only) |
| `statusBarStyle`                    | `'light' \| 'dark'` | Status bar icon color                       |
| `navigationBarStyle`                | `'light' \| 'dark'` | Navigation bar icon color (Android only)    |
| `contentBackgroundColor`            | `string`            | Main content area background                |
| `statusBarBackgroundColor`          | `string`            | Status bar area background                  |
| `navigationBarBackgroundColor`      | `string`            | Navigation bar area background              |
| `navigationBarLeftBackgroundColor`  | `string`            | Left navigation bar in landscape            |
| `navigationBarRightBackgroundColor` | `string`            | Right navigation bar in landscape           |
| `cutoutBackgroundColor`             | `string`            | Display cutout (notch/Dynamic Island) area  |

---

### `setBackgroundColors(options)`

Set background colors for different UI areas independently.

```typescript
// Set all areas to one color (cascade)
await SystemUI.setBackgroundColors({
  contentBackgroundColor: '#ffffff',
});

// Or customize each area
await SystemUI.setBackgroundColors({
  contentBackgroundColor: '#ffffff',
  statusBarBackgroundColor: '#f5f5f5',
  navigationBarBackgroundColor: '#e0e0e0',
  cutoutBackgroundColor: '#f5f5f5',
});
```

#### 🔄 Color Cascade Behavior

Colors automatically cascade if not explicitly set:

```
contentBackgroundColor
    ├── statusBarBackgroundColor
    ├── navigationBarBackgroundColor
    │       ├── navigationBarLeftBackgroundColor
    │       └── navigationBarRightBackgroundColor
    └── cutoutBackgroundColor (via statusBar)
```

- If only `contentBackgroundColor` is provided, it fills **all** areas
- If `statusBarBackgroundColor` is not set, it uses `contentBackgroundColor`
- If `navigationBarBackgroundColor` is not set, it uses `contentBackgroundColor`
- If `cutoutBackgroundColor` is not set, it cascades from `statusBarBackgroundColor`

---

### `setBarStyles(options)`

Set the icon/content style for system bars.

```typescript
// For dark theme (light icons on dark background)
await SystemUI.setBarStyles({
  statusBarStyle: 'light',
  navigationBarStyle: 'light',
});

// For light theme (dark icons on light background)
await SystemUI.setBarStyles({
  statusBarStyle: 'dark',
  navigationBarStyle: 'dark',
});
```

---

### `setStatusBarVisibility(options)`

Show or hide the status bar.

```typescript
// Hide status bar
await SystemUI.setStatusBarVisibility({ visible: false });

// Show status bar
await SystemUI.setStatusBarVisibility({ visible: true });
```

---

### `setNavigationBarVisibility(options)`

Show or hide the navigation bar (Android only).

```typescript
// Hide navigation bar (immersive mode)
await SystemUI.setNavigationBarVisibility({ visible: false });

// Show navigation bar
await SystemUI.setNavigationBarVisibility({ visible: true });
```

> **Note**: On iOS, this method has no effect as the home indicator is controlled by the system.

---

### `setEdgeToEdge(options)`

Enable or disable edge-to-edge display mode.

```typescript
// Enable edge-to-edge
await SystemUI.setEdgeToEdge({ enabled: true });

// Disable edge-to-edge (restore normal behavior)
await SystemUI.setEdgeToEdge({ enabled: false });
```

---

### `getInfo()`

Get current system UI information including inset values.

```typescript
const info = await SystemUI.getInfo();

console.log('Status bar height:', info.statusBarHeight);
console.log('Navigation bar height:', info.navigationBarHeight);
console.log('Left inset:', info.leftInset);
console.log('Right inset:', info.rightInset);
console.log('Is edge-to-edge:', info.isEdgeToEdgeEnabled);
console.log('Color scheme:', info.colorScheme);
```

#### Return Value (`SystemUIInfo`)

| Property                 | Type                | Description                        |
| ------------------------ | ------------------- | ---------------------------------- |
| `statusBarHeight`        | `number`            | Status bar height in pixels        |
| `navigationBarHeight`    | `number`            | Navigation bar height in pixels    |
| `leftInset`              | `number`            | Left inset (landscape navigation)  |
| `rightInset`             | `number`            | Right inset (landscape navigation) |
| `cutoutTop`              | `number`            | Top display cutout height          |
| `cutoutLeft`             | `number`            | Left display cutout width          |
| `cutoutRight`            | `number`            | Right display cutout width         |
| `isEdgeToEdgeEnabled`    | `boolean`           | Whether edge-to-edge is active     |
| `isSafeAreaEnabled`      | `boolean`           | Whether safe area is respected     |
| `isStatusBarVisible`     | `boolean`           | Status bar visibility state        |
| `isNavigationBarVisible` | `boolean`           | Navigation bar visibility state    |
| `colorScheme`            | `'light' \| 'dark'` | Current system color scheme        |

---

### `getColorScheme()`

Get the current system color scheme.

```typescript
const { colorScheme } = await SystemUI.getColorScheme();
console.log('Current theme:', colorScheme); // 'light' or 'dark'
```

---

### Event: `colorSchemeChanged`

Listen for system color scheme changes (dark mode toggle).

```typescript
import { SystemUI } from '@payiano/capacitor-theme-support';

SystemUI.addListener('colorSchemeChanged', event => {
  console.log('Theme changed to:', event.colorScheme);

  // Update your app's theme
  if (event.colorScheme === 'dark') {
    applyDarkTheme();
  } else {
    applyLightTheme();
  }
});
```

---

## 💡 Usage Examples

### Basic Light Theme

```typescript
await SystemUI.configure({
  edgeToEdge: true,
  statusBarStyle: 'dark',
  navigationBarStyle: 'dark',
  contentBackgroundColor: '#ffffff',
});
```

### Basic Dark Theme

```typescript
await SystemUI.configure({
  edgeToEdge: true,
  statusBarStyle: 'light',
  navigationBarStyle: 'light',
  contentBackgroundColor: '#121212',
});
```

### Dynamic Theme Switching (Vue/Nuxt)

```typescript
import { SystemUI } from '@payiano/capacitor-theme-support';

const isDarkMode = ref(false);

watch(
  isDarkMode,
  dark => {
    SystemUI.configure({
      edgeToEdge: true,
      statusBarStyle: dark ? 'light' : 'dark',
      navigationBarStyle: dark ? 'light' : 'dark',
      contentBackgroundColor: dark ? '#121212' : '#ffffff',
      statusBarBackgroundColor: dark ? '#1e1e1e' : '#f5f5f5',
      navigationBarBackgroundColor: dark ? '#1e1e1e' : '#f5f5f5',
    });
  },
  { immediate: true },
);
```

### Fullscreen Media Player

```typescript
// Enter fullscreen
await SystemUI.configure({
  edgeToEdge: true,
  statusBarVisible: false,
  navigationBarVisible: false,
  contentBackgroundColor: '#000000',
});

// Exit fullscreen
await SystemUI.configure({
  statusBarVisible: true,
  navigationBarVisible: true,
});
```

### Gradient Header Effect

```typescript
await SystemUI.configure({
  edgeToEdge: true,
  statusBarStyle: 'light',
  contentBackgroundColor: '#1a1a2e',
  statusBarBackgroundColor: '#0d0d1a', // Darker shade for header
  navigationBarBackgroundColor: '#1a1a2e',
});
```

### Safe Area CSS Variables

```typescript
const info = await SystemUI.getInfo();

// Use in CSS custom properties
document.documentElement.style.setProperty(
  '--safe-area-top',
  `${info.statusBarHeight}px`,
);
document.documentElement.style.setProperty(
  '--safe-area-bottom',
  `${info.navigationBarHeight}px`,
);
document.documentElement.style.setProperty(
  '--safe-area-left',
  `${info.leftInset}px`,
);
document.documentElement.style.setProperty(
  '--safe-area-right',
  `${info.rightInset}px`,
);
```

### Auto Dark Mode with System Detection

```typescript
import { SystemUI } from '@payiano/capacitor-theme-support';

// Initial setup based on system preference
const { colorScheme } = await SystemUI.getColorScheme();
applyTheme(colorScheme);

// Listen for changes
SystemUI.addListener('colorSchemeChanged', event => {
  applyTheme(event.colorScheme);
});

function applyTheme(scheme: 'light' | 'dark') {
  const isDark = scheme === 'dark';

  SystemUI.configure({
    edgeToEdge: true,
    statusBarStyle: isDark ? 'light' : 'dark',
    navigationBarStyle: isDark ? 'light' : 'dark',
    contentBackgroundColor: isDark ? '#121212' : '#ffffff',
  });
}
```

---

## 📱 Platform Differences

| Feature                   | Android                   | iOS                     |
| ------------------------- | ------------------------- | ----------------------- |
| Status bar colors         | ✅ Full support           | ✅ Full support         |
| Navigation bar colors     | ✅ Full support           | ✅ Home indicator area  |
| Status bar visibility     | ✅ Full support           | ✅ Full support         |
| Navigation bar visibility | ✅ Hide with swipe reveal | ❌ No effect            |
| Display cutout handling   | ✅ Full support           | ✅ Notch/Dynamic Island |
| Edge-to-edge              | ✅ Full support           | ✅ Full support         |
| Dark mode detection       | ✅ Full support           | ✅ Full support         |
| Landscape bar colors      | ✅ Left/Right control     | ✅ Left/Right control   |

---

## 🔄 Migration from v1.x

If you're upgrading from the old `NativeTheme` API:

### Old API (v1.x)

```typescript
import { NativeTheme } from '@payiano/capacitor-theme';

await NativeTheme.enableEdgeToEdge();
await NativeTheme.setAppTheme({
  windowBackgroundColor: '#ffffff',
  statusBarColor: '#ffffff',
  navigationBarColor: '#ffffff',
  isStatusBarLight: true,
  isNavigationBarLight: true,
});
```

### New API (v2.x)

```typescript
import { SystemUI } from '@payiano/capacitor-theme-support';

await SystemUI.configure({
  edgeToEdge: true,
  statusBarStyle: 'dark',
  navigationBarStyle: 'dark',
  contentBackgroundColor: '#ffffff',
  statusBarBackgroundColor: '#ffffff',
  navigationBarBackgroundColor: '#ffffff',
});
```

### Key Changes

| v1.x                      | v2.x                              |
| ------------------------- | --------------------------------- |
| `NativeTheme`             | `SystemUI`                        |
| `enableEdgeToEdge()`      | `configure({ edgeToEdge: true })` |
| `setAppTheme()`           | `configure()`                     |
| `windowBackgroundColor`   | `contentBackgroundColor`          |
| `statusBarColor`          | `statusBarBackgroundColor`        |
| `navigationBarColor`      | `navigationBarBackgroundColor`    |
| `isStatusBarLight: true`  | `statusBarStyle: 'dark'`          |
| `isStatusBarLight: false` | `statusBarStyle: 'light'`         |

---

## 🤝 Contributing

Contributions are welcome! Please open issues or pull requests if you want to suggest improvements or fixes.

### Development Commands

```bash
npm run build    # Build the plugin
npm run verify   # Verify Android and iOS builds
npm run lint     # Run ESLint
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📜 Code of Conduct

This project follows the [Contributor Code of Conduct](CODE-OF-CONDUCT.md). By participating, you agree to abide by its terms.

---

## ☕ Sponsoring

If you find this project helpful, please consider supporting me on Buy Me a Coffee! Your support helps me continue developing open-source software.

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/default-orange.png)](https://buymeacoffee.com/alaa_abdallah1)

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/alaa-abdallah1">Alaa Abdallah</a> at <a href="https://payiano.com">Payiano</a>
</p>
