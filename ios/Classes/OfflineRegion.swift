//
//  OfflineRegionData.swift
//  location
//
//  Created by Patryk on 02/06/2020.
//

import Foundation
import Mapbox

class OfflineRegion {
    let id: Int
    let metadata: [String: Any]
    let definition: OfflineRegionDefinition
    
    enum CodingKeys: CodingKey {
      case id, metadata, definition
    }

    init(id: Int, metadata: [String: Any], definition: OfflineRegionDefinition) {
        self.id = id
        self.metadata = metadata
        self.definition = definition
    }

    func prepareContext() -> Data {
        let context = ["metadata": metadata, "id": id] as [String: Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: context, options: [])
        return jsonData ?? Data()
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "metadata": metadata,
            "definition": definition.toDictionary()
        ]
    }

    static func fromOfflinePack(_ pack: MGLOfflinePack) -> OfflineRegion? {
        guard let region = pack.region as? MGLTilePyramidOfflineRegion,
            let dataObject = try? JSONSerialization.jsonObject(with: pack.context, options: []),
            let dict = dataObject as? [String: Any],
            let id = dict["id"] as? Int,
            let metadata = dict["metadata"] as? [String: Any] else { return nil }
        return OfflineRegion(
            id: id,
            metadata: metadata,
            definition: OfflineRegionDefinition(
                bounds: [region.bounds.sw, region.bounds.ne].map { [$0.latitude, $0.longitude] },
                mapStyleUrl: region.styleURL,
                minZoom: region.minimumZoomLevel,
                maxZoom: region.maximumZoomLevel
            )
        )
    }
}
