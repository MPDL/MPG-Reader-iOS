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
import ReactiveCocoa

class TitleSearchBar: UISearchBar {
    override public var intrinsicContentSize: CGSize {
        return CGSize.init(width: 180, height: 44)
    }
}

class SearchBookViewController: UIViewController {
    fileprivate var tableView: UITableView!
    fileprivate var searchBar: UISearchBar!
    fileprivate var historyView: UIView!
    fileprivate var historyContentView: UIView!
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
        searchBar.becomeFirstResponder()
        titleView.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        self.navigationItem.titleView = titleView

        historyView = UIView()
        self.view.addSubview(historyView)
        historyView.snp.makeConstraints { (make) in
            make.top.equalTo(100)
            make.left.equalTo(80)
            make.right.equalTo(-56)
        }
        historyTitleLabel = UILabel()
        historyTitleLabel.text = "Recent Search"
        historyTitleLabel.textColor = UIColor(red: 0.81, green: 0.81, blue: 0.81, alpha: 1)
        historyView.addSubview(historyTitleLabel)
        historyTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(9)
        }
        trashImageView = UIImageView()
        trashImageView.image = UIImage(named: "icon-trash")
        trashImageView.isUserInteractionEnabled = true
        trashImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTrashTapped)))
        historyView.addSubview(trashImageView)
        trashImageView.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.centerY.equalTo(historyTitleLabel)
        }
        historyContentView = UIView()
        historyView.addSubview(historyContentView)
        historyContentView.snp.makeConstraints { (make) in
            make.top.equalTo(historyTitleLabel.snp.bottom).offset(3)
            make.left.right.bottom.equalTo(0)
        }


        tableView = UITableView()
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: String(describing: BookTableViewCell.self))
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(historyView.snp.bottom)
        }
        
        loadHistories()
    }

    @objc func onTrashTapped() {
        prefs.set(nil, forKey: inputKey)
        prefs.synchronize()

        loadHistories()
    }

    fileprivate func onRecordTapped(searchString: String) {
        self.searchBar.text = searchString
        self.searchText = searchString
        self.searchBarSearchButtonClicked(self.searchBar)
    }

    fileprivate func getRecordView(record: String) -> UIView {
        let view = UIControl()
        view.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            self?.onRecordTapped(searchString: record)
        }
        view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        let maxWidth = UIScreen.main.bounds.width - 136
        view.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualTo(maxWidth)
        }

        let recordLabel = UILabel()
        recordLabel.font = UIFont.systemFont(ofSize: 12)
        recordLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        recordLabel.text = record
        view.addSubview(recordLabel)
        recordLabel.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(12)
            make.bottom.equalTo(-5)
            make.right.equalTo(-12)
        }

        view.layoutIfNeeded()

        return view
    }

    fileprivate func updateHistories() {
        for subview in historyContentView.subviews {
            subview.removeFromSuperview()
        }
        var last: UIView?
        var leftOffset: CGFloat = -20.0
        let maxWidth = UIScreen.main.bounds.width - 136
        for record in histories {
            let recordView = getRecordView(record: record)
            historyContentView.addSubview(recordView)
            let widthNeeded = recordView.bounds.width + 20
            if (leftOffset + widthNeeded) <= maxWidth {
                recordView.snp.makeConstraints({ (make) in
                    if let last = last {
                        make.left.equalTo(last.snp.right).offset(20)
                        make.centerY.equalTo(last)
                    } else {
                        make.left.equalTo(0)
                        make.top.equalTo(18)
                    }
                    if record == histories.last {
                        make.bottom.equalTo(-18)
                    }
                })
                leftOffset = leftOffset + widthNeeded
                last = recordView
            } else {
                guard let lastView = last else {
                    return
                }
                recordView.snp.makeConstraints({ (make) in
                    make.left.equalTo(0)
                    make.top.equalTo(lastView.snp.bottom).offset(18)
                    if record == histories.last {
                        make.bottom.equalTo(-18)
                    }
                })
                leftOffset = recordView.bounds.width
                last = recordView
            }
        }
    }

    fileprivate func loadHistories() {
        if let data = prefs.value(forKey: inputKey) as? Data, let histories = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String], !histories.isEmpty {
            historyContentView.isHidden = false
            self.histories = histories
            self.updateHistories()
        } else {
            historyContentView.isHidden = true
        }
    }

    fileprivate func searchBook() {
        PopupView.showLoading(true)
        NetworkManager.sharedInstance().GET(path: "search",
            parameters: ["lookfor": self.searchText],
            modelClass: Book.self,
            success: { (books) in
                guard let books = books as? [Book]  else {
                    self.dataSource = []
                    self.tableView.reloadData()
                    PopupView.showWithContent("No Results")
                    return
                }
                // Caching last 3 items
                var histories: [Book] = []
                if let data = prefs.value(forKey: bookHistoryKey) as? Data {
                    do {
                        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
                        if let saved = try unarchiver.decodeTopLevelDecodable([Book].self, forKey: NSKeyedArchiveRootObjectKey) {
                            histories = saved
                        }
                    } catch {
                        print("unarchiving failure: \(error)")
                    }
                }
                for i in 0..<min(books.count, 3) {
                    histories.append(books[i])
                }
                while histories.count > 3 {
                    _ = histories.remove(at: 0)
                }

                let archiver = NSKeyedArchiver(requiringSecureCoding: false)
                try! archiver.encodeEncodable(histories, forKey: NSKeyedArchiveRootObjectKey)
                archiver.finishEncoding()
                prefs.set(archiver.encodedData, forKey: bookHistoryKey)
                prefs.synchronize()


                self.dataSource = books
                self.tableView.reloadData()

                PopupView.showLoading(false)
            }, failure:  { (error) in
                PopupView.showWithContent("No Results")
                self.dataSource = []
                self.tableView.reloadData()
                PopupView.showLoading(false)
            })
    }
}

extension SearchBookViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBook()

        var histories: [String] = []
        if let data = prefs.value(forKey: inputKey) as? Data, let saved = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String], !saved.isEmpty {
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
        let encoded = try! NSKeyedArchiver.archivedData(withRootObject: histories, requiringSecureCoding: false)
        prefs.setValue(encoded, forKey: inputKey)
        prefs.synchronize()

        loadHistories()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 1 {
            return
        }
        self.searchText = searchText
    }
}

extension SearchBookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BookTableViewCell.self)) as! BookTableViewCell
        cell.setObject(book: dataSource[indexPath.row])
        cell.checkMatch(searchText: searchText)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = dataSource[indexPath.row]
        let viewController = DownloadViewController(book: book)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
