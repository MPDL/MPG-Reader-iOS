//
//  Book.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/23.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Book: Object, Codable {
    @objc dynamic var abstract = ""
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var downloadUrl = ""
    @objc dynamic var modifyDate = Date()
    @objc dynamic var pdf = true
    @objc dynamic var thumbnail: String?
    @objc dynamic var rating = 0.0
    @objc dynamic var url = ""
    @objc dynamic var folder = false

    let authorsPrimary = List<String>()
    let isbns = List<String>()
    let publicationDates = List<String>()
    let publishers = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }

    private enum CodingKeys: String, CodingKey {
        case abstract, id, title, downloadUrl, modifyDate, pdf, thumbnail, rating, authorsPrimary, isbns, publicationDates, publishers, url, folder
    }

    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let str = try container.decodeIfPresent(String.self, forKey: .abstract) {
            abstract = str
        }
        if let str = try container.decodeIfPresent(String.self, forKey: .id) {
            id = str
        }
        if let str = try container.decodeIfPresent(String.self, forKey: .title) {
            title = str
        }
        if let str = try container.decodeIfPresent(String.self, forKey: .downloadUrl) {
            downloadUrl = str
        }
        if let date = try container.decodeIfPresent(Date.self, forKey: .modifyDate) {
            modifyDate = date
        }
        if let bool = try container.decodeIfPresent(Bool.self, forKey: .pdf) {
            pdf = bool
        }
        if let str = try container.decodeIfPresent(String.self, forKey: .thumbnail) {
            thumbnail = str
        }
        if let str = try container.decodeIfPresent(String.self, forKey: .url) {
            url = str
        }
        if let double = try container.decodeIfPresent(Double.self, forKey: .rating) {
            rating = double
        }
        if let arr = try container.decodeIfPresent(Array<String>.self, forKey: .authorsPrimary) {
            authorsPrimary.append(objectsIn: arr)
        }
        if let arr = try container.decodeIfPresent(Array<String>.self, forKey: .isbns) {
            isbns.append(objectsIn: arr)
        }
        if let arr = try container.decodeIfPresent(Array<String>.self, forKey: .publicationDates) {
            publicationDates.append(objectsIn: arr)
        }
        if let arr = try container.decodeIfPresent(Array<String>.self, forKey: .publishers) {
            publishers.append(objectsIn: arr)
        }
        if let bool = try container.decodeIfPresent(Bool.self, forKey: .folder) {
            folder = bool
        }
    }
}
