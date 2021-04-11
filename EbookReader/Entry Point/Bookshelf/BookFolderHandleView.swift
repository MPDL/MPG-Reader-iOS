//
//  BookFolderHandleView.swift
//  EbookReader
//
//  Created by ysq on 2021/4/1.
//  Copyright © 2021 CN. All rights reserved.
//

import UIKit

class BookFolderHandleView: UIView {
    var isFileInFolder = false
    @IBOutlet weak var titleLabel: UILabel!
    var cancelBlock: (()->())?
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    var doneBlock: (()->())?
    @IBOutlet weak var contentView: UIView!
    var addNameBlock: (()->())?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = COLOR_overlayView
        headerView.backgroundColor = COLOR_overlayView
        footerView.backgroundColor = COLOR_overlayView
        tableView.backgroundColor = COLOR_overlayView
        titleLabel.textColor = COLOR_overlayText
        cancelButton.setTitleColor(COLOR_overlayText, for: .normal)
        doneButton.setTitleColor(COLOR_overlayText, for: .normal)
        tableView.register(UINib(nibName: "BookFolderHandleTableViewCell", bundle: nil), forCellReuseIdentifier: "BookFolderHandleTableViewCell")
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
        self.alpha = 1
        self.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { (finish) in
            self.isHidden = true
        }
    }
}
extension BookFolderHandleView: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!isFileInFolder && section == 0) {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookFolderHandleTableViewCell") as! BookFolderHandleTableViewCell
        cell.isMoveOutCell = indexPath.section == 0
        cell.isFolderAddCell = indexPath.section == 1
        cell.isDefaultCell = indexPath.section == 2
        cell.setup()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 1) {
            addNameBlock?()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = COLOR_overlayView
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 2) {
            return 10
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
}
