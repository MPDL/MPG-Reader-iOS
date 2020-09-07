//
//  DownloadViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/9.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import AFNetworking
import FolioReaderKit
import RealmSwift

@available(iOS 13.0, *)
class DownloadViewController: UIViewController {
    fileprivate var bookImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var authorLabel: UILabel!
    fileprivate var introductionTitleLabel: UILabel!
    fileprivate var publicationDateLabel: UILabel!
    fileprivate var publicationPressLabel: UILabel!
    fileprivate var isbnLabel: UILabel!
    fileprivate var introductionLabel: UILabel!
    fileprivate var downloadView: UIView!
    fileprivate var downloadImageView: UIImageView!
    fileprivate var downloadLabel: UILabel!

    fileprivate var book: Book!
    fileprivate var path: String!

    fileprivate var progressBar: UIProgressView!

    init(book: Book) {
        super.init(nibName: nil, bundle: nil)
        self.book = book
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)

        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }

        // Do any additional setup after loading the view.
        bookImageView = UIImageView()
        contentView.addSubview(bookImageView)
        bookImageView.snp.makeConstraints { (make) in
            make.top.equalTo(48)
            make.left.equalTo(44)
            make.width.equalTo(180)
            make.height.equalTo(240)
        }

        titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bookImageView)
            make.left.equalTo(bookImageView.snp.right).offset(37)
            make.right.equalTo(-35)
        }

        isbnLabel = UILabel()
        isbnLabel.font = UIFont.systemFont(ofSize: 20)
        isbnLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        contentView.addSubview(isbnLabel)
        isbnLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(bookImageView).offset(-5)
            make.left.equalTo(titleLabel)
        }

        publicationDateLabel = UILabel()
        publicationDateLabel.font = UIFont.italicSystemFont(ofSize: 24)
        publicationDateLabel.textColor = UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1)
        contentView.addSubview(publicationDateLabel)
        publicationDateLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(isbnLabel.snp.top).offset(-10)
            make.left.equalTo(titleLabel)
        }

        publicationPressLabel = UILabel()
        publicationPressLabel.font = UIFont.italicSystemFont(ofSize: 24)
        publicationPressLabel.textColor = UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1)
        contentView.addSubview(publicationPressLabel)
        publicationPressLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(publicationDateLabel)
            make.left.equalTo(publicationDateLabel.snp.right).offset(10)
        }

        authorLabel = UILabel()
        authorLabel.numberOfLines = 2
        authorLabel.font = UIFont.boldSystemFont(ofSize: 26)
        authorLabel.textColor = UIColor(red: 0.25, green: 0.31, blue: 0.36,alpha:1)
        contentView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(publicationDateLabel.snp.top).offset(-6)
            make.left.equalTo(titleLabel)
            make.right.equalTo(-35)
        }

        introductionTitleLabel = UILabel()
        introductionTitleLabel.font = UIFont.systemFont(ofSize: 24)
        introductionTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        contentView.addSubview(introductionTitleLabel)
        introductionTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bookImageView.snp.bottom).offset(50)
            make.left.equalTo(35)
        }

        introductionLabel = UILabel()
        introductionLabel.font = UIFont.systemFont(ofSize: 18)
        introductionLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        introductionLabel.numberOfLines = 0
        contentView.addSubview(introductionLabel)
        introductionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(introductionTitleLabel.snp.bottom).offset(30)
            make.bottom.equalTo(-30)
            make.left.equalTo(introductionTitleLabel)
            make.right.equalTo(-35)
        }

        progressBar = UIProgressView()
        progressBar.isUserInteractionEnabled = true
        progressBar.layer.cornerRadius = 8
        progressBar.layer.masksToBounds = true
        progressBar.progressTintColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
        progressBar.backgroundColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
        self.view.addSubview(progressBar)
        progressBar.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(-50)
            make.width.equalTo(454)
            make.height.equalTo(66)
        }
        downloadView = UIView()
        progressBar.addSubview(downloadView)
        downloadView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.equalTo(progressBar)
        }
        downloadImageView = UIImageView()
        downloadView.addSubview(downloadImageView)
        downloadImageView.snp.makeConstraints { (make) in
            make.left.centerY.equalTo(downloadView)
        }
        downloadLabel = UILabel()
        downloadLabel.textColor = UIColor.white
        downloadView.addSubview(downloadLabel)
        downloadLabel.snp.makeConstraints { (make) in
            make.right.centerY.equalTo(downloadView)
            make.left.equalTo(downloadImageView.snp.right).offset(20)
        }

        searchBook()
    }

    fileprivate func setObject() {
        bookImageView.kf.setImage(with: URL(string: book.thumbnail))
        titleLabel.text = book.title
        introductionTitleLabel.text = "Introduction"
        introductionLabel.text = book.abs
        if (book.authorsPrimary.count > 0) {
            var text = "Author: "
            for author in book.authorsPrimary {
                text = text + author + ", "
            }
            text = String(text.dropLast(2))
            authorLabel.text = text
        }
        if (book.isbns.count > 0) {
            var text = "ISBN: ["
            for isbn in book.isbns {
                text = text + isbn + ","
            }
            text = String(text.dropLast(1))
            text += "]"
            isbnLabel.text = text
        }
        if (book.publicationDates.count > 0) {
            publicationDateLabel.text = book.publicationDates[0]
        }
        if (book.publishers.count > 0) {
            publicationPressLabel.text = book.publishers[0]
        }

        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        path = paths[0] + "/" + book.id
        if (checkFileExisted(path)) {
            progressBar.progress = 100
            downloadLabel.text = "Start Reading"
            downloadImageView.image = UIImage(named: "icon-downloaded")
            progressBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOpenBookTapped)))
        } else {
            progressBar.progress = 0
            downloadLabel.text = "Download"
            downloadImageView.image = UIImage(named: "icon-download")
            progressBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDownloadTapped)))
        }
    }

    fileprivate func searchBook() {
        PopupView.showLoading(true)
        NetworkManager.sharedInstance().GET(path: "record?id=" + book.id,
            parameters: nil,
            modelClass: Book.self,
            success: { (books) in
                if let books = books as? [Book] {
                    self.book = books[0]
                }

                self.setObject()
                PopupView.showLoading(false)
            }, failure:  { (error) in
                PopupView.showLoading(false)
            })
    }

    @objc func onOpenBookTapped() {
        if book.isPdf {
            let url = URL(fileURLWithPath: path)
            let pdfReaderViewController = PdfReaderViewController(url: url, bookId: book.id)
            self.present(pdfReaderViewController, animated: true, completion: nil)
        } else {
            let config = FolioReaderConfig()
            config.tintColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
            config.menuTextColorSelected = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
            config.allowSharing = false
            let folioReader = FolioReader()
            if keepScreenOnWhileReading {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            folioReader.presentReader(parentViewController: self, withEpubPath: path, unzipPath: nil, andConfig: config, shouldRemoveEpub: false, animated: true)
        }
    }
    
    @objc func onDownloadTapped(_ sender: Any) {
        if downloadWithWifiOnly && AFNetworkReachabilityManager.shared().networkReachabilityStatus != .reachableViaWiFi {
            PopupView.showWithContent("Download on Wifi Only")
            return
        }
        guard book.downloadUrl != "" else {
            PopupView.showWithContent("该书没有下载链接")
            return
        }
        var fileUrl = book.downloadUrl
        let manager = AFURLSessionManager(sessionConfiguration: .default)
        fileUrl = fileUrl.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: fileUrl)!
        let request = URLRequest(url: url)

        PopupView.showLoading(true)
        progressBar.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1)

        let downloadTask = manager.downloadTask(with: request, progress: { (progress) in
            DispatchQueue.main.async {
                self.progressBar.setProgress(Float(progress.completedUnitCount) / Float(progress.totalUnitCount), animated: true)
                self.downloadLabel.text = "Downloading"
            }
        }, destination: { (url, response) -> URL in
            return URL(fileURLWithPath: self.path)
        }, completionHandler: { (response, url, error) in
            PopupView.showLoading(false)
            if self.checkFileExisted(self.path) {
                self.setObject()
                self.saveBook()
            } else {
                PopupView.showWithContent("下载失败，请重试")
            }
        })
        downloadTask.resume()
    }

    fileprivate func saveBook() {
        let realm = try! Realm()

        let predicate = NSPredicate(format: "id == %@", book.id)
        if !realm.objects(Book.self).filter(predicate).isEmpty {
            PopupView.showWithContent("书已经存在")
            return
        }

        try! realm.write {
            realm.add(book)
        }
    }

    fileprivate func checkFileExisted(_ path: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }

}
