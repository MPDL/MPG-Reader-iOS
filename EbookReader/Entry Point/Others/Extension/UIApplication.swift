//
//  UIApplication.swift
//  EbookReader
//
//  Created by Ying Li on 07.10.20.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {

    func clearLaunchScreenCache() {
        do {
            try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Library/SplashBoard")
        } catch {
            print("Failed to delete launch screen cache: \(error)")
        }
    }

}
