# 🎨 @payiano/capacitor-theme

[![NPM Package](https://img.shields.io/npm/v/@payiano/capacitor-theme?color=red)](https://www.npmjs.com/package/@payiano/capacitor-theme)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

> **Powered by [Payiano Team](https://payiano.com) | [GitHub](https://github.com/payiano)**

A lightweight Capacitor plugin for **advanced native theme customization** on Android and iOS.

This plugin solves common theming issues in hybrid apps, such as:

- 📱 **Edge-to-Edge Support**: Easily enable full-screen content behind system bars.
- 🎨 **Window Background**: Fixes black bars appearing during rotation or overscroll by setting the native window background.
- 🌈 **System Bar Colors**: Granular control over Status Bar and Navigation Bar colors.
- 🌗 **Icon Themes**: Independently toggle Light/Dark icons for Status Bar and Navigation Bar.

## Features

- **Cross-Platform**: Works seamlessly on Android and iOS.
- **Safe Area Management**: Automatically handles insets for system bars and keyboard (IME) when in Edge-to-Edge mode.
- **Zero Conflicts**: Designed to replace multiple fragmented plugins (`EdgeToEdge`, `NavigationBar`, `StatusBar`) with a single, cohesive solution.

## Installation

Install the plugin from npm:

```bash
npm install @payiano/capacitor-theme
npx cap sync
```

## Usage

Import the plugin and use it in your app initialization logic.

```typescript
import { NativeTheme } from '@payiano/capacitor-theme';

// 1. Enable Edge-to-Edge (usually on app launch)
await NativeTheme.enableEdgeToEdge();

// 2. Set App Theme (can be called reactively when dark mode changes)
await NativeTheme.setAppTheme({
  windowBackgroundColor: '#FFFFFF', // Fixes rotation black bars
  statusBarColor: '#FFFFFF', // Sets status bar color
  navigationBarColor: '#FFFFFF', // Sets nav bar color (Android only)
  isStatusBarLight: true, // true = Dark Icons (Light Background)
  isNavigationBarLight: true, // true = Dark Icons (Light Background)
});
```

### Example with Vue/Nuxt

```typescript
import { NativeTheme } from '@payiano/capacitor-theme';

// Watch for theme changes
watch(
  isDarkMode,
  dark => {
    NativeTheme.setAppTheme({
      windowBackgroundColor: dark ? '#000000' : '#FFFFFF',
      statusBarColor: dark ? '#000000' : '#FFFFFF',
      navigationBarColor: dark ? '#000000' : '#FFFFFF',
      isStatusBarLight: !dark,
      isNavigationBarLight: !dark,
    });
  },
  { immediate: true },
);
```

## API

<docgen-index>

- [`enableEdgeToEdge()`](#enableedgetoedge)
- [`setAppTheme(...)`](#setapptheme)
- [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and run docgen to update the docs below-->

### enableEdgeToEdge()

```typescript
enableEdgeToEdge() => Promise<void>
```

Enables Edge-to-Edge mode for the application.

- **Android**: Sets `DecorFitsSystemWindows(false)` and applies safe area insets to the WebView.
- **iOS**: Sets `contentInsetAdjustmentBehavior = .never` and makes the WebView transparent.

---

### setAppTheme(...)

```typescript
setAppTheme(options: NativeThemeOptions) => Promise<void>
```

Sets the application theme, including window background, system bar colors, and icon styles.

| Param         | Type                                                              | Description                 |
| :------------ | :---------------------------------------------------------------- | :-------------------------- |
| **`options`** | <code><a href="#nativethemeoptions">NativeThemeOptions</a></code> | Theme configuration options |

---

### Interfaces

#### NativeThemeOptions

| Prop                        | Type                 | Description                                                                                                                           |
| :-------------------------- | :------------------- | :------------------------------------------------------------------------------------------------------------------------------------ |
| **`windowBackgroundColor`** | <code>string</code>  | The background color of the window (visible in overscroll/notch areas). Hex color string (e.g. #FFFFFF).                              |
| **`statusBarColor`**        | <code>string</code>  | The background color of the status bar. Hex color string (e.g. #FFFFFF) or #00000000 for transparent.                                 |
| **`navigationBarColor`**    | <code>string</code>  | The background color of the navigation bar. Hex color string (e.g. #FFFFFF) or #00000000 for transparent.                             |
| **`isStatusBarLight`**      | <code>boolean</code> | Whether the status bar should be light (Dark Icons). true = Dark Icons (Light Background), false = Light Icons (Dark Background).     |
| **`isNavigationBarLight`**  | <code>boolean</code> | Whether the navigation bar should be light (Dark Icons). true = Dark Icons (Light Background), false = Light Icons (Dark Background). |

</docgen-api>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open issues or pull requests if you want to suggest improvements or fixes.

### Development commands

```bash
npm run build   # Build the plugin
```
