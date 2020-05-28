//
//  OfflineSideloader.swift
//  flutter_plugin_mapbox_whyre
//
//  Created by mac on 26/5/20.
//
import Foundation
import Flutter
import UIKit
import Mapbox
import MapboxAnnotationExtension


class OfflineManager: NSObject {
    private var mapView: MGLMapView
    private var channel: FlutterMethodChannel
    var progressView: UIProgressView!

    
    init(mapview:MGLMapView, registrar: FlutterPluginRegistrar) {
        
        self.mapView = mapview
        self.channel = FlutterMethodChannel(name: "plugins.flutter.io/offline_map", binaryMessenger: registrar.messenger())
        super.init()
        self.channel.setMethodCallHandler(onMethodCall)
        NSLog("\nInit offline")
        
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
        
    }
    
   
    
    func downloadRegion(regionName:String){
    // Create a region that includes the current viewport and any tiles needed to view it when zoomed further in.
    // Because tile count grows exponentially with the maximum zoom level, you should be conservative with your `toZoomLevel` setting.
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: mapView.zoomLevel, toZoomLevel: mapView.maximumZoomLevel)
         
        // Store some data for identification purposes alongside the downloaded resources.
        let userInfo = ["name": regionName]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
         
        // Create and register an offline pack with the shared offline storage object.
         
        MGLOfflineStorage.shared.addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
            // The pack couldn’t be created for some reason.
            //print("Error: \(error?.localizedDescription ?? "unknown error")")
            NSLog("\nError: \(error?.localizedDescription ?? "unknown error")")
            return
            }
             
            // Start downloading.
            NSLog("\nDownloading")
            pack!.resume()
        }
     
    }
    
    @objc func offlinePackProgressDidChange(notification: NSNotification) {
    // Get the offline pack this notification is regarding,
    // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
        let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
        let progress = pack.progress
        
            
        // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
        let completedResources = progress.countOfResourcesCompleted
        let expectedResources = progress.countOfResourcesExpected
         
        // Calculate current progress percentage.
        let progressPercentage = Float(completedResources) / Float(expectedResources)
         
        // Setup the progress bar.
        if progressView == nil {
            progressView = UIProgressView(progressViewStyle: .default)
            let frame = mapView.bounds.size
            progressView.frame = CGRect(x: 0, y: frame.height , width: frame.width / 1, height: 20)
              
            progressView.transform = CGAffineTransform(scaleX:1, y:8)
            mapView.addSubview(progressView)
            
            
        }
         
        progressView.progress = progressPercentage
         
        // If this pack has finished, print its size and resource count.
        if completedResources == expectedResources {
            let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)
            print("Offline pack “\(userInfo["name"] ?? "unknown")” completed: \(byteCount), \(completedResources) resources")
            
//            progressView.removeFromSuperview()
   
                 
            } else {
            // Otherwise, print download/verification progress.
//            print()
            NSLog("\nOffline pack “\(userInfo["name"] ?? "unknown")” has \(completedResources) of \(expectedResources) resources — \(String(format: "%.2f", progressPercentage * 100))%.")
            }
        }
    }
 
    
    @objc func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” received error: \(error.localizedFailureReason ?? "unknown error")")
        }
    }

    @objc func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount] as AnyObject).uint64Value {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” reached limit of \(maximumCount) tiles.")
        }
    }
    
    func retrieveOfflineTileNames() -> [AnyObject]{
        var allPacks = [MGLOfflinePack]()
        var result :[AnyObject] = []
        if let offlinePacks = MGLOfflineStorage.shared.packs {
            
           allPacks = offlinePacks.filter({
            guard let context = NSKeyedUnarchiver.unarchiveObject(with: $0.context) as? [String:String] else {
                   NSLog("\n Error retrieving offline pack context")
                   return false
               }
//            NSLog("\ncontext \(context as AnyObject)")
            result.append(context["name"] as AnyObject)
            return true
           })
        }
         
        return result
    }
    
    func getDownloadedTiles(){
        let result :[AnyObject] = retrieveOfflineTileNames()
        channel.invokeMethod("retrieveDownloadedTileNames",arguments:result);
    }
    
    func deleteRegion(index:Int){
        var result :[AnyObject] = []
        if let offlinePacks = MGLOfflineStorage.shared.packs {
//            let allPacks = offlinePacks[index]
            MGLOfflineStorage.shared.removePack(offlinePacks[index])
 
        }
    }
    
    func navigateToRegion(index:Int){
        mapView.styleURL =  MGLOfflineStorage.shared.packs?[index].region.styleURL
        if let tiles = MGLOfflineStorage.shared.packs?[index].region as? MGLTilePyramidOfflineRegion{
            mapView.setVisibleCoordinateBounds(tiles.bounds, animated: true)
        }

    }
    
    func onMethodCall(methodCall: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(methodCall.method) {
            case "offline#downloadOnClick":
                guard let arguments = methodCall.arguments as? [String: Any] else { return }
                guard var regName = arguments["downloadName"] as? String else { return }
                if(regName.count==0){
                    regName = String(format:"%.1f,%.1f,%.1f,%.1f",mapView.visibleCoordinateBounds.ne.latitude,mapView.visibleCoordinateBounds.ne.longitude,
                                        mapView.visibleCoordinateBounds.sw.latitude,
                    mapView.visibleCoordinateBounds.sw.longitude)
                        
                }

                downloadRegion(regionName:regName)
                break;
            case "offline#getDownloadedTiles":
                getDownloadedTiles();
                break;
            case "offline#deleteDownloadedTiles":
                guard let arguments = methodCall.arguments as? [String: Any] else { return }
                guard let indexToDelete = arguments["indexToDelete"] as? Int else { return }
                deleteRegion(index:indexToDelete);
                break;
            case "offline#navigateToRegion":
                guard let arguments = methodCall.arguments as? [String: Any] else { return }
                 guard let indexToNavigate = arguments["indexToNavigate"] as? Int else { return }
                  
                navigateToRegion(index:indexToNavigate);
                break;
            default:
                result(FlutterMethodNotImplemented)
        }
    }
    
    
    
    
}
