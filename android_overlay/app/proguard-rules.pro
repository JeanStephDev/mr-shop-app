# Règles ProGuard/R8 — nécessaires pour que certains plugins ne soient pas
# supprimés par erreur lors de la minification du build release.

# Google Play Services / Maps / AdMob
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.ads.** { *; }

# Firebase Messaging
-keep class com.google.firebase.** { *; }

# WebView (paiement GeniusPay)
-keepclassmembers class * extends android.webkit.WebViewClient
-keepclassmembers class * extends android.webkit.WebChromeClient

# flutter_local_notifications
-keep class com.dexterous.** { *; }
