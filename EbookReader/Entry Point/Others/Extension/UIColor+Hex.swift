//
//  UIColor+Hex.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/5.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )

        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}
