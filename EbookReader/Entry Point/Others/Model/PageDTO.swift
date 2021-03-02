//
//  PageDTO.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/25.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation

class PageDTO<T>: Codable where T: Codable {
    var content: [T]?
    var totalPages: Int?
    var totalElements: Int?
}
