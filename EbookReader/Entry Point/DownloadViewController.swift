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

    var name: String!
    var fileUrl: String!

    @IBOutlet var progressBar: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        name = "book.pdf"
//        fileUrl = "http://qiniu.cdn.yituishui.com/04.01%20BOBODEE%E4%BA%A7%E5%93%81%E9%9C%80%E6%B1%82%E6%96%87%E6%A1%A3.pdf"

        name = "yoga.epub"
        fileUrl = "http://qiniu.cdn.yituishui.com/2013_Book_YogaTraveling.epub"

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onDownloadTapped(_ sender: Any) {
        let manager = AFURLSessionManager(sessionConfiguration: .default)
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let path = paths[0] + "/" + name
        if (checkFileExisted(path)) {
            // 直接打开
            print("existed")
            if (path.contains(".pdf")) {
                self.openPdf(path)
            } else {
                self.openEpub(path)
            }
            return
        }

        fileUrl = fileUrl.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: fileUrl)!
        let request = URLRequest(url: url)

        let downloadTask = manager.downloadTask(with: request, progress: { (progress) in
            print(progress)
        }, destination: { (url, response) -> URL in
            return URL(fileURLWithPath: path)
        }, completionHandler: { (response, url, error) in
            if (path.contains(".pdf")) {
                self.openPdf(path)
            } else {
                self.openEpub(path)
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
        config.scrollDirection = .horizontal
        let folioReader = FolioReader()
        folioReader.presentReader(parentViewController: self, withEpubPath: path, andConfig: config)
    }

}
