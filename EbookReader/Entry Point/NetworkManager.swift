//
//  NetworkManager.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/23.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import AFNetworking
import Mantle

class NetworkManager: AFHTTPSessionManager {
    static var networkManager: NetworkManager?

    static func sharedInstance() -> NetworkManager {
        if let manager = networkManager {
            return manager
        } else {
            networkManager = NetworkManager(baseURL: URL(string: "http://register.dev-mpad.mpdl.mpg.de/"))
            networkManager!.requestSerializer = AFHTTPRequestSerializer()
            networkManager!.responseSerializer = AFHTTPResponseSerializer()
            return networkManager!
        }
    }

    func GET(path: String, parameters: Any?, modelClass: AnyClass?, success: ((Any) -> Void)?, failure: ((Error) -> Void)?) {
        self.get(path,
            parameters: parameters,
            headers: nil,
            progress: nil,
            success: { (task, response) in
                guard let response = response as? Data else {
                    return
                }
                do {
                    let responseJson = try JSONSerialization.jsonObject(with: response, options: [])
                    guard let responseDictionary = responseJson as? [AnyHashable : Any] else {
                        return
                    }
                    let object = try MTLJSONAdapter.models(of: modelClass, fromJSONArray: responseDictionary["records"] as? [Any])
                    if let success = success {
                        success(object)
                    }
                } catch {
                    return
                }
            }, failure: { (task, error) in
                if let failure = failure {
                    failure(error)
                }
            })
    }
}
