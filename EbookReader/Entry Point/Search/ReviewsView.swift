//
//  ReviewsView.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/6.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import TTTAttributedLabel

let kCharacterBeforReadMore =  240

class ReviewsView: UIScrollView {

    fileprivate var reviews: [Review] = []

    init(reviews: [Review]) {
        super.init(frame: .zero)

        self.reviews = reviews
        var last: UIView?

        let contentView = UIView()
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
            make.width.equalTo(self)
        }

        for index in 0..<reviews.count {
            let review = reviews[index]
            let view = generateOneReviewView(review: review, index: index)
            contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.left.right.equalTo(0)
                if let last = last {
                    make.top.equalTo(last.snp.bottom).offset(15)
                } else {
                    make.top.equalTo(0)
                }
                if index == reviews.count - 1 {
                    make.bottom.equalTo(-15)
                }
            }
            last = view
        }
    }
    fileprivate func generateOneReviewView(review: Review, index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF2F2F5)

        let profileImageView = UIImageView()
        profileImageView.image = UIImage(named: "avatar")
        profileImageView.layer.cornerRadius = 25
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.top.equalTo(13)
            make.left.equalTo(27)
        }
        let nameLabel = UILabel()
        if let userName = review.userName, userName != "" {
            nameLabel.text = review.userName
        } else {
            nameLabel.text = "MPG Reader User"
        }
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.equalTo(profileImageView.snp.right).offset(20)
        }
        let starImageView = UIImageView()
        starImageView.image = UIImage(named: "icon-star-\(String(describing: review.rating ?? 0))")
        view.addSubview(starImageView)
        starImageView.snp.makeConstraints { (make) in
            make.width.equalTo(130)
            make.height.equalTo(22)
            make.left.equalTo(profileImageView.snp.right).offset(16)
            make.top.equalTo(nameLabel.snp.bottom).offset(7)
        }
        var commentsLabel: UILabel!
        if let count = review.comment?.count, count < kCharacterBeforReadMore {
            commentsLabel = UILabel()
            commentsLabel.text = review.comment!
            commentsLabel.textColor = COLOR_downloadViewReviewComment
            commentsLabel.font = UIFont.systemFont(ofSize: 16)
        } else {
            commentsLabel = TTTAttributedLabel(frame: .zero)
            (commentsLabel as! TTTAttributedLabel).showTextOnTTTAttributeLabel(originText: review.comment!, charatersBeforeReadMore: kCharacterBeforReadMore, isReadMoreTapped: false, isReadLessTapped: false)
            (commentsLabel as! TTTAttributedLabel).delegate = self
        }
        commentsLabel.tag = index
        view.addSubview(commentsLabel)
        commentsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).offset(22)
            make.left.equalTo(profileImageView).offset(13)
            make.right.equalTo(-40)
        }
        let dateLabel = UILabel()
        dateLabel.text = review.createDate?.dateString()
        dateLabel.textColor = UIColor(hex: 0x999999)
        dateLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(commentsLabel)
            make.top.equalTo(commentsLabel.snp.bottom).offset(18)
            make.bottom.equalTo(-20)
        }
        let organizationLabel = UILabel()
        organizationLabel.text = review.organization ?? ""
        organizationLabel.textColor = UIColor(hex: 0x999999)
        organizationLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(organizationLabel)
        organizationLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dateLabel.snp.right).offset(15)
            make.centerY.equalTo(dateLabel)
        }
        return view
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ReviewsView: TTTAttributedLabelDelegate {
    func readMore(label: TTTAttributedLabel, fullStr: String, readMore: Bool) {
        label.showTextOnTTTAttributeLabel(originText: fullStr, charatersBeforeReadMore: kCharacterBeforReadMore, isReadMoreTapped: readMore, isReadLessTapped: false)
    }
    
    func readLess(label: TTTAttributedLabel, fullStr: String, readLess: Bool) {
        label.showTextOnTTTAttributeLabel(originText: fullStr, charatersBeforeReadMore: kCharacterBeforReadMore, isReadMoreTapped: readLess, isReadLessTapped: true)
    }

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable : Any]!) {
        if let _ = components as? [String: String] {
            if let value = components[kReadMoreLink] as? String, value == kChosenKey {
                self.readMore(label: label, fullStr: reviews[label.tag].comment!, readMore: true)
            }
            if let value = components[kReadLessLink] as? String, value == kChosenKey {
                self.readLess(label: label, fullStr: reviews[label.tag].comment!, readLess: true)
            }
        }
    }
}
