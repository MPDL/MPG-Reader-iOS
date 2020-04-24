//
//  NetworkManager.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/23.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import AFNetworking

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
                    let decoder = JSONDecoder()
                    let bookRS = try decoder.decode(BookRS.self, from: response)
                    if let success = success {
                        success(bookRS.records!)
                    }
                } catch {
                    print(error)
                    return
                }
            }, failure: { (task, error) in
                if let failure = failure {
                    failure(error)
                }
            })
    }
}
