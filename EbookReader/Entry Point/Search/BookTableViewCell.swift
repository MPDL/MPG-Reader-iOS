//
//  BookTableViewCell.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/29.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {

    fileprivate var bookImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var authorLabel: UILabel!
    fileprivate var publicationDateLabel: UILabel!
    fileprivate var publicationPressLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        bookImageView = UIImageView()
        self.contentView.addSubview(bookImageView)
        bookImageView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.bottom.equalTo(-15)
            make.left.equalTo(30)
        }

        titleLabel = UILabel()
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }

        authorLabel = UILabel()
        self.contentView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(30)
        }

        publicationDateLabel = UILabel()
        self.contentView.addSubview(publicationDateLabel)
        publicationDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(authorLabel.snp.bottom).offset(15)
            make.left.equalTo(30)
        }

        publicationPressLabel = UILabel()
        self.contentView.addSubview(publicationPressLabel)
        publicationPressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(publicationDateLabel)
            make.left.equalTo(publicationDateLabel.snp.right).offset(10)
        }

    }

    func setObject(book: Book) {

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
