//
//  UIViewController+Present.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/9.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension UIViewController: SelfAware {

    static func awake() {

        DispatchQueue.once(token: "UIViewController+FullScreen") {
            let originalSelector = #selector(UIViewController.present(_:animated:completion:))
            let swizzleSelector = #selector(UIViewController.swizzlePresent(_:animated:completion:))

            let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector)
            let swizzleMethod = class_getInstanceMethod(UIViewController.self, swizzleSelector)

            let didAddMethod = class_addMethod(UIViewController.self, originalSelector, method_getImplementation(swizzleMethod!), method_getTypeEncoding(swizzleMethod!))

            if didAddMethod {
                class_replaceMethod(UIViewController.self, swizzleSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzleMethod!);
            }
        }
    }

    @objc func swizzlePresent(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if #available(iOS 13.0, *) {
            if viewControllerToPresent.modalPresentationStyle == .pageSheet {
                viewControllerToPresent.modalPresentationStyle = .fullScreen
            }
        }
        self.swizzlePresent(viewControllerToPresent, animated: flag, completion: completion)
    }
}

