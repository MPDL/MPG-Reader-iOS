//
//  PdfReaderViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/9.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import PDFKit

class PdfReaderViewController: UIViewController {
    var pdfDocument: PDFDocument?
    var pdfView: PDFView!
    var toolView: UIView!

//    override var prefersStatusBarHidden: Bool {
//        return true
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        pdfView = PDFView(frame: CGRect(x: -10, y: -15, width: self.view.frame.width + 20, height: self.view.frame.height + 30))
        pdfView = PDFView(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64))
        pdfView.document = pdfDocument
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.displayDirection = .horizontal
        pdfView.autoScales = true
        self.view.addSubview(pdfView)
    }

    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        let document = PDFDocument(url: url)
        self.pdfDocument = document
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
