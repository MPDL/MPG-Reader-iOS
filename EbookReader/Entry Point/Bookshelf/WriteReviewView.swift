//
//  WriteReviewView.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/6.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit

class WriteReviewView: UIView {

    fileprivate var starImageViewList: [UIImageView] = []
    fileprivate var organizationSwitch: UISwitch!
    fileprivate var rating: String = "five"
    fileprivate var book: Book!

    init(book: Book) {
        super.init(frame: .zero)
        self.book = book
        self.backgroundColor = UIColor(white: 0, alpha: 0.6)
        self.isHidden = true

        let writeReviewView = UIView()
        writeReviewView.layer.cornerRadius = 10
        writeReviewView.backgroundColor = UIColor.white
        self.addSubview(writeReviewView)
        writeReviewView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(10)
            make.width.equalTo(630)
            make.height.equalTo(780)
        }
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "icon-write-review")
        writeReviewView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(writeReviewView)
            make.top.equalTo(writeReviewView).offset(-30)
        }
        let closeImageView = UIImageView()
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        closeImageView.image = UIImage(named: "icon-dialog-close")
        writeReviewView.addSubview(closeImageView)
        closeImageView.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.right.equalTo(-20)
        }
        let titleLabel = UILabel()
        titleLabel.text = "Write a review"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor(hex: 0x333333)
        writeReviewView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(writeReviewView)
            make.top.equalTo(50)
        }
        let bookImageView = UIImageView()
        bookImageView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        bookImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bookImageView.layer.shadowOpacity = 1
        bookImageView.layer.shadowRadius = 4
        if let url = book.thumbnail {
            bookImageView.kf.setImage(with: URL(string: url))
        }
        writeReviewView.addSubview(bookImageView)
        bookImageView.snp.makeConstraints { (make) in
            make.width.equalTo(83)
            make.height.equalTo(110)
            make.top.equalTo(titleLabel.snp.bottom).offset(21)
            make.left.equalTo(68)
        }
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.text = book.title
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        nameLabel.textColor = UIColor(hex: 0x333333)
        writeReviewView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bookImageView)
            make.left.equalTo(bookImageView.snp.right).offset(29)
            make.right.equalTo(-30)
        }
        let question1Label = UILabel()
        question1Label.text = "1. How do you think of this book? "
        question1Label.textColor = UIColor(hex: 0x333333)
        question1Label.font = UIFont.boldSystemFont(ofSize: 18)
        writeReviewView.addSubview(question1Label)
        question1Label.snp.makeConstraints { (make) in
            make.top.equalTo(bookImageView.snp.bottom).offset(27)
            make.left.equalTo(bookImageView)
        }
        let starView = generateStarView()
        writeReviewView.addSubview(starView)
        starView.snp.makeConstraints { (make) in
            make.top.equalTo(question1Label.snp.bottom).offset(15)
            make.left.equalTo(question1Label)
        }
        let question2Label = UILabel()
        question2Label.text = "2. Share your thoughts with other users:"
        question2Label.textColor = UIColor(hex: 0x333333)
        question2Label.font = UIFont.boldSystemFont(ofSize: 18)
        writeReviewView.addSubview(question2Label)
        question2Label.snp.makeConstraints { (make) in
            make.top.equalTo(starView.snp.bottom).offset(27)
            make.left.equalTo(bookImageView)
        }
        let textArea = UITextView()
        textArea.font = UIFont.systemFont(ofSize: 16)
        textArea.layer.borderWidth = 1
        textArea.layer.borderColor = UIColor(hex: 0x333333).cgColor
        textArea.layer.cornerRadius = 4
        writeReviewView.addSubview(textArea)
        textArea.snp.makeConstraints { (make) in
            make.width.equalTo(502)
            make.height.equalTo(110)
            make.top.equalTo(question2Label.snp.bottom).offset(15)
            make.centerX.equalTo(writeReviewView)
        }
        let question3Label = UILabel()
        question3Label.text = "3. What's your name?"
        question3Label.textColor = UIColor(hex: 0x333333)
        question3Label.font = UIFont.boldSystemFont(ofSize: 18)
        writeReviewView.addSubview(question3Label)
        question3Label.snp.makeConstraints { (make) in
            make.top.equalTo(textArea.snp.bottom).offset(27)
            make.left.equalTo(bookImageView)
        }
        let textField = UITextView()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0x333333).cgColor
        textField.layer.cornerRadius = 4
        writeReviewView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.width.equalTo(502)
            make.height.equalTo(40)
            make.top.equalTo(question3Label.snp.bottom).offset(15)
            make.centerX.equalTo(writeReviewView)
        }
        let question4Label = UILabel()
        question4Label.text = "4. Display your organization in the review"
        question4Label.textColor = UIColor(hex: 0x333333)
        question4Label.font = UIFont.boldSystemFont(ofSize: 18)
        writeReviewView.addSubview(question4Label)
        question4Label.snp.makeConstraints { (make) in
            make.top.equalTo(textField.snp.bottom).offset(27)
            make.left.equalTo(bookImageView)
        }
        organizationSwitch = UISwitch()
        organizationSwitch.onTintColor = UIColor(hex: 0x009FA1)
        organizationSwitch.isOn = true
        writeReviewView.addSubview(organizationSwitch)
        organizationSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(question4Label)
            make.left.equalTo(question4Label.snp.right).offset(18)
        }
        let submitView = UIControl()
        submitView.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            guard let self = self else {
                return
            }
            let parameters = [
                "bookId": book.id,
                "comment": textArea.text ?? "",
                "name": textField.text ?? "",
                "rating": self.rating,
                "showOrg": self.organizationSwitch.isOn
            ] as [String : Any]
            NetworkManager.sharedInstance().POST(
                path: "rest/user/review",
                parameters: parameters,
                modelClass: Review.self,
                success: { (review) in
                    PopupView.showLoading(false)
                    self.dismiss()
                    NotificationCenter.default.post(name: .reviewDidAdd, object: nil)
                    PopupView.showWithContent("Thanks!")
                }, failure: nil)
        }
        submitView.layer.cornerRadius = 8
        submitView.backgroundColor = UIColor(hex: 0x009FA1)
        writeReviewView.addSubview(submitView)
        submitView.snp.makeConstraints { (make) in
            make.width.equalTo(220)
            make.height.equalTo(50)
            make.centerX.equalTo(writeReviewView)
            make.top.equalTo(organizationSwitch.snp.bottom).offset(50)
        }
        let submitLabel = UILabel()
        submitLabel.text = "Submit"
        submitLabel.textColor = UIColor.white
        submitLabel.font = UIFont.boldSystemFont(ofSize: 20)
        submitView.addSubview(submitLabel)
        submitLabel.snp.makeConstraints { (make) in
            make.center.equalTo(submitView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display() {
        self.isHidden = false
    }

    @objc func dismiss() {
        self.isHidden = true
    }

    fileprivate func generateStarView() -> UIView {
        let view = UIView()
        var last: UIView?
        for i in 0..<5 {
            let starImageView = UIImageView()
            starImageView.image = UIImage(named: "star-solid")
            starImageView.isUserInteractionEnabled = true
            starImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStarTapped(sender:))))
            starImageView.tag = i
            view.addSubview(starImageView)
            starImageView.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(view)
                if let last = last {
                    make.left.equalTo(last.snp.right).offset(12)
                } else {
                    make.left.equalTo(0)
                }
                if i == 4 {
                    make.right.equalTo(0)
                }
            }
            last = starImageView
            starImageViewList.append(starImageView)
        }
        return view
    }

    @objc func onStarTapped(sender: UIGestureRecognizer) {
        if let view = sender.view {
            for i in 0...view.tag {
                starImageViewList[i].image = UIImage(named: "star-solid")
            }
            for i in (view.tag + 1)..<5 {
                starImageViewList[i].image = UIImage(named: "star-empty")
            }
            switch view.tag {
                case 0:
                    self.rating = "one"
                    break
                case 1:
                    self.rating = "two"
                    break
                case 2:
                    self.rating = "three"
                    break
                case 3:
                    self.rating = "four"
                    break
                case 4:
                    self.rating = "five"
                    break
                default:
                    self.rating = "five"
            }
        }
    }

}
