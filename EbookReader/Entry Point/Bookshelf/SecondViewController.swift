//
//  SecondViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/7.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import RealmSwift
import FolioReaderKit

class SecondViewController: UIViewController {

    fileprivate var collectionView: UICollectionView!
    fileprivate var countLabel: UILabel!

    fileprivate var books: Results<Book>!
    fileprivate var isEditingBooks = false
    fileprivate var searchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

        self.navigationItem.title = "My Bookshelf"

        if isEditingBooks {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Select all", style: .plain, target: self, action: #selector(onSelectAllTapped))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onDeSelectAllTapped))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onEditTapped))
        }

        let searchView = UIView()
        self.view.addSubview(searchView)
        searchView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(104)
        }
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchView.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.centerX.equalTo(searchView)
            make.width.equalTo(750)
            make.height.equalTo(53)
        }
        countLabel = UILabel()
        countLabel.text = "All Books"
        searchView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.centerX.bottom.equalTo(searchView)
            make.top.equalTo(searchBar.snp.bottom).offset(60)
        }

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = CGFloat(50)
        layout.sectionInset = UIEdgeInsets(top: 40, left: CGFloat(50), bottom: 0, right: CGFloat(50))
        layout.itemSize = CGSize(width: 150, height: 265)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let realm = try! Realm()
        books = realm.objects(Book.self).sorted(byKeyPath: "modifyDate", ascending: false)

        countLabel.text = "All Books (\(books.count))"
        collectionView.reloadData()
    }

    @objc func onSelectAllTapped() {

    }

    @objc func onDeSelectAllTapped() {

    }

    @objc func onEditTapped() {

    }

}

extension SecondViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        let realm = try! Realm()
        let predicate = NSPredicate(format: "title CONTAINS[c] %@ OR abs CONTAINS[c] %@", searchText, searchText)
        books = realm.objects(Book.self).filter(predicate).sorted(byKeyPath: "modifyDate", ascending: false)

        collectionView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if searchText.count < 1 {
            searchBar.resignFirstResponder()
            let realm = try! Realm()
            books = realm.objects(Book.self).sorted(byKeyPath: "modifyDate", ascending: false)
            collectionView.reloadData()
            return
        }
    }

}

extension SecondViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BookCollectionViewCell.self), for: indexPath) as! BookCollectionViewCell
        cell.setObject(book: books[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = books[indexPath.row]
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let path = paths[0] + "/" + book.id
        if book.isPdf {
            let url = URL(fileURLWithPath: path)
            let pdfReaderViewController = PdfReaderViewController(url: url)
            self.present(pdfReaderViewController, animated: true, completion: nil)
        } else {
            let config = FolioReaderConfig()
            let folioReader = FolioReader()
            if keepScreenOnWhileReading {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            folioReader.presentReader(parentViewController: self, withEpubPath: path, unzipPath: nil, andConfig: config, shouldRemoveEpub: false, animated: true)
        }
        
        if book.isPdf {
            let url = URL(fileURLWithPath: path)
            let pdfReaderViewController = PdfReaderViewController(url: url)
            self.present(pdfReaderViewController, animated: true, completion: nil)
        } else {
            let config = FolioReaderConfig()
            let folioReader = FolioReader()
            if keepScreenOnWhileReading {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            folioReader.presentReader(parentViewController: self, withEpubPath: path, andConfig: config)
        }

        // Update modify time
        let realm = try! Realm()
        try! realm.write {
            book.modifyDate = Date()
            realm.add(book)
        }
    }


}

