//
//  WebviewViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/5/11.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import WebKit

class WebviewViewController: UIViewController {
    internal var webView: WKWebView!

    var urlString: String?
    internal var titleLabel = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = titleLabel

        webView = WKWebView()
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }

        if let urlString = self.urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.webView.scrollView.contentInset = UIEdgeInsets.zero
    }
}
