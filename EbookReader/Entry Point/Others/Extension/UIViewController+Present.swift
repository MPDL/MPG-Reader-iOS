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

extension UIViewController {

    public class func initializeMethod() {

        if self != UIViewController.self {
            return
        }

        DispatchQueue.once(token: "UIViewController+EmptyBackButton") {
            let originalSelector = #selector(UIViewController.viewDidLoad)
            let swizzleSelector = #selector(UIViewController.swizzleViewDidLoad)

            let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector)
            let swizzleMethod = class_getInstanceMethod(UIViewController.self, swizzleSelector)

            let didAddMethod = class_addMethod(UIViewController.self, originalSelector, method_getImplementation(swizzleMethod!), method_getTypeEncoding(swizzleMethod!))

            if didAddMethod {
                class_replaceMethod(UIViewController.self, swizzleSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzleMethod!);
            }
        }

        DispatchQueue.once(token: "UINavigationController+BottomBar") {
            let originalSelector = #selector(UINavigationController.pushViewController(_:animated:))
            let swizzleSelector = #selector(UINavigationController.swizzlePushViewController(_:animated:))

            let originalMethod = class_getInstanceMethod(UINavigationController.self, originalSelector)
            let swizzleMethod = class_getInstanceMethod(UINavigationController.self, swizzleSelector)

            let didAddMethod = class_addMethod(UINavigationController.self, originalSelector, method_getImplementation(swizzleMethod!), method_getTypeEncoding(swizzleMethod!))

            if didAddMethod {
                class_replaceMethod(UINavigationController.self, swizzleSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzleMethod!);
            }
        }

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

    @objc func swizzleViewDidLoad() {
        self.swizzleViewDidLoad()
        let image = UIImage(named: "icon-back")!.withRenderingMode(.alwaysOriginal)
        self.navigationController?.navigationBar.backIndicatorImage = image
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButtonItem
    }

    @objc func swizzlePushViewController(_ viewController: UIViewController, animated: Bool) {
        guard self is UINavigationController else {
            return
        }
        let navigationViewController = self as! UINavigationController
        if navigationViewController.viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        navigationViewController.swizzlePushViewController(viewController, animated: animated)
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

