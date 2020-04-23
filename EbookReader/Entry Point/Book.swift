//
//  Book.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/23.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import Mantle

class Book: MTLModel, MTLJSONSerializing {
    @objc var abs: String?
    @objc var authorsPrimary: [String]?
    @objc var id: String?
    @objc var isbns: [String]?
    @objc var publicationDates: [String]?
    @objc var publishers: [String]?
    @objc var title: String?
    @objc var urlPdf_str: String?

    static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return NSDictionary.mtl_identityPropertyMap(withModel: self)
    }
}
