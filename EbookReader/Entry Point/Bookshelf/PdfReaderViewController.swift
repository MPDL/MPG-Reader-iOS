//
//  PdfReaderViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/9.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import PDFKit
import SnapKit
import RealmSwift

@objc protocol PdfReaderViewControllerDelegate: class {
    @objc optional func showInfoPage(bookId: String)
}

class PdfReaderViewController: UIViewController, PdfOutlineViewControllerDelegate, PdfSearchViewControllerDelegate {
    fileprivate var pdfDocument: PDFDocument!
    fileprivate var pdfView: PDFView!
    fileprivate var toolView: UIView!
    fileprivate var headerView: UIView!
    fileprivate var overlayView: UIView!
    fileprivate var fontView: UIView!
    fileprivate var navigationItemView: NavigationItemView!
    fileprivate var writeReviewView: WriteReviewView?
    fileprivate var citeView: CiteView?
    fileprivate var shareImageView: UIImageView!

    fileprivate var isStatusBarHidden: Bool = true
    fileprivate var isOverlayHidden: Bool = true
    fileprivate var zoomValue: Float = 5
    fileprivate var book: Book!

    var delegate: PdfReaderViewControllerDelegate?

    init(url: URL, book: Book) {
        super.init(nibName: nil, bundle: nil)
        let document = PDFDocument(url: url)
        self.pdfDocument = document
        self.book = book
    }

    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPageChanged), name: NSNotification.Name.PDFViewPageChanged, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.PDFViewPageChanged, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if keepScreenOnWhileReading {
            UIApplication.shared.isIdleTimerDisabled = true
        }

        pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        pdfView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPdfViewTapped)))
        pdfView.document = pdfDocument
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.displayDirection = .horizontal
        pdfView.maxScaleFactor = 4
        pdfView.minScaleFactor = 0.5
        self.view.addSubview(pdfView)
        pdfView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
        }
        if let cachePageIndex = prefs.value(forKey: book.id) as? Int, let page = pdfDocument.page(at: cachePageIndex) {
            pdfView.go(to: page)
        }

        headerView = UIView()
        headerView.isHidden = isStatusBarHidden
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        self.view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(70)
        }

        let closeImageView = UIImageView()
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCloseTapped)))
        closeImageView.image = UIImage(named: "navi-close")
        headerView.addSubview(closeImageView)
        closeImageView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalTo(headerView).offset(5)
        }

        let outlineImageView = UIImageView()
        outlineImageView.isUserInteractionEnabled = true
        outlineImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOutlineTapped)))
        outlineImageView.image = UIImage(named: "navi-index")
        headerView.addSubview(outlineImageView)
        outlineImageView.snp.makeConstraints { (make) in
            make.left.equalTo(closeImageView.snp.right).offset(25)
            make.centerY.equalTo(headerView).offset(5)
        }

        let moreImageView = UIImageView()
        moreImageView.isUserInteractionEnabled = true
        moreImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMoreTapped)))
        moreImageView.image = UIImage(named: "icon-navbar-more")
        headerView.addSubview(moreImageView)
        moreImageView.snp.makeConstraints { (make) in
            make.right.equalTo(headerView).offset(-20)
            make.centerY.equalTo(headerView).offset(5)
        }

        let searchImageView = UIImageView()
        searchImageView.isUserInteractionEnabled = true
        searchImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSearchTapped)))
        searchImageView.image = UIImage(named: "navi-search")
        headerView.addSubview(searchImageView)
        searchImageView.snp.makeConstraints { (make) in
            make.right.equalTo(moreImageView.snp.left).offset(-25)
            make.centerY.equalTo(headerView).offset(5)
        }

        let fontImageView = UIImageView()
        fontImageView.isUserInteractionEnabled = true
        fontImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onFontTapped)))
        fontImageView.image = UIImage(named: "navi-font")
        headerView.addSubview(fontImageView)
        fontImageView.snp.makeConstraints { (make) in
            make.right.equalTo(searchImageView.snp.left).offset(-25)
            make.centerY.equalTo(headerView).offset(5)
        }

        shareImageView = UIImageView()
        shareImageView.isUserInteractionEnabled = true
        shareImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onShareTapped)))
        shareImageView.image = UIImage(named: "icon-navbar-share")
        headerView.addSubview(shareImageView)
        shareImageView.snp.makeConstraints { (make) in
            make.right.equalTo(fontImageView.snp.left).offset(-25)
            make.centerY.equalTo(headerView).offset(5)
        }

        overlayView = UIView()
        overlayView.isHidden = isOverlayHidden
        overlayView.isUserInteractionEnabled = true
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOverlayTapped)))
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        self.view.addSubview(overlayView)
        overlayView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        fontView = UIView()
        fontView.isHidden = isOverlayHidden
        fontView.backgroundColor = UIColor.white
        self.view.addSubview(fontView)
        fontView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(0)
            make.height.equalTo(100)
        }
        let fontSlider = UISlider()
        fontSlider.tintColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
        fontSlider.isContinuous = false
        fontSlider.maximumValue = 10
        fontSlider.value = zoomValue
        fontSlider.minimumValue = 1
        fontSlider.addTarget(self, action: #selector(onSliderChanged(slider:)), for: .valueChanged)
        fontView.addSubview(fontSlider)
        fontSlider.snp.makeConstraints { (make) in
            make.center.equalTo(fontView)
            make.width.equalTo(400)
            make.height.equalTo(40)
        }
        let zoomOutImageView = UIImageView()
        zoomOutImageView.image = UIImage(named: "icon-zoom-out")
        fontView.addSubview(zoomOutImageView)
        zoomOutImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(fontSlider)
            make.right.equalTo(fontSlider.snp.left).offset(-33)
        }
        let zoomInImageView = UIImageView()
        zoomInImageView.image = UIImage(named: "icon-zoom-in")
        fontView.addSubview(zoomInImageView)
        zoomInImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(fontSlider)
            make.left.equalTo(fontSlider.snp.right).offset(33)
        }

        navigationItemView = NavigationItemView(bookId: book.id, delegate: self)
        self.view.addSubview(navigationItemView)
        navigationItemView.snp.makeConstraints { (make) in
            make.top.equalTo(70)
            make.left.right.bottom.equalTo(0)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.pdfView.autoScales = true
    }

    @objc func onPageChanged() {
        if let currentPage = pdfView.currentPage {
            let currentPageIndex = pdfDocument.index(for: currentPage)
            prefs.set(currentPageIndex, forKey: book.id)
            prefs.synchronize()
        }
    }

    @objc func onDeviceRotated() {
//        switch UIDevice.current.orientation {
//            case .portrait, .portraitUpsideDown:
//                pdfView.displayDirection = .vertical
//                break
//            case .landscapeLeft, .landscapeRight:
//                pdfView.displayDirection = .horizontal
//                break
//            default:
//                pdfView.displayDirection = .vertical
//                break
//            }
    }

    @objc func onSliderChanged(slider: UISlider) {
        let scaleFactor = CGFloat(slider.value / 5) * pdfView.scaleFactorForSizeToFit
        pdfView.scaleFactor = scaleFactor
    }

    @objc func onOverlayTapped() {
        isOverlayHidden = !isOverlayHidden
        overlayView.isHidden = isOverlayHidden
        fontView.isHidden = isOverlayHidden
    }

    @objc func onMoreTapped() {
        navigationItemView.display()
    }

    @objc func onShareTapped() {
        var title = book.title
        if book.publicationDates.count > 0 {
            title += " (\(book.publicationDates.joined(separator: ", ")))"
        }
        let jumpValue = "[Read in MPG Reader](mpgreader://\(String(describing: book.id)))"
        let linkValue = NSURL(string: book.url)!
        let activityItems = [title, jumpValue, linkValue] as [Any]
        let viewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        viewController.excludedActivityTypes = [.airDrop, .assignToContact, .markupAsPDF, .message, .openInIBooks, .postToFacebook, .postToFlickr, .postToTencentWeibo, .postToTwitter, .postToVimeo, .postToWeibo, .print, .saveToCameraRoll]
        self.present(viewController, animated: true)

        if let popOver = viewController.popoverPresentationController {
            popOver.sourceView = self.view
            popOver.sourceRect = self.shareImageView.frame
        }
    }

    @objc func onFontTapped() {
        isOverlayHidden = !isOverlayHidden
        overlayView.isHidden = isOverlayHidden
        fontView.isHidden = isOverlayHidden
    }

    @objc func onPdfViewTapped() {
        self.isStatusBarHidden = !self.isStatusBarHidden
        self.setNeedsStatusBarAppearanceUpdate()
        self.headerView.isHidden = self.isStatusBarHidden
    }

    @objc func onOutlineTapped() {
        let outlineViewController = PdfOutlineViewController(document: pdfDocument, delegate: self)
        self.present(outlineViewController, animated: true, completion: nil)
    }

    @objc func onSearchTapped() {
        let searchViewController = PdfSearchViewController(document: pdfDocument, delegate: self)
        self.present(searchViewController, animated: true, completion: nil)
    }

    @objc func onCloseTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func didSelectOutline(_ outline: PDFOutline) {
        if let goToAction = outline.action as? PDFActionGoTo {
            self.pdfView.go(to: goToAction.destination)
        }
    }

    func didSelectSearchResult(_ selection: PDFSelection) {
        self.pdfView.currentSelection = selection
        self.pdfView.go(to: selection)
    }

}

extension PdfReaderViewController: NavigationItemDelegate {
    func onOneActionTapped(action: NaviAction) {
        switch action {
            case .writeReview:
                if let writeReviewView = writeReviewView {
                    writeReviewView.display()
                } else {
                    writeReviewView = WriteReviewView(book: book)
                    self.view.addSubview(writeReviewView!)
                    writeReviewView?.snp.makeConstraints({ (make) in
                        make.edges.equalTo(self.view)
                    })
                    writeReviewView?.display()
                }
                break
            case .citeItem:
                if let citeView = citeView {
                    citeView.display()
                } else {
                    citeView = CiteView(book: book)
                    self.view.addSubview(citeView!)
                    citeView?.snp.makeConstraints({ (make) in
                        make.edges.equalTo(self.view)
                    })
                    citeView?.display()
                }
                break
            case .gotoInfo:
                self.dismiss(animated: true) {
                    if let delegate = self.delegate {
                        delegate.showInfoPage?(bookId: self.book.id)
                    }
                }
                break
        }
    }
}
