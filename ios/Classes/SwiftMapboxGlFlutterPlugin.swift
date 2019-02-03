import Flutter
import UIKit

public class SwiftMapboxGlFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = MapboxMapFactory(withMessenger: registrar.messenger())
        registrar.register(instance, withId: "plugins.flutter.io/mapbox_gl")
    }
}
