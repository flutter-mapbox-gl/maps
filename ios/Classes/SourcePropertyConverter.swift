import Foundation
import Mapbox

class SourcePropertyConverter {
    class func interpretTileOptions(properties: [String: Any])  -> [MGLTileSourceOption : Any] {
        var options = [MGLTileSourceOption : Any]();

        if let bounds = properties["bounds"] as? Array<Double> {
            options[.coordinateBounds] = boundsFromArray(coordinates: bounds)
        }
        if let minzoom = properties["minzoom"] as? Double {
            options[.minimumZoomLevel] = minzoom
        }
        if let maxzoom = properties["maxzoom"] as? Double {
            options[.maximumZoomLevel] = maxzoom
        }
        if let tileSize = properties["tileSize"] as? Double {
            options[.tileSize] = tileSize
        }
        if let scheme = properties["scheme"] as? String {
            options[.tileCoordinateSystem] = scheme == "tms" ?  MGLTileCoordinateSystem.TMS : MGLTileCoordinateSystem.XYZ
        }
        return options
        // TODO attribution not implemneted for IOS
    }

    class func buildRasterTileSource(identifier: String, properties: [String: Any]) -> MGLRasterTileSource? {
        if let url = properties["url"] as? String {
            return MGLRasterTileSource(identifier:identifier, configurationURL: URL(string: url)!)
        }
        if let tiles = properties["tiles"] as? Array<String> {
            return MGLRasterTileSource(identifier:identifier, tileURLTemplates: tiles, options: interpretTileOptions(properties: properties))
        }
        return nil
    }

    class func buildVectorTileSource(identifier: String, properties: [String: Any]) -> MGLVectorTileSource?  {
        if let url = properties["url"] as? String {
            return MGLVectorTileSource(identifier:identifier, configurationURL: URL(string: url)!)
        }
        if let tiles = properties["tiles"] as? Array<String> {
            return MGLVectorTileSource(identifier:identifier, tileURLTemplates: tiles, options: interpretTileOptions(properties: properties))
        }
        return nil
    }

    class func buildRasterDemSource(identifier: String, properties: [String: Any]) -> MGLRasterDEMSource?  {
        if let url = properties["url"] as? String {
            return MGLRasterDEMSource(identifier:identifier, configurationURL: URL(string: url)!)
        }
        if let tiles = properties["tiles"] as? Array<String> {
            return MGLRasterDEMSource(identifier:identifier, tileURLTemplates: tiles, options: interpretTileOptions(properties: properties))
        }
        return nil
    }

    class func interpretShapeOptions(properties: [String: Any]) -> [MGLShapeSourceOption : Any] {
        var options = [MGLShapeSourceOption : Any]();

        if let maxzoom = properties["maxzoom"] as? Double {
            options[.maximumZoomLevel] = maxzoom
        }
   
        if let buffer = properties["buffer"] as? Double {
            options[.buffer] = buffer
        }
        if let tolerance = properties["tolerance"] as? Double {
            options[.simplificationTolerance] = tolerance
        }

        if let cluster = properties["cluster"] as? Bool {
            options[.clustered] = cluster
        }
        if let clusterRadius = properties["clusterRadius"] as? Double {
            options[.clusterRadius] = clusterRadius
        }
        if let clusterMaxZoom = properties["clusterMaxZoom"] as? Double {
            options[.maximumZoomLevelForClustering] = clusterMaxZoom
        }

        // TODO clusterProperties not implemneted for IOS

        if let lineMetrics = properties["lineMetrics"] as? Bool {
            options[.lineDistanceMetrics] = lineMetrics
        }
        return options;

    }

    class func buildShapeSource(identifier: String, properties: [String: Any]) -> MGLShapeSource?  {
        var source = MGLShapeSource(identifier: identifier)
        addShapeProperties(properties:properties, source:source)
        return source
    }

     class func buildImageSource(identifier: String, properties: [String: Any]) -> MGLImageSource?  {
        var source = MGLImageSource(identifier: identifier)
        addImageProperties(properties:properties, source:source)
        return source
    }

    class func addShapeProperties(properties: [String: Any], source: MGLShapeSource) {
        do {
            if let data = properties["data"] as? String {
                let parsed = try MGLShape.init(data: data.data(using: .utf8)!, encoding: String.Encoding.utf8.rawValue)
                source.shape = parsed
            }
        } catch {
        }
    }

    class func addImageProperties(properties: [String: Any], source: MGLImageSource) {
        if let url = properties["url"] as? String {
            source.url = URL(string: url)!
        }
        if let coordinates = properties["coordinates"] as? [[Double]]  {
            source.coordinates = quadFromArray(coordinates: coordinates)
        }
    }

    class func quadFromArray(coordinates: [[Double]]) -> MGLCoordinateQuad {
        return MGLCoordinateQuad(
                topLeft: CLLocationCoordinate2D(latitude: coordinates[0][1], longitude: coordinates[0][0]),
                bottomLeft: CLLocationCoordinate2D( latitude: coordinates[3][1], longitude: coordinates[3][0]),
                bottomRight: CLLocationCoordinate2D( latitude: coordinates[2][1], longitude: coordinates[2][0]),
                topRight: CLLocationCoordinate2D( latitude: coordinates[1][1], longitude: coordinates[1][0])
            )
    }

     class func boundsFromArray(coordinates: [Double]) -> MGLCoordinateBounds {
        return MGLCoordinateBounds(
                sw: CLLocationCoordinate2D( latitude: coordinates[1], longitude: coordinates[0]),
                ne: CLLocationCoordinate2D( latitude: coordinates[3], longitude: coordinates[2])
            )
    }
}
