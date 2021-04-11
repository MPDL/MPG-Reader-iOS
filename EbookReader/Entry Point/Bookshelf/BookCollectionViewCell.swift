//
//  BookCollectionViewCell.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/29.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import Kingfisher

class BookCollectionViewCell: UICollectionViewCell {
    fileprivate var bookImageView: UIImageView!
    fileprivate var bookLabel: UILabel!

    var checkButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        bookImageView = UIImageView()
        bookImageView.layer.cornerRadius = 8
        bookImageView.layer.masksToBounds = true
        self.contentView.addSubview(bookImageView)
        bookImageView.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(200)
            make.left.right.top.equalTo(0)
        }

        bookLabel = UILabel()
        bookLabel.numberOfLines = 2
        self.contentView.addSubview(bookLabel)
        bookLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(bookImageView)
            make.bottom.equalTo(0)
            make.top.equalTo(bookImageView.snp.bottom).offset(17)
        }

        checkButton = UIButton()
        checkButton.isHidden = true
        checkButton.isUserInteractionEnabled = false
        checkButton.setImage(UIImage(named: "icon-selected"), for: .selected)
        checkButton.setImage(UIImage(named: "icon-selected-not"), for: .normal)
        bookImageView.addSubview(checkButton)
        checkButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
    }

    func setObject(book: Book) {
        if (book.folder) {
            bookImageView.image = UIImage(named: "folder")
        } else if let thumbnail = book.thumbnail {
            bookImageView.kf.setImage(with: URL(string: thumbnail))
        } else {
            bookImageView.image = UIImage(named: "default-book-cover")
        }
        bookLabel.text = book.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
