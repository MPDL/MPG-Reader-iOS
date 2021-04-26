//
//  BookFolderHandlerTableViewCell.swift
//  EbookReader
//
//  Created by ysq on 2021/4/1.
//  Copyright © 2021 CN. All rights reserved.
//

import UIKit

class BookFolderHandleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var centerTitleLabel: UILabel!
    @IBOutlet weak var rightSelectImageView: UIImageView!
    
    var isMoveOutCell = false
    var isFolderAddCell = false
    var isDefaultCell = true
    var folderName = ""
    var isFolderNameSelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = COLOR_overlayView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup() {
        if (isMoveOutCell) {
            self.rightSelectImageView.isHidden = true
            self.leftIconImageView.image = UIImage(named: "move_out")
            self.centerTitleLabel.text = "Move Book Out of Folder"
            self.centerTitleLabel.textColor = UIColor(red: 0, green: 159/255.0, blue: 161/255.0, alpha: 1)
        } else if (isFolderAddCell) {
            self.rightSelectImageView.isHidden = true
            self.leftIconImageView.image = UIImage(named: "folder_add")
            self.centerTitleLabel.text = "New Folder"
            self.centerTitleLabel.textColor = UIColor(red: 0, green: 159/255.0, blue: 161/255.0, alpha: 1)
        } else {
            self.rightSelectImageView.isHidden = false
            self.leftIconImageView.image = UIImage(named: "folder_mini")
            self.centerTitleLabel.text = folderName
            self.centerTitleLabel.textColor = COLOR_overlayText
            self.rightSelectImageView.image = self.isFolderNameSelected ? UIImage(named: "folder_select") : UIImage(named: "folder_no_select")
        }
    }
    
}
