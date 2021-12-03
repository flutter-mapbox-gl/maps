import Mapbox
import MapboxAnnotationExtension

/*
 * The mapping is based on the values defined here:
 *  https://docs.mapbox.com/android/api/map-sdk/8.4.0/constant-values.html
 */

class Constants {
    static let symbolIconAnchorMapping = [
        "center": MGLIconAnchor.center,
        "left": MGLIconAnchor.left,
        "right": MGLIconAnchor.right,
        "top": MGLIconAnchor.top,
        "bottom": MGLIconAnchor.bottom,
        "top-left": MGLIconAnchor.topLeft,
        "top-right": MGLIconAnchor.topRight,
        "bottom-left": MGLIconAnchor.bottomLeft,
        "bottom-right": MGLIconAnchor.bottomRight,
    ]

    static let symbolTextJustificationMapping = [
        "auto": MGLTextJustification.auto,
        "center": MGLTextJustification.center,
        "left": MGLTextJustification.left,
        "right": MGLTextJustification.right,
    ]

    static let symbolTextAnchorMapping = [
        "center": MGLTextAnchor.center,
        "left": MGLTextAnchor.left,
        "right": MGLTextAnchor.right,
        "top": MGLTextAnchor.top,
        "bottom": MGLTextAnchor.bottom,
        "top-left": MGLTextAnchor.topLeft,
        "top-right": MGLTextAnchor.topRight,
        "bottom-left": MGLTextAnchor.bottomLeft,
        "bottom-right": MGLTextAnchor.bottomRight,
    ]

    static let symbolTextTransformationMapping = [
        "none": MGLTextTransform.none,
        "lowercase": MGLTextTransform.lowercase,
        "uppercase": MGLTextTransform.uppercase,
    ]

    static let lineJoinMapping = [
        "bevel": MGLLineJoin.bevel,
        "miter": MGLLineJoin.miter,
        "round": MGLLineJoin.round,
    ]
}
