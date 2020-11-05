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
            // TODO: 切换成正式的地址
            networkManager = NetworkManager(baseURL: URL(string: "http://8.129.114.118:8089/"))
            networkManager!.requestSerializer = AFJSONRequestSerializer()
            networkManager!.responseSerializer = AFHTTPResponseSerializer()
            if let path = Bundle.main.path(forResource: "credential", ofType: "json") {
                do {
                      let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                      let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                      if let jsonResult = jsonResult as? Dictionary<String, String>, let client = jsonResult["client"], let secret = jsonResult["secret"] {
                        // TODO: 从mdm读取
                        networkManager?.requestSerializer.setValue("yu@mpdl.mpg.de", forHTTPHeaderField: "X-Email")
                        networkManager?.requestSerializer.setValue("snOfThePad", forHTTPHeaderField: "X-SN")
                        let authorization = "\(client):\(secret)".data(using: String.Encoding.utf8)!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                        networkManager?.requestSerializer.setValue("Basic \(authorization)", forHTTPHeaderField: "Authorization")
                      }
                  } catch {
                       // handle error
                       PopupView.showWithContent("failed to load credential file")
                  }
            } else {
                PopupView.showWithContent("failed to load credential file")
            }
            return networkManager!
        }
    }

    func successHandler<T>(response: Any?, modelClass: T.Type, success: ((T?) -> Void)?) where T: Codable {
        PopupView.showLoading(false)
        guard let response = response as? Data else {
            return
        }
        do {
            let decoder = JSONDecoder()
            let model = try decoder.decode(BaseDTO<T>.self, from: response)
            if model.code == 0 {
                success?(model.content)
            } else {
                PopupView.showWithContent(model.message ?? "server error")
            }
        } catch {
            print(error)
            return
        }
    }

    func GET<T>(path: String, parameters: Any?, modelClass: T.Type, success: ((T?) -> Void)?, failure: ((Error) -> Void)?) where T: Codable {
        PopupView.showLoading(true)
        self.get(path,
            parameters: parameters,
            headers: nil,
            progress: nil,
            success: { (task, response) in
                self.successHandler(response: response, modelClass: modelClass, success: success)
            }, failure: { (task, error) in
                PopupView.showLoading(false)
                failure?(error)
            })
    }

    func POST<T>(path: String, parameters: Any?, modelClass: T.Type, success: ((T?) -> Void)?, failure: ((Error) -> Void)?) where T: Codable {
        PopupView.showLoading(true)
        self.post(path,
            parameters: parameters,
            headers: nil,
            progress: nil,
            success: { (task, response) in
                self.successHandler(response: response, modelClass: modelClass, success: success)
            }, failure: { (task, error) in
                PopupView.showLoading(false)
                failure?(error)
            })
    }
}
