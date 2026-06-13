# --- Jitsi (REQUIRED) ---
-keep class org.jitsi.** { *; }
-keep class org.webrtc.** { *; }

# Keep Flutter app label resources

-keep class com.facebook.react.** { *; }
-keep class com.facebook.soloader.** { *; }

-dontwarn org.webrtc.**
-dontwarn com.facebook.react.**
-dontwarn com.facebook.soloader.**

# Keep Android media & notification metadata
-keep class android.media.** { *; }
-keep class androidx.media.** { *; }

# Prevent stripping of services
-keepclassmembers class * extends android.app.Service {
    <init>(...);
}
