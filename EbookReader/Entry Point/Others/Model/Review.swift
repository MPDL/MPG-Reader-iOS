//
//  Review.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/6.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation

class Review: Codable {
    var comment: String?
    var createDate: Int?
    var modifyDate: Int?
    var rating: Int?
    var userName: String?
    var uuid: String?
}
