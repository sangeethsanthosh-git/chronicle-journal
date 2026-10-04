# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Drift & SQLite
-keep class org.sqlite.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-keep class sqlite3.** { *; }
-dontwarn org.sqlite.**

# Audio & Media
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Java 8+ Desugaring
-dontwarn java.time.**
-dontwarn java.util.concurrent.**

# Play Core (Deferred Components)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

