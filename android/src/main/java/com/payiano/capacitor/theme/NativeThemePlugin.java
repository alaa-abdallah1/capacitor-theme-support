package com.payiano.capacitor.theme;

import android.graphics.Color;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "NativeTheme")
public class NativeThemePlugin extends Plugin {

    @PluginMethod
    public void enableEdgeToEdge(PluginCall call) {
        getActivity().runOnUiThread(() -> {
            Window window = getActivity().getWindow();
            WindowCompat.setDecorFitsSystemWindows(window, false);
            
            // Ensure we can draw system bar backgrounds
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
            window.setNavigationBarColor(Color.TRANSPARENT);

            View webView = getBridge().getWebView();
            
            ViewCompat.setOnApplyWindowInsetsListener(webView, (v, windowInsets) -> {
                Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars() | WindowInsetsCompat.Type.displayCutout());
                Insets imeInsets = windowInsets.getInsets(WindowInsetsCompat.Type.ime());
                boolean isKeyboardVisible = windowInsets.isVisible(WindowInsetsCompat.Type.ime());

                ViewGroup.MarginLayoutParams mlp = (ViewGroup.MarginLayoutParams) v.getLayoutParams();
                mlp.topMargin = insets.top;
                mlp.leftMargin = insets.left;
                mlp.rightMargin = insets.right;
                mlp.bottomMargin = isKeyboardVisible ? imeInsets.bottom : insets.bottom;
                
                v.setLayoutParams(mlp);
                return WindowInsetsCompat.CONSUMED;
            });
            
            call.resolve();
        });
    }

    @PluginMethod
    public void setAppTheme(PluginCall call) {
        String windowBg = call.getString("windowBackgroundColor");
        String statusBarColor = call.getString("statusBarColor");
        String navBarColor = call.getString("navigationBarColor");
        
        // Use "Light" naming to match setAppearanceLightStatusBars (true = dark icons, false = light icons)
        Boolean isStatusBarLight = call.getBoolean("isStatusBarLight");
        Boolean isNavigationBarLight = call.getBoolean("isNavigationBarLight");

        getActivity().runOnUiThread(() -> {
            try {
                Window window = getActivity().getWindow();
                WindowInsetsControllerCompat windowInsetsController =
                        WindowCompat.getInsetsController(window, window.getDecorView());

                // Set the Window Background Color (covers the area under the notch/cutout during rotation)
                if (windowBg != null && !windowBg.isEmpty()) {
                    window.getDecorView().setBackgroundColor(Color.parseColor(windowBg));
                }

                // Set Status Bar Color
                if (statusBarColor != null && !statusBarColor.isEmpty()) {
                    window.setStatusBarColor(Color.parseColor(statusBarColor));
                }

                // Set Navigation Bar Color
                if (navBarColor != null && !navBarColor.isEmpty()) {
                    window.setNavigationBarColor(Color.parseColor(navBarColor));
                }

                // Handle Status Bar Icons
                // true = Light Mode (Dark Icons)
                // false = Dark Mode (Light Icons)
                if (isStatusBarLight != null) {
                    windowInsetsController.setAppearanceLightStatusBars(isStatusBarLight);
                }

                // Handle Navigation Bar Icons
                if (isNavigationBarLight != null) {
                    windowInsetsController.setAppearanceLightNavigationBars(isNavigationBarLight);
                }

                call.resolve();
            } catch (IllegalArgumentException e) {
                call.reject("Invalid color format");
            } catch (Exception e) {
                call.reject("Failed to set theme: " + e.getMessage());
            }
        });
    }
}
