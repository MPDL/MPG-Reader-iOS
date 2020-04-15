//
//  FirstViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/7.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import FolioReaderKit
import PDFKit

class FirstViewController: UIViewController {

    var pdfView: PDFView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onEpubTapped(_ sender: Any) {
        let config = FolioReaderConfig()
        let bookPath = Bundle.main.path(forResource: "2013_Book_YogaTraveling", ofType: "epub")
        let folioReader = FolioReader()
        folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
    }

    @IBAction func onPdfTapped(_ sender: Any) {
        let url = Bundle.main.url(forResource: "2016_Book_YogaUndMeditationFürFührungskr", withExtension: "pdf")!
        let pdfReaderViewController = PdfReaderViewController(url: url)
        pdfReaderViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(pdfReaderViewController, animated: true)
    }
}

