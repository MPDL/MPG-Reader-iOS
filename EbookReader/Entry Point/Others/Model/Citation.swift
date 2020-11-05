//
//  Citation.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/6.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation

class CitationRS: Codable {
    var bookId: String?
    var citationContents: CitationContent?
}

struct CitationContent: Codable {
    var array: [Citation]

    // Define DynamicCodingKeys type needed for creating
    // decoding container from JSONDecoder
    private struct DynamicCodingKeys: CodingKey {

        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempArray = [Citation]()
        for key in container.allKeys {
            let value = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            tempArray.append(Citation(key: key.stringValue, value: value))
        }
        array = tempArray
    }
}

struct Citation: Codable {
    var key: String?
    var value: String?
}
