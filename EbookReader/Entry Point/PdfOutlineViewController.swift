//
//  PdfOutlineViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/22.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import PDFKit

@objc protocol PdfOutlineViewControllerDelegate: class {
    @objc optional func didSelectOutline(_ outline: PDFOutline)
}

class PdfOutlineViewController: UIViewController {

    fileprivate var tableView: UITableView!

    fileprivate var document: PDFDocument!
    fileprivate var outline: PDFOutline?
    fileprivate var dataSource: NSMutableArray!
    fileprivate var delegate: PdfOutlineViewControllerDelegate!

    
    init(document: PDFDocument, delegate: PdfOutlineViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)

        self.document = document
        self.delegate = delegate
        self.outline = document.outlineRoot
        self.dataSource = NSMutableArray()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white

        let headerView = UIView()
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        self.view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(56)
        }

        let closeImageView = UIImageView()
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCloseTapped)))
        closeImageView.image = UIImage(named: "icon-navbar-close")
        headerView.addSubview(closeImageView)
        closeImageView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(headerView).offset(10)
        }

        tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(headerView.snp.bottom).offset(2)
            make.bottom.equalTo(-50)
        }

        self.setOutlineRoot()
    }

    @objc func onCloseTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    fileprivate func setOutlineRoot() {
        guard let outline = self.outline else {
            return
        }
        for index in 0..<outline.numberOfChildren {
            if let oneOutline = outline.child(at: index) {
                self.dataSource.add(oneOutline)
                // the maximum depth is 2
                for subindex in 0..<oneOutline.numberOfChildren {
                    if let oneSubOutline = oneOutline.child(at: subindex) {
                        self.dataSource.add(oneSubOutline)
                    }
                }
            }
        }
        self.tableView.reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PdfOutlineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let oneOutline = dataSource[indexPath.row] as? PDFOutline {
            if let _ = oneOutline.parent?.parent {
                cell.textLabel?.textColor = UIColor.gray
                cell.textLabel?.text = "\t" + oneOutline.label!
            } else {
                cell.textLabel?.textColor = UIColor.black
                cell.textLabel?.text = oneOutline.label
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let outline = dataSource[indexPath.row] as? PDFOutline {
            delegate.didSelectOutline?(outline)
            self.dismiss(animated: true, completion: nil)
        }
    }

}
