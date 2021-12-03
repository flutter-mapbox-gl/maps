//
//  OfflineChannelHandler.swift
//  location
//
//  Created by Patryk on 03/06/2020.
//

import Flutter
import Foundation

class OfflineChannelHandler: NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?

    init(messenger: FlutterBinaryMessenger, channelName: String) {
        super.init()
        let eventChannel = FlutterEventChannel(name: channelName, binaryMessenger: messenger)
        eventChannel.setStreamHandler(self)
    }

    // MARK: FlutterStreamHandler protocol compliance

    func onListen(withArguments _: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError?
    {
        sink = events
        return nil
    }

    func onCancel(withArguments _: Any?) -> FlutterError? {
        sink = nil
        return nil
    }

    // MARK: Util methods

    func onError(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        sink?(FlutterError(code: errorCode, message: errorMessage, details: errorDetails))
    }

    func onSuccess() {
        let body = ["status": "success"]
        guard let jsonData = try? JSONSerialization.data(
            withJSONObject: body,
            options: .prettyPrinted
        ),
            let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        sink?(jsonString)
    }

    func onStart() {
        let body = ["status": "start"]
        guard let jsonData = try? JSONSerialization.data(
            withJSONObject: body,
            options: .prettyPrinted
        ),
            let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        sink?(jsonString)
    }

    func onProgress(progress: Double) {
        let body: [String: Any] = ["status": "progress", "progress": progress]
        guard let jsonData = try? JSONSerialization.data(
            withJSONObject: body,
            options: .prettyPrinted
        ),
            let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        sink?(jsonString)
    }
}
