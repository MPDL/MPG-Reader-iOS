//
//  FolderNavigationItemView.swift
//  EbookReader
//
//  Created by ysq on 2021/4/19.
//  Copyright © 2021 CN. All rights reserved.
//


import UIKit

protocol FolderNavigationItemDelegate: class {
    func onOneActionTapped(action: FolderNaviAction)
}

enum FolderNaviAction {
    case rename
    case select
}

class FolderNavigationItemView: UIView {

    fileprivate var delegate: FolderNavigationItemDelegate!
    fileprivate var contentView: UIView!
    fileprivate var selectView: UIControl!

    init(delegate: FolderNavigationItemDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.backgroundColor = UIColor.clear
        self.isHidden = true
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tap.delegate = self
        self.addGestureRecognizer(tap)

        contentView = UIView()
        contentView.backgroundColor = COLOR_navItem
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
        let renameView = UIControl()
        renameView.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            self?.dismiss()
            self?.delegate.onOneActionTapped(action: .rename)
        }
        contentView.addSubview(renameView)
        renameView.snp.makeConstraints { (make) in
            make.height.equalTo(68)
            make.width.left.top.equalTo(contentView)
        }
        let infoImageView = UIImageView()
        infoImageView.image = UIImage(named: "icon-navbar-review")
        renameView.addSubview(infoImageView)
        infoImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(renameView)
            make.left.equalTo(28)
        }
        let infoLabel = UILabel()
        infoLabel.text = "Rename"
        infoLabel.textColor = COLOR_navItemText
        infoLabel.font = UIFont.boldSystemFont(ofSize: 18)
        renameView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(renameView)
            make.left.equalTo(infoImageView.snp.right).offset(12)
        }
        selectView = UIControl()
        selectView.clipsToBounds = true
        selectView.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            self?.dismiss()
            self?.delegate.onOneActionTapped(action: .select)
        }
        contentView.addSubview(selectView)
        selectView.snp.makeConstraints { (make) in
            make.height.equalTo(68)
            make.width.left.equalTo(contentView)
            make.top.equalTo(renameView.snp.bottom)
            make.bottom.equalTo(0)
        }
        let reviewImageView = UIImageView()
        reviewImageView.image = UIImage(named: "folder_select_icon")
        selectView.addSubview(reviewImageView)
        reviewImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(selectView)
            make.left.equalTo(28)
        }
        let reviewLabel = UILabel()
        reviewLabel.text = "Select"
        reviewLabel.textColor = COLOR_navItemText
        reviewLabel.font = UIFont.boldSystemFont(ofSize: 18)
        selectView.addSubview(reviewLabel)
        reviewLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(selectView)
            make.left.equalTo(reviewImageView.snp.right).offset(12)
        }       
    }

    @objc func dismiss() {
        self.isHidden = true
    }

    func display() {
        self.isHidden = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension FolderNavigationItemView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: contentView) {
            return false
        } else {
            return true
        }
    }
}
