//
//  PopupView.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/23.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

@available(iOS 13.0, *)
class PopupView: NSObject {
    static var stack: NSMutableArray = []
    static let kLoadingViewTag = 1000

    class func showWithContent(_ content: String) {
        self.showWithContent(content, completionBlock: nil)
    }

    class func showWithContent(_ content: String, completionBlock: (() -> Void)?) {
        let topView: UIView = AppDelegate.getTopView()
        DispatchQueue.main.async(execute: {
            let hud: MBProgressHUD = MBProgressHUD.showAdded(to: topView, animated: true)
            hud.mode = .text
            hud.detailsLabel.text = content
            hud.detailsLabel.textColor = UIColor.white
            hud.bezelView.layer.cornerRadius = 5
            hud.bezelView.style = .solidColor
            hud.bezelView.color = UIColor(white: 0, alpha: 0.8)
            hud.hide(animated: true, afterDelay: 2)
        })
        if let block = completionBlock{
            let time = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: block)
        }
    }

    class func showLoading(_ show: Bool, parentView: UIView?) {
        var parentView = parentView
        if (!show) {
            if let loadingView: UIView = stack.lastObject as? UIView {
                loadingView.removeFromSuperview()
                stack.remove(loadingView)
            }
            return
        }
        if (parentView == nil) {
            parentView = AppDelegate.getTopView()
        }
        var backgroundView = parentView?.viewWithTag(kLoadingViewTag)
        if (backgroundView == nil) {
            backgroundView = UIView(frame: parentView!.bounds)
            backgroundView!.backgroundColor = UIColor.clear
            backgroundView!.tag = kLoadingViewTag
            parentView?.addSubview(backgroundView!)
            stack.add(backgroundView!)

            let loadingView = UIActivityIndicatorView(style: .large)
            backgroundView!.addSubview(loadingView)
            loadingView.snp.makeConstraints({ (make) in
                make.centerX.equalTo(backgroundView!)
                make.centerY.equalTo(backgroundView!).offset(-20)
            })

            backgroundView?.layoutIfNeeded()
            loadingView.startAnimating()
        }
        parentView?.bringSubviewToFront(backgroundView!)
    }

    class func showLoading(_ show: Bool) {
        self.showLoading(show, parentView: nil)
    }

    @objc class func dismissLoadingIndicator() {
        self.showLoading(false)
    }
}
