import Flutter
import UIKit

public class SwiftMapboxGlFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = MapboxMapFactory(withRegistrar: registrar)
        registrar.register(instance, withId: "plugins.flutter.io/mapbox_gl")
        

        let channel = FlutterMethodChannel(name: "plugins.flutter.io/mapbox_gl", binaryMessenger: registrar.messenger())

        channel.setMethodCallHandler { (methodCall, result) in
            switch(methodCall.method) {
            case "installOfflineMapTiles":
                guard let arguments = methodCall.arguments as? [String: String] else { return }
                let tilesdb = arguments["tilesdb"]
                installOfflineMapTiles(registrar: registrar, tilesdb: tilesdb!)
                result(nil)
            case "downloadOfflineRegion":
                // Get download region arguments from caller
                guard let args = methodCall.arguments as? [String: Any],
                      let definitionDictionary = args["definition"] as? [String: Any],
                      let metadata = args["metadata"] as? [String: Any],
                      let defintion = OfflineRegionDefinition.fromDictionary(definitionDictionary),
                      let channelName = args["channelName"] as? String
                    else {
                        print("downloadOfflineRegion unexpected arguments: \(String(describing: methodCall.arguments))")
                        result(nil)
                        return
                    }
                // Prepare channel
                let channelHandler = OfflineChannelHandler(
                    messenger: registrar.messenger(),
                    channelName: channelName
                )
                OfflineManagerUtils.downloadRegion(
                    definition: defintion,
                    metadata: metadata,
                    result: result,
                    registrar: registrar,
                    channelHandler: channelHandler
                )
            case "setOfflineTileCountLimit":
                guard let arguments = methodCall.arguments as? [String: Any],
                    let limit = arguments["limit"] as? UInt64 else {
                        result(FlutterError(
                            code: "SetOfflineTileCountLimitError",
                            message: "could not decode arguments",
                            details: nil
                        ))
                        return
                }
                OfflineManagerUtils.setOfflineTileCountLimit(result: result, maximumCount: limit)
            case "getListOfRegions":
                // Note: this does not download anything from internet, it only fetches data drom database
                OfflineManagerUtils.regionsList(result: result)
            case "deleteOfflineRegion":
                guard let args = methodCall.arguments as? [String: Any],
                    let id = args["id"] as? Int else {
                        result(nil)
                        return
                }
                OfflineManagerUtils.deleteRegion(result: result, id: id)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private static func getTilesUrl() -> URL {
        guard var cachesUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
            let bundleId = Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String else {
                fatalError("Could not get map tiles directory")
        }
        cachesUrl.appendPathComponent(bundleId)
        cachesUrl.appendPathComponent(".mapbox")
        cachesUrl.appendPathComponent("cache.db")
        return cachesUrl
    }

    // Copies the "offline" tiles to where Mapbox expects them
    private static func installOfflineMapTiles(registrar: FlutterPluginRegistrar, tilesdb: String) {
        var tilesUrl = getTilesUrl()
        let bundlePath = getTilesDbPath(registrar: registrar, tilesdb: tilesdb)
        NSLog("Cached tiles not found, copying from bundle... \(String(describing: bundlePath)) ==> \(tilesUrl)")
        do {
            let parentDir = tilesUrl.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true, attributes: nil)
            if FileManager.default.fileExists(atPath: tilesUrl.path) {
                try FileManager.default.removeItem(atPath: tilesUrl.path)
            }
            try FileManager.default.copyItem(atPath: bundlePath!, toPath: tilesUrl.path)
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try tilesUrl.setResourceValues(resourceValues)
        } catch let error {
            NSLog("Error copying bundled tiles: \(error)")
        }
    }
    
    private static func getTilesDbPath(registrar: FlutterPluginRegistrar, tilesdb: String) -> String? {
        if (tilesdb.starts(with: "/")) {
            return tilesdb;
        } else {
            let key = registrar.lookupKey(forAsset: tilesdb)
            return Bundle.main.path(forResource: key, ofType: nil)
        }
    }
}
