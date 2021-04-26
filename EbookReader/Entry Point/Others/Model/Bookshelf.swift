//
//  Bookshelf.swift
//  EbookReader
//
//  Created by ysq on 2021/4/16.
//  Copyright © 2021 CN. All rights reserved.
//


import Foundation

class BookshelfBook: Codable {
    var bookId: String?
    var bookName: String?
    var bookCoverURL: String?
}

class Bookshelf: Codable {
    var sn: String?
    var folderNames: Array<String>?
    var folderName: String?
    var bookIds: Array<String>?
    var books: Array<BookshelfBook>?
}
