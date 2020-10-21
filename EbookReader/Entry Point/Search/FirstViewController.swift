//
//  FirstViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/7.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    fileprivate var headerView: UIView!
    fileprivate var tableView: UITableView!
    fileprivate var hintView: UIView!
    fileprivate var tableTitle: UILabel!
    fileprivate var searchView: UIView!

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

        headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))

        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logo")
        headerView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(headerView)
            make.top.equalTo(107)
        }

        searchView = UIView()
        searchView.layer.borderWidth = 1
        searchView.layer.borderColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).cgColor
        searchView.layer.cornerRadius = 6
        searchView.isUserInteractionEnabled = true
        searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSearchTapped)))
        searchView.backgroundColor = UIColor.white
        headerView.addSubview(searchView)
        searchView.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).offset(76)
            make.centerX.equalTo(headerView)
            make.width.equalTo(544)
            make.height.equalTo(70)
        }
        let searchIcon = UIImageView()
        searchIcon.image = UIImage(named: "icon-input-search")
        searchView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(searchView)
            make.left.equalTo(27)
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
        headerView.addSubview(hintView)
        hintView.snp.makeConstraints { (make) in
            make.width.equalTo(565)
            make.top.equalTo(searchView.snp.bottom).offset(107)
            make.centerX.equalTo(headerView)
            make.bottom.equalTo(-60)
        }
        let hintImageView = UIImageView()
        hintImageView.image = UIImage(named: "icon-book")
        hintView.addSubview(hintImageView)
        hintImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(hintView)
            make.top.equalTo(0)
        }
        let hintTitleLabel = UILabel()
        hintTitleLabel.text = "MPG.eBooks"
        hintTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        hintTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        hintView.addSubview(hintTitleLabel)
        hintTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(hintView)
            make.top.equalTo(hintImageView.snp.bottom).offset(-10)
        }
        let hintLabel = UILabel()
        hintLabel.numberOfLines = 0
        let text = "On this search platform, you can find all e-books that are accessible to all institutes of Max Planck Gesellschaft.\nCurrently you have access to ca.120,000 publications from Springer eBooks.\nThe contents are continuously extended and updated.\nClick here for an overview of the included e-books."
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 5
        let attr: [NSAttributedString.Key : Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1),
                .paragraphStyle: para]
        hintLabel.attributedText = NSAttributedString(string: text, attributes: attr)
        hintView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(hintView)
            make.top.equalTo(hintTitleLabel.snp.bottom).offset(22)
            make.bottom.left.right.equalTo(0)
        }

        tableTitle = UILabel()
        tableTitle.text = "Search History"
        tableTitle.textColor = UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1)
        tableTitle.font = UIFont.systemFont(ofSize: 24)
        headerView.addSubview(tableTitle)
        tableTitle.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom).offset(60)
            make.left.equalTo(7)
            make.bottom.equalTo(-22)
        }

        tableView = UITableView()
        tableView.tableHeaderView = headerView
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: String(describing: BookTableViewCell.self))
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(48)
            make.right.equalTo(-48)
        }

        checkHistories()
    }
    
    @objc func onSearchTapped() {
        let searchViewController = SearchBookViewController()
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
            tableTitle.isHidden = false

            hintView.snp.removeConstraints()
            tableTitle.snp.remakeConstraints { (make) in
                make.top.equalTo(searchView.snp.bottom).offset(60)
                make.left.equalTo(7)
                make.bottom.equalTo(-22)
            }
        } else {
            self.histories = nil
            hintView.isHidden = false
            tableTitle.isHidden = true

            hintView.snp.remakeConstraints { (make) in
                make.width.equalTo(565)
                make.top.equalTo(searchView.snp.bottom).offset(107)
                make.centerX.equalTo(headerView)
                make.bottom.equalTo(-60)
            }
            tableTitle.snp.removeConstraints()
        }

        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableView.reloadData()
    }
}

extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

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
        cell.contentWrapper.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = histories![indexPath.row]
        let viewController = DownloadViewController(book: book)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
