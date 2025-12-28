import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
  ) -> Bool {

    // Google Maps / Places / Geocoding (iOS tarafı tek API key ile)
    GMSServices.provideAPIKey("YOUR_REAL_API_KEY_HERE")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
