//
//  SecondViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/7.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import RealmSwift

class SecondViewController: UIViewController {

    fileprivate var collectionView: UICollectionView!
    fileprivate var books: Results<Book>!
    fileprivate var isEditingBooks = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let realm = try! Realm()
        books = realm.objects(Book.self).sorted(byKeyPath: "modifyDate", ascending: false)

        if isEditingBooks {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Select all", style: .plain, target: self, action: #selector(onSelectAllTapped))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onDeSelectAllTapped))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onEditTapped))
        }

        let searchView = UIView()
        self.view.addSubview(searchView)
        searchView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
        }
        let searchBar = UISearchBar()
        searchView.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.centerX.equalTo(searchView)
            make.width.equalTo(400)
            make.height.equalTo(40)
        }
        let countLabel = UILabel()
        countLabel.text = "All Books"
        searchView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(searchView)
            make.top.equalTo(60)
            make.bottom.equalTo(-30)
        }

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = CGFloat(30)
        layout.sectionInset = UIEdgeInsets(top: 0, left: CGFloat(30), bottom: 0, right: CGFloat(30))
        let width = (UIScreen.main.bounds.size.width - 45) / 2
        layout.itemSize = CGSize(width: width, height: width)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: BookCollectionViewCell.self))
        self.view.addSubview(self.collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }

    }

    @objc func onSelectAllTapped() {

    }

    @objc func onDeSelectAllTapped() {

    }

    @objc func onEditTapped() {

    }


}

extension SecondViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = BookCollectionViewCell()
        cell.setObject(book: books[indexPath.row])
        return cell
    }


}

