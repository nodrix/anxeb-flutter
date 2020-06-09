package com.nodrix.anxeb.android_middleware.middleware;

import android.app.Activity;
import android.os.Build;
import androidx.annotation.NonNull;
import android.view.WindowManager;

@SuppressWarnings("deprecation")
public class AndroidWindowManager {
    private Activity activity;

    public AndroidWindowManager(Activity activity) {
        this.activity = activity;
    }
    private boolean validLayoutParam(int flag) {
        switch (flag) {
            case WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON:
            case WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM:
            case WindowManager.LayoutParams.FLAG_DIM_BEHIND:
            case WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN:
            case WindowManager.LayoutParams.FLAG_FULLSCREEN:
            case WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED:
            case WindowManager.LayoutParams.FLAG_IGNORE_CHEEK_PRESSES:
            case WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON:
            case WindowManager.LayoutParams.FLAG_LAYOUT_INSET_DECOR:
            case WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN:
            case WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS:
            case WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE:
            case WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE:
            case WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL:
            case WindowManager.LayoutParams.FLAG_SCALED:
            case WindowManager.LayoutParams.FLAG_SECURE:
            case WindowManager.LayoutParams.FLAG_SHOW_WALLPAPER:
            case WindowManager.LayoutParams.FLAG_SPLIT_TOUCH:
            case WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH:
                return true;
            case WindowManager.LayoutParams.FLAG_BLUR_BEHIND:
                return !(Build.VERSION.SDK_INT >= 15);
            case WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD:
                return (Build.VERSION.SDK_INT >= 5 && Build.VERSION.SDK_INT < 26);
            case WindowManager.LayoutParams.FLAG_DITHER:
                return !(Build.VERSION.SDK_INT >= 17);
            case WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS:
                return (Build.VERSION.SDK_INT >= 21);
            case WindowManager.LayoutParams.FLAG_LAYOUT_ATTACHED_IN_DECOR:
                return (Build.VERSION.SDK_INT >= 22);
            case WindowManager.LayoutParams.FLAG_LAYOUT_IN_OVERSCAN:
                return (Build.VERSION.SDK_INT >= 18);
            case WindowManager.LayoutParams.FLAG_LOCAL_FOCUS_MODE:
                return (Build.VERSION.SDK_INT >= 19);
            case WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED:
                return !(Build.VERSION.SDK_INT >= 27);
            case WindowManager.LayoutParams.FLAG_TOUCHABLE_WHEN_WAKING:
                return !(Build.VERSION.SDK_INT >= 20);
            case WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION:
            case WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS:
                return (Build.VERSION.SDK_INT >= 19);
            case WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON:
                return !(Build.VERSION.SDK_INT >= 27);
            default:
                return false;
        }
    }

    private boolean validLayoutParams(int flags) {
        for (int i = 0; i < Integer.SIZE; i++) {
            int flag = (1 << i);
            if ((flags & flag) == 1) {
                if (!validLayoutParam(flag)) {
                    return false;
                }
            }
        }
        return true;
    }

    public boolean setFlags(int flags) {
        if (!validLayoutParams(flags)) {
            return false;
        }
        activity.getWindow().addFlags(flags);
        return true;
    }

    public boolean clearFlags(int flags) {
        if (!validLayoutParams(flags)) {
            return false;
        }
        activity.getWindow().clearFlags(flags);
        return true;
    }
}