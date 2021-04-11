//
//  BookFolderHandleNameView.swift
//  EbookReader
//
//  Created by ysq on 2021/4/1.
//  Copyright © 2021 CN. All rights reserved.
//

import UIKit

class BookFolderHandleNameView: UIView {
    var cancelBlock: (()->())?
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var textFieldView: UIView!
    var doneBlock: (()->())?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        footerView.backgroundColor = COLOR_overlayView
        contentView.backgroundColor = COLOR_overlayView
        titleLabel.textColor = COLOR_overlayText
        cancelButton.setTitleColor(COLOR_overlayText, for: .normal)
        doneButton.setTitleColor(COLOR_overlayText, for: .normal)
        nameTextField.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        textFieldView.backgroundColor = UIColor { (tc) -> UIColor in
            return tc.userInterfaceStyle == .light ? UIColor(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1) : UIColor(red: 83/255.0, green: 83/255.0, blue: 83/255.0, alpha: 1)
        }
    }

    @objc fileprivate func tapBackgroundView(_ sender: Any) {
        self.hide()
    }
    @IBAction func clickOnCancelButton(_ sender: Any) {
        self.hide()
        cancelBlock?()
    }
    @IBAction func clickOnDoneButton(_ sender: Any) {
        doneBlock?()
    }
    func show() {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        } completion: { (finish) in
            
        }
    }
    func hide() {
        nameTextField.resignFirstResponder()
        self.alpha = 1
        self.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { (finish) in
            self.isHidden = true
        }
    }
}
