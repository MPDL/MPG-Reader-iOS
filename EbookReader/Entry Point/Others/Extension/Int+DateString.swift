//
//  Date+String.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/26.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation

extension Int {
    func dateString() -> String {
        let df = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(self / 1000))
        df.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return df.string(from: date)
    }
}
