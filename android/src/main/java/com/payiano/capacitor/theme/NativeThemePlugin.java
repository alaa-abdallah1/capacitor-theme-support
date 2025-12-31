package com.payiano.capacitor.theme;

import android.graphics.Color;
import android.view.View;
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
        getActivity()
            .runOnUiThread(
                () -> {
                    Window window = getActivity().getWindow();

                    // 1️⃣ Enable edge-to-edge
                    WindowCompat.setDecorFitsSystemWindows(window, false);

                    // 2️⃣ Allow drawing behind system bars
                    window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
                    window.setStatusBarColor(Color.TRANSPARENT);
                    window.setNavigationBarColor(Color.TRANSPARENT);

                    // 3️⃣ Apply insets to the ROOT content view (not the WebView)
                    View contentView = window.findViewById(android.R.id.content);

                    ViewCompat.setOnApplyWindowInsetsListener(
                        contentView,
                        (view, insets) -> {
                            Insets systemBars = insets.getInsets(
                                WindowInsetsCompat.Type.systemBars() | WindowInsetsCompat.Type.displayCutout()
                            );

                            Insets imeInsets = insets.getInsets(WindowInsetsCompat.Type.ime());
                            boolean imeVisible = insets.isVisible(WindowInsetsCompat.Type.ime());

                            // Use padding, NOT margins
                            view.setPadding(
                                systemBars.left,
                                systemBars.top,
                                systemBars.right,
                                imeVisible ? imeInsets.bottom : systemBars.bottom
                            );

                            // IMPORTANT: do NOT consume insets
                            return insets;
                        }
                    );

                    call.resolve();
                }
            );
    }

    @PluginMethod
    public void setAppTheme(PluginCall call) {
        String windowBg = call.getString("windowBackgroundColor");
        String statusBarColor = call.getString("statusBarColor");
        String navBarColor = call.getString("navigationBarColor");

        Boolean isStatusBarLight = call.getBoolean("isStatusBarLight");
        Boolean isNavigationBarLight = call.getBoolean("isNavigationBarLight");

        getActivity()
            .runOnUiThread(
                () -> {
                    try {
                        Window window = getActivity().getWindow();

                        WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(window, window.getDecorView());

                        // Window background (important for cutout area during rotation)
                        if (windowBg != null && !windowBg.isEmpty()) {
                            window.getDecorView().setBackgroundColor(Color.parseColor(windowBg));
                        }

                        // Status bar color
                        if (statusBarColor != null && !statusBarColor.isEmpty()) {
                            window.setStatusBarColor(Color.parseColor(statusBarColor));
                        }

                        // Navigation bar color
                        if (navBarColor != null && !navBarColor.isEmpty()) {
                            window.setNavigationBarColor(Color.parseColor(navBarColor));
                        }

                        // Status bar icon appearance
                        if (isStatusBarLight != null) {
                            controller.setAppearanceLightStatusBars(isStatusBarLight);
                        }

                        // Navigation bar icon appearance
                        if (isNavigationBarLight != null) {
                            controller.setAppearanceLightNavigationBars(isNavigationBarLight);
                        }

                        call.resolve();
                    } catch (IllegalArgumentException e) {
                        call.reject("Invalid color format");
                    } catch (Exception e) {
                        call.reject("Failed to set theme: " + e.getMessage());
                    }
                }
            );
    }
}
