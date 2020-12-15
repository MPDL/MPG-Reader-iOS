//
//  ReadingListViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/6.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import RealmSwift
import FolioReaderKit
import MJRefresh

class ReadingListViewController: UIViewController {

    fileprivate var collectionView: UICollectionView!
    fileprivate var deleteView: UIView!
    fileprivate var emptyView: UIView!
    fileprivate var overlayView: UIView!
    fileprivate var overlayContentView: UIView!
    fileprivate var footer: MJRefreshAutoNormalFooter!
    fileprivate var header: MJRefreshNormalHeader!
    fileprivate var books: [BookStatistic] = []
    fileprivate var selected: [Bool] = []
    fileprivate var page = 0
    fileprivate var pageSize = 12

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: .readingListDidChange, object: nil)

        // Do any additional setup after loading the view.
        self.navigationItem.title = "My Reading List"
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        self.view.backgroundColor = UIColor(hex: 0xF9F9F9)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = CGFloat(50)
        layout.sectionInset = UIEdgeInsets(top: 40, left: CGFloat(50), bottom: 0, right: CGFloat(50))
        layout.itemSize = CGSize(width: 150, height: 265)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = true
        self.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(reloadData))
        self.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        collectionView.mj_footer = footer
        collectionView.mj_header = header
        collectionView.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: BookCollectionViewCell.self))
        self.view.addSubview(self.collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }

        deleteView = UIView()
        deleteView.isHidden = true
        deleteView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.view.addSubview(deleteView)
        deleteView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(160)
        }
        let deleteButton = UIView()
        deleteButton.backgroundColor = UIColor.white
        deleteButton.isUserInteractionEnabled = true
        deleteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDeleteTapped)))
        deleteButton.backgroundColor = UIColor.white
        deleteButton.layer.shadowColor = UIColor(red: 0.43, green: 0.43, blue: 0.43, alpha: 0.5).cgColor
        deleteButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        deleteButton.layer.shadowOpacity = 1
        deleteButton.layer.cornerRadius = 6
        deleteView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.width.equalTo(550)
            make.height.equalTo(80)
            make.centerX.equalTo(deleteView)
        }
        let deleteImageView = UIImageView()
        deleteImageView.image = UIImage(named: "icon-trash-green")
        deleteButton.addSubview(deleteImageView)
        deleteImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(deleteButton)
            make.centerX.equalTo(deleteButton).offset(-35)
        }
        let deleteLabel = UILabel()
        deleteLabel.textColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
        deleteLabel.font = UIFont.systemFont(ofSize: 24)
        deleteLabel.text = "Remove"
        deleteButton.addSubview(deleteLabel)
        deleteLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(deleteButton)
            make.centerX.equalTo(deleteButton).offset(35)
        }

        overlayView = UIView()
        overlayView.isHidden = true
        overlayView.isUserInteractionEnabled = true
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOverlayTapped)))
        overlayView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.58)
        AppDelegate.getTopView().addSubview(overlayView)
        overlayView.snp.makeConstraints { (make) in
            make.width.equalTo(UIScreen.main.bounds.width)
            make.left.bottom.top.equalTo(0)
        }
        overlayContentView = UIView()
        overlayContentView.isHidden = true
        overlayContentView.layer.cornerRadius = 20
        overlayContentView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        AppDelegate.getTopView().addSubview(overlayContentView)
        overlayContentView.snp.makeConstraints { (make) in
            make.width.equalTo(overlayView)
            make.left.right.equalTo(0)
            make.bottom.equalTo(20)
        }
        let deleteTitleLabel = UILabel()
        deleteTitleLabel.text = "Are you sure to remove?"
        deleteTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        deleteTitleLabel.font = UIFont.systemFont(ofSize: 28)
        overlayContentView.addSubview(deleteTitleLabel)
        deleteTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(overlayContentView)
            make.top.equalTo(32)
        }
        let confirmView = UIView()
        confirmView.isUserInteractionEnabled = true
        confirmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onConfirmDeleteTapped)))
        overlayContentView.addSubview(confirmView)
        confirmView.snp.makeConstraints { (make) in
            make.top.equalTo(deleteTitleLabel.snp.bottom).offset(24)
            make.left.right.equalTo(0)
            make.height.equalTo(80)
        }
        let confirmLabel = UILabel()
        confirmLabel.text = "Sure"
        confirmLabel.textColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
        confirmLabel.font = UIFont.systemFont(ofSize: 24)
        confirmView.addSubview(confirmLabel)
        confirmLabel.snp.makeConstraints { (make) in
            make.center.equalTo(confirmView)
        }
        let separator = UIView()
        separator.backgroundColor = UIColor(red: 0.81, green: 0.81, blue: 0.81, alpha: 1)
        overlayContentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(confirmView.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(1)
        }
        let cancelView = UIView()
        cancelView.isUserInteractionEnabled = true
        cancelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOverlayTapped)))
        overlayContentView.addSubview(cancelView)
        cancelView.snp.makeConstraints { (make) in
            make.top.equalTo(separator.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(80)
            make.bottom.equalTo(-20)
        }
        let cancelLabel = UILabel()
        cancelLabel.text = "Cancel"
        cancelLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        cancelLabel.font = UIFont.systemFont(ofSize: 24)
        cancelView.addSubview(cancelLabel)
        cancelLabel.snp.makeConstraints { (make) in
            make.center.equalTo(cancelView)
        }

        emptyView = UIView()
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).offset(-50)
        }
        let emptyIcon = UIImageView()
        emptyIcon.image = UIImage(named: "icon-empty-shelf")
        emptyView.addSubview(emptyIcon)
        emptyIcon.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(emptyView)
            make.width.equalTo(518)
            make.height.equalTo(372)
        }
        let emptyTitleLabel = UILabel()
        emptyTitleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        emptyTitleLabel.textColor = UIColor(hex: 0x333333)
        emptyTitleLabel.text = "Your reading list is empty"
        emptyView.addSubview(emptyTitleLabel)
        emptyTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emptyIcon.snp.bottom).offset(43)
            make.centerX.equalTo(emptyView)
        }
        let emptySubTitleLabel = UILabel()
        emptySubTitleLabel.font = UIFont.systemFont(ofSize: 20)
        emptySubTitleLabel.textColor = UIColor(hex: 0x999999)
        emptySubTitleLabel.text = "Tap here to discover and add books."
        emptyView.addSubview(emptySubTitleLabel)
        emptySubTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(13)
            make.centerX.equalTo(emptyView)
        }
        let emptyButton = UIControl()
        emptyButton.reactive.controlEvents(.touchUpInside).observeValues { (control) in
            self.tabBarController?.selectedIndex = 0
        }
        emptyButton.layer.cornerRadius = 8
        emptyButton.backgroundColor = UIColor(hex: 0x009FA1)
        emptyView.addSubview(emptyButton)
        emptyButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(emptyView)
            make.top.equalTo(emptySubTitleLabel.snp.bottom).offset(37)
            make.bottom.equalTo(0)
            make.width.equalTo(220)
            make.height.equalTo(50)
        }
        let emptyButtonLabel = UILabel()
        emptyButtonLabel.text = "Get inspired"
        emptyButtonLabel.textColor = UIColor.white
        emptyButtonLabel.font = UIFont.boldSystemFont(ofSize: 20)
        emptyButton.addSubview(emptyButtonLabel)
        emptyButtonLabel.snp.makeConstraints { (make) in
            make.center.equalTo(emptyButton)
        }

        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }

    @objc fileprivate func reloadData() {
        page = 0
        loadData()
    }

    @objc fileprivate func loadMore() {
        page += 1
        loadData()
    }

    @objc fileprivate func loadData() {
        let parameters = ["pageNumber": page, "pageSize": pageSize]
        NetworkManager.sharedInstance().POST(
            path: "rest/user/readinglist",
            parameters: parameters,
            modelClass: PageDTO<BookStatistic>.self,
            success: { (pageDTO) in
                PopupView.showLoading(false)
                self.header.endRefreshing()
                self.footer.endRefreshing()
                if let pageDTO = pageDTO, let books = pageDTO.content, books.count > 0 {
                    if self.page == 0 {
                        self.collectionView.isHidden = false
                        self.emptyView.isHidden = true
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.onEditTapped))

                        self.books = books
                    } else {
                        self.books.append(contentsOf: books)
                    }
                    self.collectionView.reloadData()
                } else {
                    if self.page == 0 {
                        self.collectionView.isHidden = true
                        self.emptyView.isHidden = false
                        self.navigationItem.rightBarButtonItem = nil

                        self.books = []
                        self.collectionView.reloadData()
                    } else {
                        PopupView.showWithContent("No more results")
                        self.page -= 1
                    }
                }
            }, failure:  { (error) in
                self.header.endRefreshing()
                self.footer.endRefreshing()
                PopupView.showWithContent("No Results")
            })
    }

    @objc func onConfirmDeleteTapped() {
        self.onOverlayTapped()

        var ids = [String]()
        for i in 0..<selected.count {
            if let bookId = books[i].bookId, selected[i] == true {
                ids.append(bookId)
            }
        }
        let parameters = ["bookIds": ids]
        NetworkManager.sharedInstance().POST(
            path: "rest/user/readinglist/delete",
            parameters: parameters,
            modelClass: ReadingList.self,
            success: { (pageDTO) in
                PopupView.showLoading(false)
                self.onCancelTapped()
                PopupView.showWithContent("Remove from the reading list successfully.")
                NotificationCenter.default.post(name: .readingListDidChange, object: nil)
            },
            failure: { (error) in
                self.onCancelTapped()
            })
    }

    @objc func onOverlayTapped() {
        self.overlayView.isHidden = true
        self.overlayContentView.isHidden = true
    }

    @objc func onDeleteTapped() {
        if !selected.contains(true) {
            PopupView.showWithContent("No book selected")
            return
        }
        self.overlayView.isHidden = false
        self.overlayContentView.isHidden = false
    }

    @objc func onSelectAllTapped() {
        if selected.contains(false) {
            for i in 0..<selected.count {
                selected[i] = true
            }
        } else {
            for i in 0..<selected.count {
                selected[i] = false
            }
        }
        checkAllSelected()
        self.collectionView.reloadData()
    }

    @objc func onCancelTapped() {
        self.deleteView.isHidden = true
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onEditTapped))
        selected = []
        self.collectionView.reloadData()
    }

    @objc func onEditTapped() {
        self.tabBarController?.tabBar.isHidden = true
        self.deleteView.isHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(onSelectAllTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancelTapped))
        for _ in 0..<books.count {
            selected.append(false)
        }
        self.collectionView.reloadData()
    }

    fileprivate func checkAllSelected() {
        if selected.contains(false) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(onSelectAllTapped))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Deselect All", style: .plain, target: self, action: #selector(onSelectAllTapped))
        }
    }

}

extension ReadingListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BookCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BookCollectionViewCell.self), for: indexPath) as! BookCollectionViewCell
        let book = Book()
        let bookStatistic = books[indexPath.row]
        guard let bookId = bookStatistic.bookId else {
            return cell
        }
        book.id = bookId
        book.title = bookStatistic.bookName!
        book.thumbnail = bookStatistic.bookCoverURL!
        cell.setObject(book: book)

        if selected.count > 0 {
            cell.checkButton.isHidden = false
            cell.checkButton.isSelected = selected[indexPath.row]
        } else {
            cell.checkButton.isHidden = true
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selected.count > 0 {
            // editing mode
            if let cell = collectionView.cellForItem(at: indexPath) as? BookCollectionViewCell {
                selected[indexPath.row] = !selected[indexPath.row]
                cell.checkButton.isSelected = selected[indexPath.row]
            }
            checkAllSelected()
            return
        }

        guard let bookId = books[indexPath.row].bookId else {
            return
        }
        let viewController = DownloadViewController(bookId: bookId)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

extension ReadingListViewController: PdfReaderViewControllerDelegate {
    func showInfoPage(bookId: String) {
        let viewController = DownloadViewController(bookId: bookId)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

