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

class DownloadViewController: UIViewController {

    fileprivate var book: Book!

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

//        name = "book.pdf"
//        fileUrl = "http://qiniu.cdn.yituishui.com/swift.pdf"

//        name = "yoga.epub"
//        fileUrl = "http://qiniu.cdn.yituishui.com/2013_Book_YogaTraveling.epub"

        // Do any additional setup after loading the view.
        progressBar = UIProgressView()
        progressBar.progress = 0
        self.view.addSubview(progressBar)
        progressBar.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(100)
            make.width.equalTo(400)
            make.height.equalTo(10)
        }
        let downloadButton = UIButton()
        downloadButton.backgroundColor = UIColor.blue
        downloadButton.setTitle("下载", for: .normal)
        downloadButton.addTarget(self, action: #selector(onDownloadTapped(_:)), for: .touchUpInside)
        self.view.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { (make) in
            make.width.equalTo(90)
            make.height.equalTo(45)
            make.centerX.equalTo(self.view)
            make.top.equalTo(progressBar.snp.bottom).offset(30)
        }

        searchBook()
    }

    fileprivate func searchBook() {
        NetworkManager.sharedInstance().GET(path: "record?id=" + book.id!,
            parameters: nil,
            modelClass: Book.self,
            success: { (books) in
                if let books = books as? [Book] {
                    self.book = books[0]
                    print(self.book)
                }
            }, failure:  { (error) in
                print(error)
            })
    }
    
    @objc func onDownloadTapped(_ sender: Any) {
        guard var fileUrl = book.urlPdf_str else {
            PopupView.showWithContent("该书没有下载链接")
            return
        }
        let manager = AFURLSessionManager(sessionConfiguration: .default)
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let path = paths[0] + "/" + book.title!
        if (checkFileExisted(path)) {
            // 直接打开
            if (fileUrl.contains(".pdf")) {
                self.openPdf(path)
            } else if (fileUrl.contains(".epub")) {
                self.openEpub(path)
            } else {
                PopupView.showWithContent("该书没有下载链接")
            }
            return
        }

        fileUrl = fileUrl.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: fileUrl)!
        let request = URLRequest(url: url)

        let downloadTask = manager.downloadTask(with: request, progress: { (progress) in
            DispatchQueue.main.async {
                self.progressBar.setProgress(Float(progress.completedUnitCount) / Float(progress.totalUnitCount), animated: true)
            }
        }, destination: { (url, response) -> URL in
            return URL(fileURLWithPath: path)
        }, completionHandler: { (response, url, error) in
            if (fileUrl.contains(".pdf")) {
                self.openPdf(path)
            } else if (fileUrl.contains(".epub")) {
                self.openEpub(path)
            } else {
                PopupView.showWithContent("该书没有下载链接")
            }
        })
        downloadTask.resume()
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
