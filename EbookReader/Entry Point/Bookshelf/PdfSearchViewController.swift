//
//  PdfSearchViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/22.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import PDFKit

@objc protocol PdfSearchViewControllerDelegate: class {
    @objc optional func didSelectSearchResult(_ selection: PDFSelection)
}

class PdfSearchViewController: UIViewController {

    fileprivate var tableView: UITableView!
    fileprivate var searchBar: UISearchBar!
    fileprivate var dataSource: NSMutableArray!

    fileprivate var delegate: PdfSearchViewControllerDelegate!
    fileprivate var document: PDFDocument!

    init(document: PDFDocument, delegate: PdfSearchViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.document = document
        self.delegate = delegate
        self.dataSource = NSMutableArray()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = COLOR_background

        let headerView = UIView()
        headerView.backgroundColor = COLOR_pdfReaderHeader
        self.view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(70)
        }
        let closeImageView = UIImageView()
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCloseTapped)))
        closeImageView.image = UIImage(named: "navi-close")
        headerView.addSubview(closeImageView)
        closeImageView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(headerView).offset(10)
        }

        searchBar = UISearchBar()
        searchBar.setImage(UIImage(named: "icon-input-search"), for: .search, state: .normal)
        searchBar.tintColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
            textField.backgroundColor = UIColor.white
        }
        headerView.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.centerX.equalTo(headerView)
            make.centerY.equalTo(headerView).offset(10)
            make.height.equalTo(40)
            make.width.equalTo(600)
        }

        // Do any additional setup after loading the view.
        tableView = UITableView()
        tableView.register(PdfSearchTableViewCell.self, forCellReuseIdentifier: String(describing: PdfSearchTableViewCell.self))
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
    }

    @objc func onCloseTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PdfSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        document.cancelFindString()
        self.dismiss(animated: true, completion: nil)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 1 {
            return
        }
        dataSource.removeAllObjects()
        tableView.reloadData()

        document.cancelFindString()
        document.delegate = self
        document.beginFindString(searchText, withOptions: .caseInsensitive)
        
    }
}

extension PdfSearchViewController: PDFDocumentDelegate {
    func didMatchString(_ instance: PDFSelection) {
        dataSource.add(instance)
        tableView.reloadData()
    }
}

extension PdfSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PdfSearchTableViewCell.self)) as! PdfSearchTableViewCell
        if let selection = dataSource[indexPath.row] as? PDFSelection {
            let extendSelection: PDFSelection = selection.copy() as! PDFSelection
            extendSelection.extend(atStart: 0)
            extendSelection.extend(atEnd: 90)
            extendSelection.extendForLineBoundaries()

            var outline = document.outlineItem(for: selection)
            while outline?.parent?.parent != nil && outline?.parent?.parent?.parent != nil {
                outline = outline?.parent
            }

            let range = (extendSelection.string! as NSString).range(of: selection.string!, options: .caseInsensitive)
            let attributedString = NSMutableAttributedString(string: extendSelection.string!)
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.75, green: 0.19, blue: 0.25,alpha:1), range: range)
            cell.titleLabel?.text = outline?.label
            cell.contentLabel?.attributedText = attributedString
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selection = dataSource[indexPath.row] as? PDFSelection {
            delegate.didSelectSearchResult?(selection)
            self.dismiss(animated: true, completion: nil)
        }
    }


}
