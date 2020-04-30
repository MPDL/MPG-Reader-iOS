//
//  FirstViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/7.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    fileprivate var tableWrapper: UIView!
    fileprivate var tableView: UITableView!
    fileprivate var hintView: UIView!

    fileprivate var histories: [Book]?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        checkHistories()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "background-home")
        self.view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logo")
        self.view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(115)
        }

        let searchView = UIView()
        searchView.isUserInteractionEnabled = true
        searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSearchTapped)))
        searchView.backgroundColor = UIColor.white
        searchView.layer.cornerRadius = 12
        self.view.addSubview(searchView)
        searchView.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).offset(40)
            make.centerX.equalTo(self.view)
            make.width.equalTo(544)
            make.height.equalTo(70)
        }
        let searchIcon = UIImageView()
        searchIcon.image = UIImage(named: "icon-input-search")
        searchView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(searchView)
            make.left.equalTo(26)
        }
        let placeholderLabel = UILabel()
        placeholderLabel.font = UIFont.systemFont(ofSize: 20)
        placeholderLabel.textColor = UIColor(red: 0.79, green: 0.79, blue: 0.79, alpha: 1)
        placeholderLabel.text = "SEARCH"
        searchView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(searchView)
            make.left.equalTo(searchIcon.snp.right).offset(30)
        }

        hintView = UIView()
        hintView.layer.cornerRadius = 12
        hintView.backgroundColor = UIColor(red: 0.85, green: 0.92, blue: 0.95, alpha: 0.88)
        self.view.addSubview(hintView)
        hintView.snp.makeConstraints { (make) in
            make.width.equalTo(543)
            make.height.equalTo(526)
            make.top.equalTo(searchView.snp.bottom).offset(45)
            make.centerX.equalTo(self.view)
        }
        let hintTitleLabel = UILabel()
        hintTitleLabel.text = "MPG.eBooks"
        hintTitleLabel.textColor = UIColor(red: 0.42, green: 0.67, blue: 0.77, alpha: 1)
        hintTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        hintView.addSubview(hintTitleLabel)
        hintTitleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(40)
        }
        let hintLabel = UILabel()
        hintLabel.numberOfLines = 0
        hintLabel.text = "On this search platform,you can find all e-books that are accessible to all institutes of Max Planck Gesellschaft.\n\nCurrently,you have access to 650,000 titles from various publishers and e-book providers.\nThe contents are continuously extended and updated.\n\nClick here for an overview of the included e-books."
        hintLabel.textColor = UIColor(red: 0.28, green: 0.48, blue: 0.57, alpha: 1)
        hintLabel.font = UIFont.systemFont(ofSize: 16)
        hintView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.top.equalTo(hintTitleLabel.snp.bottom).offset(24)
        }


        tableWrapper = UIView()
        self.view.addSubview(tableWrapper)
        tableWrapper.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom).offset(60)
            make.left.equalTo(48)
            make.right.equalTo(-48)
            make.bottom.equalTo(0)
        }
        let tableTitle = UILabel()
        tableTitle.text = "Search History"
        tableTitle.textColor = UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1)
        tableTitle.font = UIFont.systemFont(ofSize: 20)
        tableWrapper.addSubview(tableTitle)
        tableTitle.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(7)
        }
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: String(describing: BookTableViewCell.self))
        tableWrapper.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(tableTitle.snp.bottom).offset(23)
        }

        checkHistories()
    }

    @objc func onSearchTapped() {
        let searchViewController = SearchBookViewController()
        searchViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }

    fileprivate func checkHistories() {
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
        if let histories = self.histories, histories.count > 0 {
            self.histories = histories
            hintView.isHidden = true
            tableWrapper.isHidden = false
            tableView.reloadData()
        } else {
            self.histories = nil
            hintView.isHidden = false
            tableWrapper.isHidden = true
        }
    }
}

extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let histories = self.histories {
            return histories.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BookTableViewCell.self)) as! BookTableViewCell
        if let histories = self.histories {
            cell.setObject(book: histories[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = histories![indexPath.row]
        let viewController = DownloadViewController(book: book)
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
