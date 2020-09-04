import UIKit
import Flutter
import MapKit
import YandexMapKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let resourcePath = Bundle.main.path(forResource: "env", ofType: "plist")!
    let dict = NSDictionary.init(contentsOfFile: resourcePath)!
    YMKMapKit.setApiKey((dict.value(forKeyPath: "YANDEX_API_KEY") as! String))

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
