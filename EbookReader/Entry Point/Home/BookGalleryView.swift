//
//  BookGalleryScrollView.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/5.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import SnapKit

enum GalleryType {
    case searchHistory
    case readingList
    case mostDownloaded
    case topRated
}

protocol BookGalleryViewDelegate: class {
    func onScrollViewReachBottom(galleryType: GalleryType)
    func onBookSelected(bookId: String)
}

class BookGalleryView: UIView {
    fileprivate var scrollView: UIScrollView!
    fileprivate var contentView: UIView!
    fileprivate var galleryType: GalleryType!
    fileprivate var delegate: BookGalleryViewDelegate?
    fileprivate var last: UIView?
    fileprivate var lastConstraint: Constraint?

    init(title: String, galleryType: GalleryType, delegate: BookGalleryViewDelegate?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        self.galleryType = galleryType
        self.delegate = delegate

        let separator = UIView()
        separator.backgroundColor = UIColor(hex: 0xCFCFCF)
        self.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(1)
        }

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(hex: 0x999999)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(separator.snp.bottom).offset(19)
            make.left.equalTo(15)
        }

        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.bottom.equalTo(-41)
            make.left.right.equalTo(0)
        }

        contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.height.equalTo(scrollView)
        }
        self.layoutIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func clear() {
        lastConstraint = nil
        last = nil
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
    }

    func appendBooks(books: [BookStatistic]) {
        if let lastConstraint = lastConstraint {
            lastConstraint.deactivate()
        }
        for index in 0..<books.count {
            let book = books[index]
            let bookView = generateBookView(book: book)
            contentView.addSubview(bookView)
            bookView.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(contentView)
                if let last = last {
                    make.left.equalTo(last.snp.right).offset(15)
                } else {
                    make.left.equalTo(contentView).offset(8)
                }
                if index == books.count - 1 {
                    lastConstraint = make.right.equalTo(contentView).constraint
                }
            }
            last = bookView
        }
    }

    fileprivate func generateBookView(book: BookStatistic) -> UIControl {
        let view = UIControl()
        view.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            guard let self = self, let delegate = self.delegate, let bookId = book.bookId else {
                return
            }
            delegate.onBookSelected(bookId: bookId)
        }
        let imageView = UIImageView()
        if let url = book.bookCoverURL {
            imageView.kf.setImage(with: URL(string: url))
        } else {
            imageView.image = UIImage(named: "default-book-cover")
        }
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(view)
            make.width.equalTo(138)
            make.height.equalTo(180)
        }
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = book.bookName
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(13)
            make.centerX.equalTo(view)
            make.bottom.equalTo(0)
            make.width.equalTo(view)
        }
        return view
    }
}

extension BookGalleryView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let contentXOffset = scrollView.contentOffset.x
        let distanceFromBottom = scrollView.contentSize.width - contentXOffset
        if let delegate = self.delegate, distanceFromBottom <= width {
            // reach bottom already
            delegate.onScrollViewReachBottom(galleryType: self.galleryType)
        }
    }
}


