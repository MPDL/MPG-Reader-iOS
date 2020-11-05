//
//  TTTAttributedLabel+More.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/9.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import TTTAttributedLabel

let kReadMoreText = "...Read More"
let kReadLessText = "...Read Less"
let kReadMoreLink = "Read More"
let kReadLessLink = "Read Less"
let kChosenKey = "1"

extension TTTAttributedLabel {

    func showTextOnTTTAttributeLabel(originText: String, charatersBeforeReadMore: Int, isReadMoreTapped: Bool, isReadLessTapped: Bool) {
        let actionTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(hex: 0x71BDD9),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ]
        let normalTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(hex: 0x333333),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ]

        let originTextWithLess = originText + kReadLessText
        let attributedFullText = NSMutableAttributedString.init(string: originTextWithLess)
        let rangeLess = NSString(string: originTextWithLess).range(of: kReadLessText, options: String.CompareOptions.caseInsensitive)
        let rangeOrigin = NSString(string: originTextWithLess).range(of: originText)
        attributedFullText.addAttributes(actionTextAttributes, range: rangeLess)
        attributedFullText.addAttributes(normalTextAttributes, range: rangeOrigin)

        var subStringWithReadMore = ""
        if originText.count > charatersBeforeReadMore {
            subStringWithReadMore = String(originText.prefix(charatersBeforeReadMore)) + kReadMoreText
        }
        let attributedLessText = NSMutableAttributedString.init(string: subStringWithReadMore)
        let nsRange = NSString(string: subStringWithReadMore).range(of: kReadMoreText, options: String.CompareOptions.caseInsensitive)
        attributedLessText.addAttributes(actionTextAttributes, range: nsRange)
        attributedLessText.addAttributes(normalTextAttributes, range: NSMakeRange(0, charatersBeforeReadMore))

        self.numberOfLines = 0
        self.attributedText = attributedLessText
        self.activeLinkAttributes = actionTextAttributes
        self.linkAttributes = actionTextAttributes
        self.addLink(toTransitInformation: [kReadMoreLink: kChosenKey], with: nsRange)

        if isReadMoreTapped {
            self.numberOfLines = 0
            self.attributedText = attributedFullText
            self.addLink(toTransitInformation: [kReadLessLink: kChosenKey], with: rangeLess)
        }
        if isReadLessTapped {
            self.numberOfLines = 3
            self.attributedText = attributedLessText
        }
    }
}

