//
//  Notification+Name.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/13.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let searchResultsDidReturn = Notification.Name("searchResultsDidReturn")
    static let readingListDidChange = Notification.Name("readingListDidChange")
    static let reviewDidAdd = Notification.Name("reviewDidAdd")
}
