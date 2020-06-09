package com.nodrix.anxeb.android_middleware;

import android.app.Activity;
import android.os.Build;
import androidx.annotation.NonNull;
import android.view.WindowManager;
import io.flutter.embedding.engine.plugins.activity.*;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.*;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import com.nodrix.anxeb.android_middleware.middleware.AndroidWindowManager;

@SuppressWarnings("deprecation")
public class AndroidMiddlewarePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private MethodChannel channel;
    private AndroidWindowManager windowManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "android_middleware");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        windowManager = new AndroidWindowManager(binding.getActivity());
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        windowManager = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        windowManager = new AndroidWindowManager(binding.getActivity());
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromActivity() {
        windowManager = null;
        channel.setMethodCallHandler(null);
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "android_middleware");
        channel.setMethodCallHandler(new AndroidMiddlewarePlugin());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "addFlags":
                result.success(windowManager.setFlags((int)call.argument("flags")));
                break;
            case "clearFlags":
                result.success(windowManager.clearFlags((int)call.argument("flags")));
                break;
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
