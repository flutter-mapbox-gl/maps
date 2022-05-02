import Flutter

enum MethodCallError: Error {
    case invalidLayerType(details: String)
    case invalidExpression

    var code: String {
        switch self {
        case .invalidLayerType:
            return "invalidLayerType"
        case .invalidExpression:
            return "invalidExpression"
        }
    }

    var message: String {
        switch self {
        case .invalidLayerType:
            return "Invalid layer type"
        case .invalidExpression:
            return "Invalid expression"
        }
    }

    var details: String {
        switch self {
        case let .invalidLayerType(details):
            return details
        case .invalidExpression:
            return "Could not parse expression."
        }
    }

    var flutterError: FlutterError {
        return FlutterError(
            code: code,
            message: message,
            details: details
        )
    }
}
