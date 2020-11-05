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
    @objc dynamic var abs = ""
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var downloadUrl = ""
    @objc dynamic var modifyDate = Date()
    @objc dynamic var isPdf = true
    @objc dynamic var thumbnail: String?
    @objc dynamic var rating = 0.0
    @objc dynamic var doi = ""

    let authorsPrimary = List<String>()
    let isbns = List<String>()
    let publicationDates = List<String>()
    let publishers = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }

    private enum CodingKeys: String, CodingKey {
        case abs, id, title, downloadUrl, modifyDate, isPdf, thumbnail, rating, authorsPrimary, isbns, publicationDates, publishers, doi
    }

    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let str = try container.decodeIfPresent(String.self, forKey: .abs) {
            abs = str
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
        if let bool = try container.decodeIfPresent(Bool.self, forKey: .isPdf) {
            isPdf = bool
        }
        if let str = try container.decodeIfPresent(String.self, forKey: .thumbnail) {
            thumbnail = str
        }
        if let str = try container.decodeIfPresent(String.self, forKey: .doi) {
            doi = str
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
        
    }
}
