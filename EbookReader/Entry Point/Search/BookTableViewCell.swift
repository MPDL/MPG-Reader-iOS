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
    fileprivate var separator: UIView!

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
            make.height.equalTo(180)
        }

        bookImageView = UIImageView()
        contentWrapper.addSubview(bookImageView)
        bookImageView.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.width.equalTo(115)
            make.height.equalTo(150)
            make.centerY.equalTo(contentWrapper)
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
        }

        publicationDateLabel = UILabel()
        publicationDateLabel.font = UIFont.italicSystemFont(ofSize: 14)
        publicationDateLabel.textColor = UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1)
        contentWrapper.addSubview(publicationDateLabel)
        publicationDateLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(bookImageView)
            make.left.equalTo(titleLabel)
        }

        publicationPressLabel = UILabel()
        publicationPressLabel.font = UIFont.italicSystemFont(ofSize: 14)
        publicationPressLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        contentWrapper.addSubview(publicationPressLabel)
        publicationPressLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(publicationDateLabel)
            make.left.equalTo(publicationDateLabel.snp.right).offset(10)
        }

        authorLabel = UILabel()
        authorLabel.numberOfLines = 1
        authorLabel.font = UIFont.boldSystemFont(ofSize: 16)
        authorLabel.textColor = UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1)
        contentWrapper.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(publicationDateLabel.snp.top).offset(-10)
            make.left.equalTo(titleLabel)
            make.right.equalTo(-30)
        }

        separator = UIView()
        separator.isHidden = true
        separator.backgroundColor = UIColor(red: 0.81, green: 0.81, blue: 0.81, alpha: 1)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.left.equalTo(36)
            make.right.equalTo(-44)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
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

    func checkMatch(searchText: String) {
        separator.isHidden = false
        if let text = titleLabel.text as NSString? {
            let titleRange = text.range(of: searchText, options: .caseInsensitive)
            let titleAttributedString = NSMutableAttributedString(string: titleLabel.text!)
            titleAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.75, green: 0.19, blue: 0.25,alpha:1), range: titleRange)
            titleLabel.attributedText = titleAttributedString
        }

        if let text = authorLabel.text as NSString? {
            let authorRange = text.range(of: searchText, options: .caseInsensitive)
            let authorAttributedString = NSMutableAttributedString(string: authorLabel.text!)
            authorAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.75, green: 0.19, blue: 0.25,alpha:1), range: authorRange)
            authorLabel.attributedText = authorAttributedString
        }

        if let text = publicationPressLabel.text as NSString? {
            let pressRange = text.range(of: searchText, options: .caseInsensitive)
            let pressAttributedString = NSMutableAttributedString(string: publicationPressLabel.text!)
            pressAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.75, green: 0.19, blue: 0.25,alpha:1), range: pressRange)
            publicationPressLabel.attributedText = pressAttributedString
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
