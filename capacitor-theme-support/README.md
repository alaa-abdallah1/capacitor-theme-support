# 🎨 capacitor-theme-support

> Make your Capacitor app look **truly native** with beautiful edge-to-edge displays and seamless dark mode support.

[![NPM Version](https://img.shields.io/npm/v/capacitor-theme-support?color=red)](https://www.npmjs.com/package/capacitor-theme-support)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

---

## 🚀 What Does This Plugin Do?

Ever noticed how your hybrid app looks different from native apps? The status bar has that awkward white or black bar? The navigation area doesn't match your app's colors? **This plugin fixes all of that.**

| Before                                    | After                              |
| ----------------------------------------- | ---------------------------------- |
| ❌ Status bar doesn't blend with your app | ✅ Seamless full-screen experience |
| ❌ Navigation bar is a different color    | ✅ Matching colors everywhere      |
| ❌ Notch/Dynamic Island shows wrong color | ✅ Perfect cutout handling         |
| ❌ Dark mode doesn't sync with system     | ✅ Automatic theme detection       |

---

## 📦 Installation

```bash
npm install capacitor-theme-support
npx cap sync
```

---

## 🎯 Quick Start

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

---

## 🌗 Auto Dark Mode

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

---

## 🎨 Custom Colors for Each Area

Want different colors for the status bar, navigation bar, and content? No problem:

```typescript
await SystemUI.configure({
  edgeToEdge: true,
  statusBarStyle: 'light',
  contentBackgroundColor: '#1a1a2e', // Your app's main background
  statusBarBackgroundColor: '#16213e', // Top bar (where time/battery shows)
  navigationBarBackgroundColor: '#0f3460', // Bottom bar (where home button is)
  cutoutBackgroundColor: '#000000', // Notch/Dynamic Island area
});
```

---

## 📱 What You Can Control

| Feature                  | What It Does                              |
| ------------------------ | ----------------------------------------- |
| **Edge-to-Edge**         | Make your app fill the entire screen      |
| **Status Bar Color**     | Color behind the clock, battery, signal   |
| **Navigation Bar Color** | Color behind the home button/gesture area |
| **Cutout Color**         | Color behind the notch or Dynamic Island  |
| **Bar Styles**           | Light or dark icons in system bars        |
| **Dark Mode Detection**  | Know when user switches dark/light mode   |
| **Bar Visibility**       | Show or hide status/navigation bars       |

---

## 🔧 All Available Options

```typescript
await SystemUI.configure({
  // Display mode
  edgeToEdge: true, // Fill entire screen

  // Visibility
  statusBarVisible: true, // Show/hide status bar
  navigationBarVisible: true, // Show/hide nav bar (Android only)

  // Icon colors
  statusBarStyle: 'light', // 'light' = white icons, 'dark' = black icons
  navigationBarStyle: 'light', // Same as above (Android only)

  // Background colors (use hex: '#RRGGBB' or '#RRGGBBAA')
  contentBackgroundColor: '#1a1a2e',
  statusBarBackgroundColor: '#16213e',
  navigationBarBackgroundColor: '#0f3460',
  cutoutBackgroundColor: '#000000',

  // Landscape mode (optional)
  navigationBarLeftBackgroundColor: '#0f3460',
  navigationBarRightBackgroundColor: '#0f3460',
});
```

---

## 📊 Get System Information

Need to know the exact sizes for your layouts?

```typescript
const info = await SystemUI.getInfo();

console.log(info.statusBarHeight); // Height in pixels
console.log(info.navigationBarHeight); // Height in pixels
console.log(info.colorScheme); // 'light' or 'dark'
console.log(info.isEdgeToEdgeEnabled); // true or false
```

---

## ✅ Supported Platforms

| Platform      | Support                   |
| ------------- | ------------------------- |
| **Android**   | ✅ Full support (API 22+) |
| **iOS**       | ✅ Full support (iOS 13+) |
| **Capacitor** | 6.x, 7.x, 8.x             |

---

## 💡 Tips

1. **Always enable edge-to-edge** for the best experience
2. **Use `statusBarStyle: 'light'`** when your status bar background is **dark**
3. **Use `statusBarStyle: 'dark'`** when your status bar background is **light**
4. **Set `contentBackgroundColor`** to your app's main background color

---

## 🆘 Common Issues

**Q: Colors not showing on iOS?**  
A: Make sure `edgeToEdge: true` is set.

**Q: Dark mode not detected?**  
A: Add the `colorSchemeChanged` listener before the app loads.

**Q: Status bar icons invisible?**  
A: Check your `statusBarStyle` - use 'light' for dark backgrounds, 'dark' for light backgrounds.

---

## 📄 License

MIT License - Use it freely in your projects!

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/alaa-abdallah1">Alaa Abdallah</a> at <a href="https://payiano.com">Payiano</a>
</p>
