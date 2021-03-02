//
//  Constants.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/29.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import AFNetworking

let bookHistoryKey = "bookHistory"
let inputKey = "inputCache"
let wifiKey = "onlyWifi"
let screenKey = "screenOn"

let prefs = UserDefaults.standard
let manager = AFNetworkReachabilityManager.shared()

var downloadWithWifiOnly = prefs.value(forKey: wifiKey) as? Bool ?? true
var keepScreenOnWhileReading = prefs.value(forKey: screenKey) as? Bool ?? true
var networkStatus: AFNetworkReachabilityStatus = .notReachable


