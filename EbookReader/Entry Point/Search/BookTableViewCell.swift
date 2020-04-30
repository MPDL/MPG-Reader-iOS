//
//  BookTableViewCell.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/29.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import Kingfisher

class BookTableViewCell: UITableViewCell {

    fileprivate var bookImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var authorLabel: UILabel!
    fileprivate var publicationDateLabel: UILabel!
    fileprivate var publicationPressLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none

        let contentWrapper = UIView()
        contentWrapper.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.88)
        contentWrapper.layer.cornerRadius = 12
        contentWrapper.layer.masksToBounds = true
        self.contentView.addSubview(contentWrapper)
        contentWrapper.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
        }

        bookImageView = UIImageView()
        contentWrapper.addSubview(bookImageView)
        bookImageView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.bottom.equalTo(-15)
            make.left.equalTo(30)
            make.width.equalTo(115)
            make.height.equalTo(150)
        }

        titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1)
        contentWrapper.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(bookImageView.snp.right).offset(40)
            make.right.equalTo(-30)
            make.width.lessThanOrEqualTo(530)
        }

        publicationDateLabel = UILabel()
        contentWrapper.addSubview(publicationDateLabel)
        publicationDateLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(bookImageView)
            make.left.equalTo(titleLabel)
        }

        publicationPressLabel = UILabel()
        contentWrapper.addSubview(publicationPressLabel)
        publicationPressLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(publicationDateLabel)
            make.left.equalTo(publicationDateLabel.snp.right).offset(10)
        }

        authorLabel = UILabel()
        contentWrapper.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(publicationDateLabel.snp.top).offset(-10)
            make.left.equalTo(titleLabel)
        }

        let footer = UIView()
        self.contentView.addSubview(footer)
        footer.snp.makeConstraints { (make) in
            make.top.equalTo(contentWrapper.snp.bottom)
            make.height.equalTo(20)
            make.left.right.bottom.equalTo(0)
        }

    }

    func setObject(book: Book) {
        bookImageView.kf.setImage(with: URL(string: book.thumbnail))
        titleLabel.text = book.title
        if (book.authorsPrimary.count > 0) {
            var text = "Author: "
            for author in book.authorsPrimary {
                text = text + author + ", "
            }
            text = String(text.dropLast(2))
            authorLabel.text = text
        }
        if (book.publicationDates.count > 0) {
            publicationDateLabel.text = book.publicationDates[0]
        }
        if (book.publishers.count > 0) {
            publicationPressLabel.text = book.publishers[0]
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
