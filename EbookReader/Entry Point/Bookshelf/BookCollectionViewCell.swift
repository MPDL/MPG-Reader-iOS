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
    fileprivate var selectImageView: UIImageView!
    fileprivate var isEditing = false

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

        selectImageView = UIImageView()
        bookImageView.addSubview(selectImageView)
        selectImageView.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
    }

    func setObject(book: Book) {
        bookImageView.kf.setImage(with: URL(string: book.thumbnail))
        bookLabel.text = book.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
