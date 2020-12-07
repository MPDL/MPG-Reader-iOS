//
//  NavigationItemView.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/6.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit

protocol NavigationItemDelegate: class {
    func onOneActionTapped(action: NaviAction)
}

enum NaviAction {
    case writeReview
    case citeItem
    case gotoInfo
}

class NavigationItemView: UIView {

    fileprivate var bookId: String!
    fileprivate var delegate: NavigationItemDelegate!
    fileprivate var contentView: UIView!
    fileprivate var reviewView: UIControl!

    init(bookId: String, delegate: NavigationItemDelegate) {
        super.init(frame: .zero)
        self.bookId = bookId
        self.delegate = delegate
        self.backgroundColor = UIColor.clear
        self.isHidden = true
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tap.delegate = self
        self.addGestureRecognizer(tap)

        contentView = UIView()
        contentView.backgroundColor = UIColor.white
        contentView.layer.shadowOffset = CGSize(width: 0, height: 8)
        contentView.layer.shadowRadius = 25
        contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.cornerRadius = 8
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.width.equalTo(262)
            make.top.equalTo(10)
            make.right.equalTo(-18)
        }
        let infoView = UIControl()
        infoView.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            self?.dismiss()
            self?.delegate.onOneActionTapped(action: .gotoInfo)
        }
        contentView.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.height.equalTo(68)
            make.width.left.top.equalTo(contentView)
        }
        let infoImageView = UIImageView()
        infoImageView.image = UIImage(named: "icon-navbar-info")
        infoView.addSubview(infoImageView)
        infoImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(infoView)
            make.left.equalTo(28)
        }
        let infoLabel = UILabel()
        infoLabel.text = "Go to Info-Page"
        infoLabel.textColor = UIColor(hex: 0x333333)
        infoLabel.font = UIFont.boldSystemFont(ofSize: 18)
        infoView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(infoView)
            make.left.equalTo(infoImageView.snp.right).offset(12)
        }
        reviewView = UIControl()
        reviewView.clipsToBounds = true
        reviewView.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            self?.dismiss()
            self?.delegate.onOneActionTapped(action: .writeReview)
        }
        contentView.addSubview(reviewView)
        reviewView.snp.makeConstraints { (make) in
            make.height.equalTo(68)
            make.width.left.equalTo(contentView)
            make.top.equalTo(infoView.snp.bottom)
        }
        let reviewImageView = UIImageView()
        reviewImageView.image = UIImage(named: "icon-navbar-review")
        reviewView.addSubview(reviewImageView)
        reviewImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(reviewView)
            make.left.equalTo(28)
        }
        let reviewLabel = UILabel()
        reviewLabel.text = "Review this book"
        reviewLabel.textColor = UIColor(hex: 0x333333)
        reviewLabel.font = UIFont.boldSystemFont(ofSize: 18)
        reviewView.addSubview(reviewLabel)
        reviewLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(reviewView)
            make.left.equalTo(reviewImageView.snp.right).offset(12)
        }
        let citeView = UIControl()
        citeView.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            self?.dismiss()
            self?.delegate.onOneActionTapped(action: .citeItem)
        }
        contentView.addSubview(citeView)
        citeView.snp.makeConstraints { (make) in
            make.height.equalTo(68)
            make.width.left.equalTo(contentView)
            make.top.equalTo(reviewView.snp.bottom)
            make.bottom.equalTo(0)
        }
        let citeImageView = UIImageView()
        citeImageView.image = UIImage(named: "icon-navbar-cite")
        citeView.addSubview(citeImageView)
        citeImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(citeView)
            make.left.equalTo(28)
        }
        let citeLabel = UILabel()
        citeLabel.text = "Cite this item"
        citeLabel.textColor = UIColor(hex: 0x333333)
        citeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        citeView.addSubview(citeLabel)
        citeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(citeView)
            make.left.equalTo(citeImageView.snp.right).offset(12)
        }

        self.loadStatistic()
    }

    @objc func dismiss() {
        self.isHidden = true
    }

    func display() {
        self.loadStatistic()
        self.isHidden = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func loadStatistic() {
        NetworkManager.sharedInstance().GET(path: "rest/ebook/" + bookId,
            parameters: nil,
            modelClass: BookStatistic.self,
            success: { (bookStatistic) in
                if let isReviewedByMe = bookStatistic?.isReviewedByMe, isReviewedByMe {
                    self.reviewView.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                } else {
                    self.reviewView.snp.updateConstraints { (make) in
                        make.height.equalTo(68)
                    }
                }
                self.layoutIfNeeded()
            }, failure: nil)
    }

}

extension NavigationItemView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: contentView) {
            return false
        } else {
            return true
        }
    }
}
