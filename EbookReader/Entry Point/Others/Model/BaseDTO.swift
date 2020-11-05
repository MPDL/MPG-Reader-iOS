//
//  BaseDTO.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/25.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation

class BaseDTO<T>: Codable where T: Codable {
    var code: Int?
    var message: String?
    var content: T?
}
