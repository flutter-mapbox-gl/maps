import Mapbox

class MapboxMapStyle {
    
    private struct MapboxMapStyles {
        // Traffic Day and Traffic Night are currently not supported.
        static let MAPBOX_STREETS = "mapbox://styles/mapbox/streets-v11"
        static let OUTDOORS = "mapbox://styles/mapbox/outdoors-v11"
        static let LIGHT = "mapbox://styles/mapbox/light-v10"
        static let DARK = "mapbox://styles/mapbox/dark-v10"
        static let SATELLITE = "mapbox://styles/mapbox/satellite-v9"
        static let SATELLITE_STREETS = "mapbox://styles/mapbox/satellite-streets-v11"
    }
    
    private static let MapboxMapStyleLookup = [
        MapboxMapStyles.MAPBOX_STREETS: MGLStyle.streetsStyleURL,
        MapboxMapStyles.OUTDOORS: MGLStyle.outdoorsStyleURL,
        MapboxMapStyles.LIGHT: MGLStyle.lightStyleURL,
        MapboxMapStyles.DARK: MGLStyle.darkStyleURL,
        MapboxMapStyles.SATELLITE: MGLStyle.satelliteStyleURL,
        MapboxMapStyles.SATELLITE_STREETS: MGLStyle.satelliteStreetsStyleURL
    ]
    
    
    static func fromUrl(styleString: String) -> URL? {
        return MapboxMapStyle.MapboxMapStyleLookup[styleString]
    }
}
