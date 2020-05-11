//
//  PdfSearchTableViewCell.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/5/11.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit

class PdfSearchTableViewCell: UITableViewCell {

    var titleLabel: UILabel!
    var contentLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)

        titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(16)
        }

        contentLabel = UILabel()
        contentLabel.numberOfLines = 2
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        self.contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }

        let separator = UIView()
        separator.backgroundColor = UIColor(red: 0.81, green: 0.81, blue: 0.81, alpha: 1)
        self.contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(contentLabel.snp.bottom).offset(16)
            make.bottom.equalTo(0)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
