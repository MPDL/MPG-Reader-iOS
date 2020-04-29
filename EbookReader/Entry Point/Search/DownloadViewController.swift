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

class DownloadViewController: UIViewController {
    fileprivate var bookImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var authorLabel: UILabel!
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
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
        bookImageView = UIImageView()
        self.view.addSubview(bookImageView)
        bookImageView.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.left.equalTo(30)
        }

        titleLabel = UILabel()
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(30)
            make.right.equalTo(-30)
        }

        authorLabel = UILabel()
        self.view.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(30)
        }

        publicationDateLabel = UILabel()
        self.view.addSubview(publicationDateLabel)
        publicationDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(authorLabel.snp.bottom).offset(15)
            make.left.equalTo(30)
        }

        publicationPressLabel = UILabel()
        self.view.addSubview(publicationPressLabel)
        publicationPressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(publicationDateLabel)
            make.left.equalTo(publicationDateLabel.snp.right).offset(10)
        }

        isbnLabel = UILabel()
        self.view.addSubview(publicationPressLabel)
        publicationPressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(publicationDateLabel.snp.bottom).offset(15)
            make.left.equalTo(30)
        }

        let introductionTitleLabel = UILabel()
        self.view.addSubview(introductionTitleLabel)
        introductionTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bookImageView.snp.bottom).offset(30)
            make.left.equalTo(30)
        }

        introductionLabel = UILabel()
        self.view.addSubview(introductionLabel)
        introductionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(introductionTitleLabel.snp.bottom).offset(30)
            make.left.equalTo(30)
        }

        progressBar = UIProgressView()
        self.view.addSubview(progressBar)
        progressBar.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(-60)
            make.width.equalTo(400)
            make.height.equalTo(10)
        }
        downloadView = UIView()
        downloadView.isUserInteractionEnabled = true
        progressBar.addSubview(downloadView)
        downloadView.snp.makeConstraints { (make) in
            make.edges.equalTo(progressBar)
        }
        downloadImageView = UIImageView()
        downloadView.addSubview(downloadImageView)
        downloadImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(downloadView).offset(-20)
            make.centerY.equalTo(downloadView)
        }
        downloadLabel = UILabel()
        downloadView.addSubview(downloadLabel)
        downloadLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(downloadView).offset(20)
            make.centerY.equalTo(downloadView)
        }

        searchBook()
    }

    fileprivate func setObject() {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        path = paths[0] + "/" + book.title
        if (checkFileExisted(path)) {
            progressBar.progress = 100
            progressBar.backgroundColor = UIColor.gray
            downloadLabel.text = "Start Reading"
            downloadView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOpenBookTapped)))
        } else {
            progressBar.progress = 0
            progressBar.backgroundColor = UIColor.blue
            downloadLabel.text = "Download"
            downloadView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDownloadTapped)))
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

                // todo: delete
                // fileUrl = "http://qiniu.cdn.yituishui.com/swift.pdf"
                // fileUrl = "http://qiniu.cdn.yituishui.com/2013_Book_YogaTraveling.epub"
                self.book.downloadUrl = "http://qiniu.cdn.yituishui.com/swift.pdf"

                self.setObject()
                PopupView.showLoading(false)
            }, failure:  { (error) in
                PopupView.showLoading(false)
            })
    }

    @objc func onOpenBookTapped() {
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

        let downloadTask = manager.downloadTask(with: request, progress: { (progress) in
            DispatchQueue.main.async {
                self.progressBar.setProgress(Float(progress.completedUnitCount) / Float(progress.totalUnitCount), animated: true)
                self.downloadLabel.text = "Downloading"
            }
        }, destination: { (url, response) -> URL in
            return URL(fileURLWithPath: self.path)
        }, completionHandler: { (response, url, error) in
            self.setObject()
            self.saveBook()
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
