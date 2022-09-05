//
//  RNMBImageUtils.swift
//  mapbox_gl
//
//  Created by mac on 30/05/2022.
//

enum RNMBImageUtils {
    static func createTempFile(_ image: UIImage) -> URL {
        let fileID = UUID().uuidString
        let pathComponent = "Documents/rctmgl-snapshot-\(fileID).jpeg"

        let filePath = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(pathComponent)

        let data = image.jpegData(compressionQuality: 1.0)
        try! data?.write(to: filePath, options: [.atomic])
        return filePath
    }

    static func createBase64(_ image: UIImage) -> URL {
        let data = image.jpegData(compressionQuality: 1.0)
        let b64string: String = data!.base64EncodedString(options: [.endLineWithCarriageReturn])
        let result = "data:image/jpeg;base64,\(b64string)"
        return URL(string: result)!
    }
}
