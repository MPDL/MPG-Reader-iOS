//
//  CiteView.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/6.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit

class CiteView: UIView {

    fileprivate var contentView: UIView!

    init(bookId: String) {
        super.init(frame: .zero)

        self.backgroundColor = UIColor(white: 0, alpha: 0.6)
        self.isHidden = true

        let citeView = UIView()
        citeView.layer.cornerRadius = 10
        citeView.backgroundColor = UIColor.white
        self.addSubview(citeView)
        citeView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(10)
            make.width.equalTo(630)
            make.height.equalTo(780)
        }
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "icon-cite-item")
        citeView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(citeView)
            make.top.equalTo(citeView).offset(-30)
        }
        let closeImageView = UIImageView()
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        closeImageView.image = UIImage(named: "icon-dialog-close")
        citeView.addSubview(closeImageView)
        closeImageView.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.right.equalTo(-20)
        }
        let titleLabel = UILabel()
        titleLabel.text = "Copy Citation"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor(hex: 0x333333)
        citeView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(citeView)
            make.top.equalTo(50)
        }

        let scrollView = UIScrollView()
        citeView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.bottom.equalTo(citeView)
        }
        contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }

        loadCitations(bookId: bookId)
    }

    fileprivate func loadCitations (bookId: String) {
        NetworkManager.sharedInstance().GET(
            path: "rest/ebook/\(bookId)/citations",
            parameters: nil,
            modelClass: CitationRS.self,
            success: { (citationRS) in
                guard let citeList = citationRS?.citationContents?.array else {
                    return
                }
                self.setObject(citeList: citeList)
            }, failure: { (error) in
                print(error)
            })
    }

    fileprivate func setObject (citeList: [Citation]) {
        var last: UIView?
        for i in 0..<citeList.count {
            let citationView = generateOneCitationView(citation: citeList[i])
            contentView.addSubview(citationView)
            citationView.snp.makeConstraints { (make) in
                make.left.right.equalTo(0)
                if let last = last {
                    make.top.equalTo(last.snp.bottom)
                } else {
                    make.top.equalTo(0)
                }
                if i == citeList.count - 1 {
                    make.bottom.equalTo(-60)
                }
            }
            last = citationView
        }
    }

    fileprivate func generateOneCitationView(citation: Citation) -> UIView {
        let view = UIView()
        let titleLabel = UILabel()
        titleLabel.text = citation.key
        titleLabel.textColor = UIColor(hex: 0x333333)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.left.equalTo(51)
        }
        let contentWrapper = UIView()
        contentWrapper.backgroundColor = UIColor(hex: 0xF2F2F5)
        view.addSubview(contentWrapper)
        contentWrapper.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(9)
            make.left.equalTo(30)
            make.width.equalTo(457)
            make.bottom.equalTo(0)
        }
        let contentLabel = UILabel()
        contentLabel.numberOfLines = 0
        contentLabel.text = citation.value
        contentLabel.textColor = UIColor(hex: 0x333333)
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentWrapper.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-12)
        }
        let copyView = UIControl()
        copyView.reactive.controlEvents(.touchUpInside).observeValues { (control) in
            UIPasteboard.general.string = citation.value
            PopupView.showWithContent("Citation copied")
        }
        copyView.backgroundColor = UIColor(hex: 0x009FA1)
        copyView.layer.cornerRadius = 4
        view.addSubview(copyView)
        copyView.snp.makeConstraints { (make) in
            make.width.equalTo(83)
            make.height.equalTo(39)
            make.top.equalTo(contentWrapper)
            make.right.equalTo(-40)
        }
        let copyLabel = UILabel()
        copyLabel.text = "Copy"
        copyLabel.textColor = UIColor.white
        copyLabel.font = UIFont.boldSystemFont(ofSize: 18)
        copyView.addSubview(copyLabel)
        copyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(copyView)
        }

        return view
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display() {
        self.isHidden = false
    }

    @objc func dismiss() {
        self.isHidden = true
    }
}
