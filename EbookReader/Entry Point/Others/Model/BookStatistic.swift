//
//  BookStatistic.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/25.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation

class BookStatistic: Codable {
    var bookCoverURL: String?
    var bookId: String?
    var bookName: String?
    var createDate: Int?
    var downloads: Int?
    var inReadingList: Bool?
    var modifyDate: Int?
    var rating: Double?
    var reviews: Int?
    var uuid: String?
    var reviewedByMe: Bool?
}
