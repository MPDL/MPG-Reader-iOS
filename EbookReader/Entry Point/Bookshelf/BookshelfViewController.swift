//
//  BookshelfViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/7.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import RealmSwift
import FolioReaderKit

class BookshelfViewController: UIViewController {

    fileprivate var searchView: UIView!
    fileprivate var collectionView: UICollectionView!
    fileprivate var countLabel: UILabel!
    fileprivate var deleteView: UIView!
    fileprivate var bookDeleteView: UIView!
    fileprivate var bookMoveView: UIView!
    fileprivate var overlayView: UIView!
    fileprivate var overlayContentView: UIView!
    fileprivate var emptyImageView: UIImageView!
    fileprivate var navigationItemView: NavigationItemView!
    fileprivate var writeReviewView: WriteReviewView?
    fileprivate var citeView: CiteView?
    fileprivate var shareBarButton: UIBarButtonItem!

    fileprivate var books: Results<Book>!
    fileprivate var searchText = ""
    fileprivate var selected: [Bool] = []
    fileprivate var folioReader: FolioReader!
    fileprivate var selectedBook: Book!
    fileprivate var deleteTitleLabel: UILabel!
    
    fileprivate var bookFolderHandleView: BookFolderHandleView!
    fileprivate var bookFolderHandleNameView: BookFolderHandleNameView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.isUserInteractionEnabled = true

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = COLOR_navBar

        self.navigationItem.title = "My Bookshelf"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onEditTapped))
        self.view.backgroundColor = COLOR_bookshelfBackground
        searchView = UIView()
        self.view.addSubview(searchView)
        searchView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(104)
        }
        let searchBar = UISearchBar()
        searchBar.setImage(UIImage(named: "icon-input-search"), for: .search, state: .normal)
        searchBar.backgroundColor = UIColor.white
        searchBar.placeholder = "SEARCH"
        searchBar.layer.cornerRadius = 6
        searchBar.layer.masksToBounds = true
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(hex: 0xC9C9C9).cgColor
        searchBar.backgroundImage = UIImage()
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.white
            textField.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        }
        searchBar.delegate = self
        searchView.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(searchView)
            make.left.equalTo(42)
            make.right.equalTo(-42)
            make.height.equalTo(53)
        }
        countLabel = UILabel()
        countLabel.font = UIFont.systemFont(ofSize: 20)
        countLabel.text = "All Books"
        searchView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.centerX.bottom.equalTo(searchView)
            make.top.equalTo(searchBar.snp.bottom).offset(60)
        }

        emptyImageView = UIImageView()
        emptyImageView.isHidden = true
        emptyImageView.image = UIImage(named: "icon-empty-shelf")
        self.view.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(searchView.snp.bottom).offset(60)
        }

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = CGFloat(50)
        layout.sectionInset = UIEdgeInsets(top: 40, left: CGFloat(50), bottom: 0, right: CGFloat(50))
        layout.itemSize = CGSize(width: 150, height: 265)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = COLOR_bookshelfBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: BookCollectionViewCell.self))
        self.view.addSubview(self.collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }

        deleteView = UIView()
        deleteView.isHidden = true
        deleteView.backgroundColor = COLOR_bookshelfBackground
        self.view.addSubview(deleteView)
        deleteView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(160)
        }
        let deleteButton = UIView()
        deleteButton.backgroundColor = COLOR_buttonBackground
        deleteButton.isUserInteractionEnabled = true
        deleteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDeleteTapped)))
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
            make.centerX.equalTo(deleteButton).offset(-36)
        }
        let deleteLabel = UILabel()
        deleteLabel.textColor = COLOR_buttonText
        deleteLabel.font = UIFont.systemFont(ofSize: 24)
        deleteLabel.text = "Remove"
        deleteButton.addSubview(deleteLabel)
        deleteLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(deleteButton)
            make.centerX.equalTo(deleteButton).offset(30)
        }
        
        bookDeleteView = UIView()
        bookDeleteView.isHidden = true
        bookDeleteView.backgroundColor = COLOR_bookshelfBackground
        self.view.addSubview(bookDeleteView)
        bookDeleteView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(160)
        }
        let bookDeleteButton = UIView()
        bookDeleteButton.backgroundColor = UIColor.white
        bookDeleteButton.isUserInteractionEnabled = true
        bookDeleteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDeleteTapped)))
        bookDeleteButton.backgroundColor = COLOR_buttonBackground
        bookDeleteButton.layer.shadowColor = UIColor(red: 0.43, green: 0.43, blue: 0.43, alpha: 0.5).cgColor
        bookDeleteButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        bookDeleteButton.layer.shadowOpacity = 1
        bookDeleteButton.layer.cornerRadius = 6
        bookDeleteView.addSubview(bookDeleteButton)
        bookDeleteButton.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.width.equalTo(260)
            make.height.equalTo(80)
            make.centerX.equalTo(bookDeleteView).offset(-145)
        }
        let bookDeleteImageView = UIImageView()
        bookDeleteImageView.image = UIImage(named: "icon-trash-green")
        bookDeleteButton.addSubview(bookDeleteImageView)
        bookDeleteImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(bookDeleteButton)
            make.centerX.equalTo(bookDeleteButton).offset(-36)
        }
        let bookDeleteLabel = UILabel()
        bookDeleteLabel.textColor = COLOR_buttonText
        bookDeleteLabel.font = UIFont.systemFont(ofSize: 24)
        bookDeleteLabel.text = "Remove"
        bookDeleteButton.addSubview(bookDeleteLabel)
        bookDeleteLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(bookDeleteButton)
            make.centerX.equalTo(bookDeleteButton).offset(30)
        }
        
        let bookMoveButton = UIView()
        bookMoveButton.backgroundColor = UIColor.white
        bookMoveButton.isUserInteractionEnabled = true
        bookMoveButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMoveTapped)))
        bookMoveButton.backgroundColor = COLOR_buttonBackground
        bookMoveButton.layer.shadowColor = UIColor(red: 0.43, green: 0.43, blue: 0.43, alpha: 0.5).cgColor
        bookMoveButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        bookMoveButton.layer.shadowOpacity = 1
        bookMoveButton.layer.cornerRadius = 6
        bookDeleteView.addSubview(bookMoveButton)
        bookMoveButton.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.width.equalTo(260)
            make.height.equalTo(80)
            make.centerX.equalTo(bookDeleteView).offset(145)
        }
        let bookMoveImageView = UIImageView()
        bookMoveImageView.image = UIImage(named: "move_in")
        bookMoveButton.addSubview(bookMoveImageView)
        bookMoveImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(bookMoveButton)
            make.centerX.equalTo(bookMoveButton).offset(-70)
        }
        let bookMoveLabel = UILabel()
        bookMoveLabel.textColor = COLOR_buttonText
        bookMoveLabel.font = UIFont.systemFont(ofSize: 24)
        bookMoveLabel.text = "Move to Folder"
        bookMoveButton.addSubview(bookMoveLabel)
        bookMoveLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(bookMoveButton)
            make.centerX.equalTo(bookMoveButton).offset(30)
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
        overlayContentView.backgroundColor = COLOR_overlayView
        AppDelegate.getTopView().addSubview(overlayContentView)
        overlayContentView.snp.makeConstraints { (make) in
            make.width.equalTo(overlayView)
            make.left.right.equalTo(0)
            make.bottom.equalTo(20)
        }
        deleteTitleLabel = UILabel()
        deleteTitleLabel.text = "Are you sure you want to remove?"
        deleteTitleLabel.textColor = COLOR_overlayText
        deleteTitleLabel.numberOfLines = 0
        deleteTitleLabel.textAlignment = .center
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
        cancelLabel.textColor = COLOR_overlayText
        cancelLabel.font = UIFont.systemFont(ofSize: 24)
        cancelView.addSubview(cancelLabel)
        cancelLabel.snp.makeConstraints { (make) in
            make.center.equalTo(cancelView)
        }
        
        bookFolderHandleView = (Bundle.main.loadNibNamed("BookFolderHandleView", owner: self, options: nil)!.last as! BookFolderHandleView)
        bookFolderHandleView.isHidden = true
        self.view.addSubview(bookFolderHandleView)
        bookFolderHandleView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view)
            make.width.equalTo(self.view)
            make.height.equalTo(self.view)
        }
        bookFolderHandleView.addNameBlock = {[weak self]() in
            guard let weakSelf = self else {
                return
            }
            weakSelf.bookFolderHandleNameView.show()
        }
        bookFolderHandleView.doneBlock = {[weak self]() in
            guard let weakSelf = self else {
                return
            }
            weakSelf.bookFolderHandleView.hide()
        }
        
        bookFolderHandleNameView = (Bundle.main.loadNibNamed("BookFolderHandleNameView", owner: self, options: nil)!.last as! BookFolderHandleNameView)
        bookFolderHandleNameView.isHidden = true
        self.view.addSubview(bookFolderHandleNameView)
        bookFolderHandleNameView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view)
            make.width.equalTo(self.view)
            make.height.equalTo(self.view)
        }
        bookFolderHandleNameView.doneBlock = {[weak self]() in
            guard let weakSelf = self else {
                return
            }
            weakSelf.bookFolderHandleNameView.hide()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = false

        let realm = try! Realm()
        books = realm.objects(Book.self).sorted(byKeyPath: "modifyDate", ascending: false)
       
        countLabel.text = "All Books (\(books.count))"
        if searchText != "" {
            let predicate = NSPredicate(format: "title CONTAINS[c] %@ OR abstract CONTAINS[c] %@", searchText, searchText)
            books = realm.objects(Book.self).filter(predicate).sorted(byKeyPath: "modifyDate", ascending: false)
        }
        collectionView.reloadData()
    }

    @objc func onConfirmDeleteTapped() {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let fileManager = FileManager.default
        var ids = [String]()
        var allDeletedSuccessfully = true
        for i in 0..<selected.count {
            if selected[i] == true {
                // Delete book file
                let path = paths[0] + "/" + books[i].id
                if fileManager.fileExists(atPath: path) {
                    do {
                        try fileManager.removeItem(atPath: path)
                        ids.append(books[i].id)
                    } catch {
                        allDeletedSuccessfully = false
                    }
                } else {
                    allDeletedSuccessfully = false
                }
            }
        }

        // Delete db records
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id IN %@", ids)
        let booksToDelete = realm.objects(Book.self).filter(predicate)
        try! realm.write {
            realm.delete(booksToDelete)
        }

        books = realm.objects(Book.self).sorted(byKeyPath: "modifyDate", ascending: false)
        countLabel.text = "All Books (\(books.count))"

        onOverlayTapped()
        onCancelTapped()

        if !allDeletedSuccessfully {
            PopupView.showWithContent("Failed to delete some books.")
        }
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
    
    @objc func onMoveTapped() {
        if !selected.contains(true) {
            PopupView.showWithContent("No book selected")
            return
        }
        bookFolderHandleView.show()
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
        self.tabBarController?.tabBar.isHidden = false
        self.deleteView.isHidden = true
        self.bookDeleteView.isHidden = true
        self.searchView.snp.remakeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(104)
        }

        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onEditTapped))

        selected = []
        self.collectionView.reloadData()
    }

    @objc func onEditTapped() {
        self.tabBarController?.tabBar.isHidden = true
        self.deleteView.isHidden = false
        self.searchView.snp.remakeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(104)
            make.height.equalTo(0)
        }

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

    @objc func onMoreTapped() {
        navigationItemView.display()
    }


    @objc func onShareTapped() {
        var title = selectedBook.title
        if selectedBook.publicationDates.count > 0 {
            title += " (\(selectedBook.publicationDates.joined(separator: ", ")))"
        }
        let jumpValue = "[Read in MPG Reader](mpgreader://\(String(describing: selectedBook.id)))"
        let linkValue = NSURL(string: selectedBook.url)!
        let activityItems = [title, jumpValue, linkValue] as [Any]
        let viewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        viewController.excludedActivityTypes = [.airDrop, .assignToContact, .markupAsPDF, .message, .openInIBooks, .postToFacebook, .postToFlickr, .postToTencentWeibo, .postToTwitter, .postToVimeo, .postToWeibo, .print, .saveToCameraRoll]
        AppDelegate.getTopViewController().present(viewController, animated: true)

        if let popOver = viewController.popoverPresentationController {
            popOver.barButtonItem = shareBarButton
        }
    }
}

extension BookshelfViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        let realm = try! Realm()
        let predicate = NSPredicate(format: "title CONTAINS[c] %@ OR abstract CONTAINS[c] %@", searchText, searchText)
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

extension BookshelfViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if books.count == 0 {
            collectionView.isHidden = true
            emptyImageView.isHidden = false
        } else {
            collectionView.isHidden = false
            emptyImageView.isHidden = true
        }
        return books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BookCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BookCollectionViewCell.self), for: indexPath) as! BookCollectionViewCell
        cell.setObject(book: books[indexPath.row])

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

        let book = books[indexPath.row]
        selectedBook = book
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let path = paths[0] + "/" + book.id
        if book.pdf || book.downloadUrl.contains(".pdf") {
            let url = URL(fileURLWithPath: path)
            let pdfReaderViewController = PdfReaderViewController(url: url, book: book)
            pdfReaderViewController.delegate = self
            if let _ = prefs.value(forKey: book.id) as? Int {
                self.present(pdfReaderViewController, animated: true, completion: nil)
            } else {
                // if it's the first time to open the book, jump to info page instead
                let downloadViewController = DownloadViewController(bookId: book.id)
                self.navigationController?.pushViewController(downloadViewController, animated: true)
            }
        } else {
            let config = FolioReaderConfig()
            config.tintColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
            config.menuTextColorSelected = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
            config.allowSharing = false
            config.enableTTS = false
            folioReader = FolioReader()
            folioReader.delegate = self
            if keepScreenOnWhileReading {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            folioReader.presentReader(parentViewController: self, withEpubPath: path, unzipPath: nil, andConfig: config, shouldRemoveEpub: false, animated: true)
            navigationItemView = NavigationItemView(bookId: book.id, delegate: self)
            AppDelegate.getTopView().addSubview(navigationItemView)
            navigationItemView.snp.makeConstraints { (make) in
                make.top.equalTo(70)
                make.left.right.bottom.equalTo(0)
            }
        }

        // Update modify time
        let realm = try! Realm()
        try! realm.write {
            book.modifyDate = Date()
            realm.add(book)
        }
    }
}

extension BookshelfViewController: PdfReaderViewControllerDelegate {
    func showInfoPage(bookId: String) {
        let viewController = DownloadViewController(bookId: bookId)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension BookshelfViewController: FolioReaderDelegate {
    func folioReader(_ folioReader: FolioReader, didFinishedLoading book: FRBook) {
        let centerViewController = (AppDelegate.getTopViewController() as! FolioReaderContainer).centerViewController!
        let rightBarButtonItems = centerViewController.navigationItem.rightBarButtonItems!
        let item1 = UIBarButtonItem(image: UIImage(named: "icon-navbar-more"), style: .plain, target: self, action: #selector(onMoreTapped))
        let item2 = rightBarButtonItems[0]
        shareBarButton = UIBarButtonItem(image: UIImage(named: "icon-navbar-share"), style: .plain, target: self, action: #selector(onShareTapped))
        centerViewController.navigationItem.rightBarButtonItems = [item1, item2, shareBarButton]
    }
}

extension BookshelfViewController: NavigationItemDelegate {
    func onOneActionTapped(action: NaviAction) {
        switch action {
            case .writeReview:
                if let writeReviewView = writeReviewView {
                    writeReviewView.display()
                } else {
                    writeReviewView = WriteReviewView(book: selectedBook)
                    AppDelegate.getTopView().addSubview(writeReviewView!)
                    writeReviewView?.snp.makeConstraints({ (make) in
                        make.edges.equalTo(AppDelegate.getTopView())
                    })
                    writeReviewView?.display()
                }
                break
            case .citeItem:
                if let citeView = citeView {
                    citeView.display()
                } else {
                    citeView = CiteView(book: selectedBook)
                    AppDelegate.getTopView().addSubview(citeView!)
                    citeView?.snp.makeConstraints({ (make) in
                        make.edges.equalTo(AppDelegate.getTopView())
                    })
                    citeView?.display()
                }
                break
            case .gotoInfo:
                self.dismiss(animated: true) {
                    let viewController = DownloadViewController(bookId: self.selectedBook.id)
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                self.folioReader.close()
                break
        }
    }
}
