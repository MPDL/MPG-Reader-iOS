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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
        progressBar = UIProgressView()
        self.view.addSubview(progressBar)
        progressBar.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(100)
            make.width.equalTo(400)
            make.height.equalTo(10)
        }
        let downloadButton = UIButton()
        downloadButton.setTitle("点击下载", for: .normal)
        downloadButton.setTitle("已经下载", for: .disabled)
        downloadButton.addTarget(self, action: #selector(onDownloadTapped(_:)), for: .touchUpInside)
        self.view.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(45)
            make.centerX.equalTo(self.view)
            make.top.equalTo(progressBar.snp.bottom).offset(30)
        }
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        path = paths[0] + "/" + book.title
        if (checkFileExisted(path)) {
            progressBar.progress = 100
            downloadButton.backgroundColor = UIColor.gray
            downloadButton.isEnabled = false
        } else {
            progressBar.progress = 0
            downloadButton.backgroundColor = UIColor.blue
            downloadButton.isEnabled = true
        }

        searchBook()
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
                self.book.urlPdf_str = "http://qiniu.cdn.yituishui.com/swift.pdf"

                PopupView.showLoading(false)
            }, failure:  { (error) in
                PopupView.showLoading(false)
            })
    }
    
    @objc func onDownloadTapped(_ sender: Any) {
        guard book.urlPdf_str != "" else {
            PopupView.showWithContent("该书没有下载链接")
            return
        }
        var fileUrl = book.urlPdf_str
        let manager = AFURLSessionManager(sessionConfiguration: .default)
        fileUrl = fileUrl.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: fileUrl)!
        let request = URLRequest(url: url)

        let downloadTask = manager.downloadTask(with: request, progress: { (progress) in
            DispatchQueue.main.async {
                self.progressBar.setProgress(Float(progress.completedUnitCount) / Float(progress.totalUnitCount), animated: true)
            }
        }, destination: { (url, response) -> URL in
            return URL(fileURLWithPath: self.path)
        }, completionHandler: { (response, url, error) in
            if (fileUrl.contains(".pdf")) {
                self.openPdf(self.path)
                self.saveBook()
            } else if (fileUrl.contains(".epub")) {
                self.openEpub(self.path)
                self.saveBook()
            } else {
                PopupView.showWithContent("该书没有下载链接")
            }
        })
        downloadTask.resume()
    }

    func saveBook() {
        let realm = try! Realm()

        let predicate = NSPredicate(format: "id == %@", book.id)
        if !realm.objects(Book.self).filter(predicate).isEmpty {
            PopupView.showWithContent("书已经存在")
            return
        }

        try! realm.write {
            realm.add(book)
        }
        print(realm.objects(Book.self))
    }

    func checkFileExisted(_ path: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }

    func openPdf(_ path: String) {
        let url = URL(fileURLWithPath: path)
        let pdfReaderViewController = PdfReaderViewController(url: url)
        self.present(pdfReaderViewController, animated: true, completion: nil)
    }

    func openEpub(_ path: String) {
        let config = FolioReaderConfig()
        let folioReader = FolioReader()
        folioReader.presentReader(parentViewController: self, withEpubPath: path, andConfig: config)
    }

}
