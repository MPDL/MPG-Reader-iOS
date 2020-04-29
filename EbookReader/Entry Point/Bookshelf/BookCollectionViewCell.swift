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
        self.contentView.addSubview(bookImageView)
        bookImageView.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.height.equalTo(120)
            make.centerX.equalTo(self.contentView)
            make.top.equalTo(0)
        }

        bookLabel = UILabel()
        self.contentView.addSubview(bookLabel)
        bookLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView)
            make.top.equalTo(bookImageView.snp.bottom).offset(20)
        }

        selectImageView = UIImageView()
        bookImageView.addSubview(selectImageView)
        selectImageView.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
    }

    func setObject(book: Book) {
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
