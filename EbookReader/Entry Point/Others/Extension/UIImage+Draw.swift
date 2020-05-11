//
//  UIImage+Draw.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/5/11.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    class func blankImage(size: CGSize, fillColor: UIColor, strokeColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(fillColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        context.setStrokeColor(strokeColor.cgColor)
        context.stroke(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image;
    }

    func changePosition(origin: CGPoint) -> UIImage {
        let size = self.size

        UIGraphicsBeginImageContextWithOptions(size, false, 2)
        self.draw(in: CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

}
