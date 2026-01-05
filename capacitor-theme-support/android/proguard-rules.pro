# ProGuard rules for capacitor-theme-support
# Keep plugin class and methods accessible to Capacitor

-keep class com.payiano.capacitor.theme.** { *; }
-keepclassmembers class com.payiano.capacitor.theme.** { *; }

# Keep Capacitor plugin annotations
-keepattributes *Annotation*

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
