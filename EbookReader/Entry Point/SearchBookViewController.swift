//
//  SearchBookViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/9.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import UIKit
import Mantle

class SearchBookViewController: UIViewController {
    fileprivate var tableView: UITableView!
    fileprivate var searchBar: UISearchBar!

    fileprivate var dataSource: [Book] = []
    fileprivate var searchText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        self.view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(100)
            make.height.equalTo(40)
            make.width.equalTo(600)
        }

        tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(searchBar.snp.bottom).offset(30)
            make.bottom.equalTo(-50)
        }
    }

    fileprivate func searchBook() {
        PopupView.showLoading(true)
        NetworkManager.sharedInstance().GET(path: "search",
            parameters: ["lookfor": self.searchText],
            modelClass: Book.self,
            success: { (books) in
                if let books = books as? [Book] {
                    self.dataSource = books
                    self.tableView.reloadData()
                }
                PopupView.showLoading(false)
            }, failure:  { (error) in
                PopupView.showLoading(false)
            })
    }
}

extension SearchBookViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBook()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 1 {
            return
        }
        self.searchText = searchText
    }
}

extension SearchBookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "book")
        cell.textLabel?.text = dataSource[indexPath.row].title
        if let authors = dataSource[indexPath.row].authorsPrimary {
            cell.detailTextLabel?.text = "Author: "
            for author in authors {
                cell.detailTextLabel?.text! += author + " "
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = dataSource[indexPath.row]
        let viewController = DownloadViewController(book: book)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
