//
//  SearchBookViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/9.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class TitleSearchBar: UISearchBar {
    override public var intrinsicContentSize: CGSize {
        return CGSize.init(width: 180, height: 44)
    }
}

class SearchBookViewController: UIViewController {
    fileprivate var tableView: UITableView!
    fileprivate var searchBar: UISearchBar!
    fileprivate var historyView: UIView!
    fileprivate var historyTitleLabel: UILabel!
    fileprivate var trashImageView: UIImageView!

    fileprivate var dataSource: [Book] = []
    fileprivate var searchText: String = ""
    fileprivate var histories: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 40))
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 400, height: 40))
        titleView.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        self.navigationItem.titleView = titleView

        historyView = UIView()
        self.view.addSubview(historyView)
        historyView.snp.makeConstraints { (make) in
            make.top.left.equalTo(30)
            make.right.equalTo(-30)
        }
        historyTitleLabel = UILabel()
        historyTitleLabel.text = "Recent Search"
        historyView.addSubview(historyTitleLabel)
        historyTitleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
        }
        trashImageView = UIImageView()
        historyView.addSubview(trashImageView)
        trashImageView.snp.makeConstraints { (make) in
            make.right.top.equalTo(0)
        }

        tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: String(describing: BookTableViewCell.self))
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(historyView.snp.bottom).offset(30)
            make.bottom.equalTo(-50)
        }

        loadHistories()
    }

    fileprivate func updateHistories() {
        // todo
    }

    fileprivate func loadHistories() {
        if let histories = prefs.value(forKey: inputKey) as? [String], !histories.isEmpty {
            historyView.isHidden = false
            self.histories = histories
            self.updateHistories()
        } else {
            historyView.isHidden = true
        }
    }

    fileprivate func searchBook() {
        PopupView.showLoading(true)
        NetworkManager.sharedInstance().GET(path: "search",
            parameters: ["lookfor": self.searchText],
            modelClass: Book.self,
            success: { (books) in
                guard let books = books as? [Book]  else {
                    return
                }
                // Caching last 3 items
                var histories = Queue<Book>()
                if let saved = prefs.value(forKey: bookHistoryKey) as? Queue<Book> {
                    histories = saved
                }
                for i in 0..<min(books.count, 3) {
                    histories.enqueue(books[i])
                }
                while histories.count > 3 {
                    _ = histories.dequeue()
                }
                let encoded = try! NSKeyedArchiver.archivedData(withRootObject: histories, requiringSecureCoding: true)
                prefs.setValue(encoded, forKey: bookHistoryKey)
                prefs.synchronize()


                self.dataSource = books
                self.tableView.reloadData()

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

        var histories: [String] = []
        if let saved = prefs.value(forKey: inputKey) as? [String] {
            histories = saved
            if let index = histories.firstIndex(of: self.searchText) {
                histories.remove(at: index)
            } else if histories.count >= 10 {
                histories.removeLast()
            }
            histories.insert(self.searchText, at: 0)
        } else {
            histories.append(self.searchText)
        }
        let encoded = try! NSKeyedArchiver.archivedData(withRootObject: histories, requiringSecureCoding: true)
        prefs.setValue(encoded, forKey: inputKey)
        prefs.synchronize()

        updateHistories()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BookTableViewCell.self)) as! BookTableViewCell
        cell.setObject(book: dataSource[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = dataSource[indexPath.row]
        let viewController = DownloadViewController(book: book)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
