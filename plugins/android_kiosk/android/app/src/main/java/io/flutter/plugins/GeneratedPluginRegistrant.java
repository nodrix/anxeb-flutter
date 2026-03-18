package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.nodrix.anxeb.android_kiosk.AndroidKioskPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    AndroidKioskPlugin.registerWith(registry.registrarFor("com.nodrix.anxeb.android_kiosk.AndroidKioskPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
