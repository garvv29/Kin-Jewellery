# Razorpay ProGuard rules - Keep all Razorpay classes
-keep class com.razorpay.** { *; }
-keepclassmembers class com.razorpay.** { *; }
-keepclasseswithmembers class com.razorpay.** { *; }

# ProGuard annotations
-keep class proguard.annotation.** { *; }
-keepclassmembers class * {
    @proguard.annotation.** *;
}

# Google Pay / Wallet classes
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-keepclassmembers class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }

# Firebase - Keep all Firebase classes
-keep class com.google.firebase.** { *; }
-keepclassmembers class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }

# Google Play Services - Keep all classes
-keep class com.google.android.gms.** { *; }
-keepclassmembers class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keepclassmembers class com.google.android.gms.auth.** { *; }

# Google Identity
-keep class com.google.identity.** { *; }
-keepclassmembers class com.google.identity.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep serializable classes
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep BuildConfig
-keep class **.BuildConfig { *; }

# Keep fragment classes
-keep class android.support.v4.app.Fragment { *; }
-keep class androidx.fragment.app.Fragment { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
