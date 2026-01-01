# 🎨 @payiano/capacitor-theme-support

[![NPM Package](https://img.shields.io/npm/v/@payiano/capacitor-theme-support?color=red)](https://www.npmjs.com/package/@payiano/capacitor-theme-support)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

> **Powered by [Payiano Team](https://payiano.com) | [GitHub](https://github.com/payiano)**

A comprehensive Capacitor plugin for **native system UI control** on Android and iOS.

This plugin provides complete control over the system UI, solving common theming issues in hybrid apps:

- 📱 **Edge-to-Edge Display**: Content extends behind system bars for immersive experiences
- 🎨 **Background Colors**: Independent control of content, status bar, navigation bar, and cutout areas
- 👁️ **Visibility Control**: Show/hide status bar and navigation bar programmatically
- 🌗 **Bar Styles**: Light/dark icon themes for system bars
- 📐 **Inset Information**: Get precise measurements for safe area handling
- 🔄 **Orientation Support**: Properly handles landscape mode and device rotation

## Features

- **Cross-Platform**: Consistent API across Android and iOS
- **Safe Area Management**: Automatically handles insets for system bars
- **Color Cascade**: Set one color and have it apply to all areas, or customize each independently
- **Modern Android Support**: Uses overlay views approach compatible with Android 15+ edge-to-edge
- **TypeScript Support**: Full type definitions included

## Installation

```bash
npm install @payiano/capacitor-theme-support
npx cap sync
```

## Quick Start

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

## API Reference

### `configure(options)`

Configure the entire system UI in a single call. This is the recommended method as it applies all changes atomically, reducing visual glitches.

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

| Property                       | Type                | Description                                           |
| ------------------------------ | ------------------- | ----------------------------------------------------- |
| `edgeToEdge`                   | `boolean`           | Enable edge-to-edge display mode                      |
| `statusBarVisible`             | `boolean`           | Show/hide the status bar                              |
| `navigationBarVisible`         | `boolean`           | Show/hide the navigation bar (Android only)           |
| `statusBarStyle`               | `'light' \| 'dark'` | Status bar icon color                                 |
| `navigationBarStyle`           | `'light' \| 'dark'` | Navigation bar icon color (Android only)              |
| `contentBackgroundColor`       | `string`            | Main content area background                          |
| `statusBarBackgroundColor`     | `string`            | Status bar area background                            |
| `navigationBarBackgroundColor` | `string`            | Navigation bar area background                        |
| `cutoutBackgroundColor`        | `string`            | Display cutout (notch/Dynamic Island) area background |

---

### `setBackgroundColors(options)`

Set background colors for different UI areas independently.

```typescript
// Set all areas to one color
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

#### Color Cascade Behavior

Colors automatically cascade if not explicitly set:

- If only `contentBackgroundColor` is provided, it fills **all** areas
- If `statusBarBackgroundColor` is not set, it uses `contentBackgroundColor`
- If `navigationBarBackgroundColor` is not set, it uses `contentBackgroundColor`
- If `cutoutBackgroundColor` is not set, it uses `contentBackgroundColor`

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

When hidden, users can swipe from the bottom edge to temporarily reveal the navigation bar.

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
```

#### Return Value (`SystemUIInfo`)

| Property                 | Type      | Description                        |
| ------------------------ | --------- | ---------------------------------- |
| `statusBarHeight`        | `number`  | Status bar height in pixels        |
| `navigationBarHeight`    | `number`  | Navigation bar height in pixels    |
| `leftInset`              | `number`  | Left inset (landscape navigation)  |
| `rightInset`             | `number`  | Right inset (landscape navigation) |
| `cutoutTop`              | `number`  | Top display cutout height          |
| `cutoutLeft`             | `number`  | Left display cutout width          |
| `cutoutRight`            | `number`  | Right display cutout width         |
| `isEdgeToEdgeEnabled`    | `boolean` | Whether edge-to-edge is active     |
| `isSafeAreaEnabled`      | `boolean` | Whether safe area is respected     |
| `isStatusBarVisible`     | `boolean` | Status bar visibility state        |
| `isNavigationBarVisible` | `boolean` | Navigation bar visibility state    |

---

## Usage Examples

### Basic Light Theme

```typescript
import { SystemUI } from '@payiano/capacitor-theme-support';

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
// Different color for status bar area (gradient effect)
await SystemUI.configure({
  edgeToEdge: true,
  statusBarStyle: 'light',
  contentBackgroundColor: '#1a1a2e',
  statusBarBackgroundColor: '#0d0d1a', // Darker shade for header
  navigationBarBackgroundColor: '#1a1a2e',
});
```

### Getting Safe Area for Custom Layout

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
```

---

## Platform Differences

| Feature                   | Android                   | iOS                     |
| ------------------------- | ------------------------- | ----------------------- |
| Status bar colors         | ✅ Full support           | ✅ Full support         |
| Navigation bar colors     | ✅ Full support           | ✅ Home indicator area  |
| Status bar visibility     | ✅ Full support           | ✅ Full support         |
| Navigation bar visibility | ✅ Hide with swipe reveal | ❌ No effect            |
| Display cutout handling   | ✅ Full support           | ✅ Notch/Dynamic Island |
| Edge-to-edge              | ✅ Full support           | ✅ Full support         |

---

## Migration from v1.x

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
  statusBarStyle: 'dark', // 'dark' = dark icons (was isStatusBarLight: true)
  navigationBarStyle: 'dark',
  contentBackgroundColor: '#ffffff',
  statusBarBackgroundColor: '#ffffff',
  navigationBarBackgroundColor: '#ffffff',
});
```

### Key Changes

| v1.x                      | v2.x                                                                    |
| ------------------------- | ----------------------------------------------------------------------- |
| `NativeTheme`             | `SystemUI`                                                              |
| `enableEdgeToEdge()`      | `configure({ edgeToEdge: true })` or `setEdgeToEdge({ enabled: true })` |
| `setAppTheme()`           | `configure()` or individual methods                                     |
| `windowBackgroundColor`   | `contentBackgroundColor`                                                |
| `statusBarColor`          | `statusBarBackgroundColor`                                              |
| `navigationBarColor`      | `navigationBarBackgroundColor`                                          |
| `isStatusBarLight: true`  | `statusBarStyle: 'dark'`                                                |
| `isStatusBarLight: false` | `statusBarStyle: 'light'`                                               |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open issues or pull requests if you want to suggest improvements or fixes.

### Development

```bash
npm run build   # Build the plugin
npm run verify  # Verify Android and iOS builds
```
