
import UIKit
import Flutter
import GoogleMaps
import UserNotifications


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
      [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
   UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    GMSServices.provideAPIKey("AIzaSyDoebikbF2QahLU3ME-_rbJtL-4F8k9Oh8")

    GeneratedPluginRegistrant.register(with: self)

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }
}
