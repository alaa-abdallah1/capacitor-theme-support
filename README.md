# 🎨 capacitor-theme-support

[![GitHub release](https://img.shields.io/github/v/release/alaa-abdallah1/capacitor-theme-support.svg)](https://github.com/alaa-abdallah1/capacitor-theme-support/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue)](LICENSE)
[![NPM Package](https://img.shields.io/npm/v/capacitor-theme-support?color=red)](https://www.npmjs.com/package/capacitor-theme-support)
[![NPM downloads](https://img.shields.io/npm/dw/capacitor-theme-support?color=limegreen)](https://www.npmjs.com/package/capacitor-theme-support)

> **Powered by [Payiano Team](https://payiano.com) | [GitHub](https://github.com/payiano)**

Make your Capacitor app look **truly native** with beautiful edge-to-edge displays and seamless dark mode support.

⚡ Ever noticed how your hybrid app looks different from native apps? The status bar has that awkward white or black bar? The navigation area doesn't match your app's colors? **This plugin fixes all of that.**

⚡ With **edge-to-edge display support**, your app fills the entire screen beautifully, just like native apps do.

⚡ **Automatic dark mode detection** keeps your app in sync with the system theme, providing a seamless user experience.

## Compatibility

| Platform      | Support                   |
| ------------- | ------------------------- |
| **Android**   | ✅ Full support (API 22+) |
| **iOS**       | ✅ Full support (iOS 13+) |
| **Capacitor** | 6.x, 7.x, 8.x             |

## Installation

Install the plugin from [npm](https://www.npmjs.com/package/capacitor-theme-support) with your preferred package manager:

```bash
# NPM
npm install capacitor-theme-support
npx cap sync

# Yarn
yarn add capacitor-theme-support
npx cap sync

# PNPM
pnpm add capacitor-theme-support
npx cap sync
```

[![NPM](https://nodei.co/npm/capacitor-theme-support.png)](https://www.npmjs.com/package/capacitor-theme-support)

## Usage

### Quick Start

**Just one line of code to make your app look amazing:**

```typescript
import { SystemUI } from 'capacitor-theme-support';

// Dark theme example
await SystemUI.configure({
  edgeToEdge: true,
  statusBarStyle: 'light', // Light icons for dark backgrounds
  navigationBarStyle: 'light',
  contentBackgroundColor: '#1a1a2e',
});
```

**Light theme? Just as easy:**

```typescript
await SystemUI.configure({
  edgeToEdge: true,
  statusBarStyle: 'dark', // Dark icons for light backgrounds
  navigationBarStyle: 'dark',
  contentBackgroundColor: '#ffffff',
});
```

### Auto Dark Mode

Want your app to automatically follow the system's dark/light mode?

```typescript
import { SystemUI } from 'capacitor-theme-support';

// Listen for system theme changes
SystemUI.addListener('colorSchemeChanged', event => {
  if (event.colorScheme === 'dark') {
    // Apply your dark theme colors
    SystemUI.configure({
      edgeToEdge: true,
      statusBarStyle: 'light',
      contentBackgroundColor: '#121212',
    });
  } else {
    // Apply your light theme colors
    SystemUI.configure({
      edgeToEdge: true,
      statusBarStyle: 'dark',
      contentBackgroundColor: '#ffffff',
    });
  }
});
```

## API Reference

### Methods

| Method                                | Description                                       | Platform     |
| ------------------------------------- | ------------------------------------------------- | ------------ |
| `configure(options)`                  | Configure all system UI settings in a single call | Android, iOS |
| `setBackgroundColors(options)`        | Set background colors for different UI areas      | Android, iOS |
| `setBarStyles(options)`               | Set icon/content style for status and nav bars    | Android, iOS |
| `setEdgeToEdge(options)`              | Enable or disable edge-to-edge display mode       | Android, iOS |
| `setStatusBarVisibility(options)`     | Show or hide the status bar                       | Android, iOS |
| `setNavigationBarVisibility(options)` | Show or hide the navigation bar                   | Android only |
| `getColorScheme()`                    | Get current system color scheme (light/dark)      | Android, iOS |
| `getInfo()`                           | Get system UI information (insets, state)         | Android, iOS |
| `addListener(event, callback)`        | Listen for color scheme changes                   | Android, iOS |
| `removeAllListeners()`                | Remove all event listeners                        | Android, iOS |

### `configure(options)`

Configure the entire system UI in a single call. This is the recommended approach.

```typescript
await SystemUI.configure({
  // Display mode
  edgeToEdge: true,

  // Visibility
  statusBarVisible: true,
  navigationBarVisible: true, // Android only

  // Icon colors: 'light' = white icons, 'dark' = black icons
  statusBarStyle: 'light',
  navigationBarStyle: 'light', // Android only

  // Background colors (hex: '#RRGGBB' or '#RRGGBBAA')
  contentBackgroundColor: '#1a1a2e',
  statusBarBackgroundColor: '#16213e',
  navigationBarBackgroundColor: '#0f3460',
  cutoutBackgroundColor: '#000000',

  // Landscape mode (optional)
  navigationBarLeftBackgroundColor: '#0f3460',
  navigationBarRightBackgroundColor: '#0f3460',
});
```

### `setBackgroundColors(options)`

Set background colors for different UI areas independently.

```typescript
// Set all areas to the same color
await SystemUI.setBackgroundColors({
  contentBackgroundColor: '#ffffff',
});

// Set different colors for each area
await SystemUI.setBackgroundColors({
  contentBackgroundColor: '#ffffff',
  statusBarBackgroundColor: '#f5f5f5',
  navigationBarBackgroundColor: '#e0e0e0',
  navigationBarLeftBackgroundColor: '#d0d0d0', // Landscape
  navigationBarRightBackgroundColor: '#d0d0d0', // Landscape
  cutoutBackgroundColor: '#f5f5f5',
});
```

### `setBarStyles(options)`

Set the icon/content color for system bars.

```typescript
// Dark theme: light icons on dark background
await SystemUI.setBarStyles({
  statusBarStyle: 'light',
  navigationBarStyle: 'light', // Android only
});

// Light theme: dark icons on light background
await SystemUI.setBarStyles({
  statusBarStyle: 'dark',
  navigationBarStyle: 'dark',
});
```

### `setEdgeToEdge(options)`

Enable or disable edge-to-edge display mode.

```typescript
// Enable edge-to-edge (content extends behind system bars)
await SystemUI.setEdgeToEdge({ enabled: true });

// Disable edge-to-edge (system bars take their own space)
await SystemUI.setEdgeToEdge({ enabled: false });
```

### `setStatusBarVisibility(options)`

Show or hide the status bar.

```typescript
// Hide status bar
await SystemUI.setStatusBarVisibility({ visible: false });

// Show status bar
await SystemUI.setStatusBarVisibility({ visible: true });
```

### `setNavigationBarVisibility(options)`

Show or hide the navigation bar (Android only).

```typescript
// Hide navigation bar (user can swipe to reveal)
await SystemUI.setNavigationBarVisibility({ visible: false });

// Show navigation bar
await SystemUI.setNavigationBarVisibility({ visible: true });
```

### `getColorScheme()`

Get the current system color scheme.

```typescript
const { colorScheme } = await SystemUI.getColorScheme();

if (colorScheme === 'dark') {
  applyDarkTheme();
} else {
  applyLightTheme();
}
```

### `getInfo()`

Get comprehensive system UI information.

```typescript
const info = await SystemUI.getInfo();

console.log(info.statusBarHeight); // Height in pixels
console.log(info.navigationBarHeight); // Height in pixels
console.log(info.leftInset); // Left inset (landscape)
console.log(info.rightInset); // Right inset (landscape)
console.log(info.cutoutTop); // Notch/Dynamic Island height
console.log(info.colorScheme); // 'light' or 'dark'
console.log(info.isEdgeToEdgeEnabled); // true or false
console.log(info.isStatusBarVisible); // true or false
console.log(info.isNavigationBarVisible); // true or false
```

### Event Listeners

Listen for system color scheme changes:

```typescript
// Add listener
const handle = await SystemUI.addListener('colorSchemeChanged', event => {
  console.log('Color scheme changed to:', event.colorScheme);

  if (event.colorScheme === 'dark') {
    document.body.classList.add('dark');
  } else {
    document.body.classList.remove('dark');
  }
});

// Remove specific listener
handle.remove();

// Remove all listeners
await SystemUI.removeAllListeners();
```

## Features

| Feature                  | What It Does                              |
| ------------------------ | ----------------------------------------- |
| **Edge-to-Edge**         | Make your app fill the entire screen      |
| **Status Bar Color**     | Color behind the clock, battery, signal   |
| **Navigation Bar Color** | Color behind the home button/gesture area |
| **Cutout Color**         | Color behind the notch or Dynamic Island  |
| **Bar Styles**           | Light or dark icons in system bars        |
| **Dark Mode Detection**  | Know when user switches dark/light mode   |
| **Bar Visibility**       | Show or hide status/navigation bars       |

## Tips

1. **Always enable edge-to-edge** for the best experience
2. **Use `statusBarStyle: 'light'`** when your status bar background is **dark**
3. **Use `statusBarStyle: 'dark'`** when your status bar background is **light**
4. **Set `contentBackgroundColor`** to your app's main background color

## Common Issues

**Q: Colors not showing on iOS?**  
A: Make sure `edgeToEdge: true` is set.

**Q: Dark mode not detected?**  
A: Add the `colorSchemeChanged` listener before the app loads.

**Q: Status bar icons invisible?**  
A: Check your `statusBarStyle` - use 'light' for dark backgrounds, 'dark' for light backgrounds.

## Contributing

Contributions are welcome! Please open issues or pull requests if you want to suggest improvements or fixes.

### Development commands

```bash
npm run build     # Build production files
npm run lint      # Run ESLint
```

## License

MIT

## Sponsoring

If you find this project helpful, please consider supporting me on Buy Me a Coffee! Your support helps me continue developing open-source software.

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/default-orange.png)](https://buymeacoffee.com/alaa_abdallah1)

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/alaa-abdallah1">Alaa Abdallah</a> & <a href="https://payiano.com">Payiano Team</a>
</p>
