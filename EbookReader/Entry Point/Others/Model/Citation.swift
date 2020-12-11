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
    var citationContents: [CitationContent]?
}

class CitationContent: Codable {
    var type: String?
    var value: String?
}
