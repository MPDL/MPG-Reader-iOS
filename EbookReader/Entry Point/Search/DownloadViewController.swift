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
import MJRefresh

class DownloadViewController: UIViewController {
    fileprivate var bookImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var authorLabel: UILabel!
    fileprivate var introductionTitleLabel: UILabel!
    fileprivate var publicationDateLabel: UILabel!
    fileprivate var publicationPressLabel: UILabel!
    fileprivate var isbnLabel: UILabel!
    fileprivate var introductionLabel: UILabel!
    fileprivate var progressBar: UIProgressView!
    fileprivate var downloadLabel: UILabel!
    fileprivate var actionView: UIView!
    fileprivate var navigationItemView: NavigationItemView!
    fileprivate var writeReviewView: WriteReviewView?
    fileprivate var citeView: CiteView?
    fileprivate var ratingLabel: UILabel!
    fileprivate var starImageView: UIImageView!
    fileprivate var reviewView: UIView!
    fileprivate var addReadingListTextLabel: UILabel!
    fileprivate var addReadingListView: UIControl!
    fileprivate var downloadView: UIView!
    fileprivate var shareBarButton: UIBarButtonItem!
    fileprivate var folioReader: FolioReader!

    fileprivate var book: Book!
    fileprivate var bookId: String!
    fileprivate var bookStatistic: BookStatistic!
    fileprivate var path: String!
    fileprivate var delegate: PdfReaderViewControllerDelegate?
    fileprivate var reviewPage: Int = 0
    fileprivate var reviewPageSize: Int = 10
    fileprivate var reviewFooter: MJRefreshAutoNormalFooter?

    fileprivate var reviews: [Review] = []

    init(bookId: String) {
        super.init(nibName: nil, bundle: nil)
        self.bookId = bookId
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
        NotificationCenter.default.addObserver(self, selector: #selector(loadStatistic), name: .readingListDidChange, object: nil)

        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.setupUI()
        self.loadData()
    }

    fileprivate func loadData() {
        if networkStatus != .notReachable {
            loadBook()
            loadStatistic()
            loadReviews()
        } else {
            // load local book
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id == %@", bookId)
            let results = realm.objects(Book.self).filter(predicate)
            if results.count > 0 {
                self.book = results.first
                self.setObject()
            }
        }
    }

    fileprivate func loadReviews() {
        NetworkManager.sharedInstance().POST(path: "rest/ebook/" + bookId + "/reviews",
            parameters: ["pageNumber": reviewPage, "pageSize": reviewPageSize],
            modelClass: PageDTO<Review>.self,
            success: { (pageDTO) in
                self.reviewFooter?.endRefreshing()
                if let pageDTO = pageDTO, let reviews = pageDTO.content, reviews.count > 0 {
                    if self.reviewPage == 0 {
                        self.reviews = reviews
                    } else {
                        self.reviews.append(contentsOf: reviews)
                        for subview in self.reviewView.subviews {
                            subview.removeFromSuperview()
                        }
                    }
                    self.setReviews()
                } else if self.reviewPage > 0 {
                    PopupView.showWithContent("No more results")
                    self.reviewPage -= 1
                }
            },
            failure: { (error) in
                self.reviewFooter?.endRefreshing()
            })
    }

    @objc fileprivate func loadMoreReviews() {
        reviewPage += 1
        loadReviews()
    }

    @objc fileprivate func loadStatistic() {
        NetworkManager.sharedInstance().GET(path: "rest/ebook/" + bookId,
            parameters: nil,
            modelClass: BookStatistic.self,
            success: { (bookStatistic) in
                self.bookStatistic = bookStatistic
                self.setStatistic()
            },
            failure: { (error) in
                print(error)
            })
    }

    fileprivate func loadBook() {
        NetworkManager.sharedInstance().GET(path: "rest/ebook/record",
            parameters: ["bookId": bookId],
            modelClass: Book.self,
            success: { (book) in
                self.book = book
                self.setObject()
            },
            failure: { (error) in
                print(error)
            })
    }

    fileprivate func setupUI() {
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
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

        actionView = UIView()
        actionView.isHidden = true
        contentView.addSubview(actionView)
        actionView.snp.makeConstraints { (make) in
            make.top.equalTo(bookImageView.snp.bottom).offset(26)
            make.left.equalTo(bookImageView)
            make.right.equalTo(titleLabel)
            make.height.equalTo(50)
        }
        let ratingView = UIView()
        actionView.addSubview(ratingView)
        ratingView.snp.makeConstraints { (make) in
            make.centerY.equalTo(actionView)
            make.left.equalTo(21)
        }
        starImageView = UIImageView()
        ratingView.addSubview(starImageView)
        starImageView.snp.makeConstraints { (make) in
            make.width.equalTo(130)
            make.height.equalTo(22)
            make.top.left.right.equalTo(0)
        }
        ratingLabel = UILabel()
        ratingLabel.font = UIFont.systemFont(ofSize: 12)
        ratingLabel.textColor = UIColor(hex: 0x999999)
        ratingView.addSubview(ratingLabel)
        ratingLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(ratingView)
            make.top.equalTo(starImageView.snp.bottom).offset(12)
            make.bottom.equalTo(0)
        }
        addReadingListView = UIControl()
        addReadingListView.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            guard let self = self, let bookStatistic = self.bookStatistic, let inReadingList = bookStatistic.inReadingList else {
                return
            }
            if inReadingList {
                NetworkManager.sharedInstance().POST(path: "rest/user/readinglist/delete",
                    parameters: ["bookIds": [self.bookId]],
                    modelClass: ReadingList.self,
                    success: { (pageDTO) in
                        PopupView.showWithContent("Remove from the reading list successfully.")
                        NotificationCenter.default.post(name: .readingListDidChange, object: nil)
                    },
                    failure: nil)
            } else {
                NetworkManager.sharedInstance().POST(path: "rest/user/readinglist/add/" + self.bookId,
                    parameters: nil,
                    modelClass: ReadingList.self,
                    success: { (pageDTO) in
                        PopupView.showWithContent("Add into the reading list successfully.")
                        NotificationCenter.default.post(name: .readingListDidChange, object: nil)
                    },
                    failure: nil)
            }
        }
        addReadingListView.layer.borderWidth = 2
        addReadingListView.layer.borderColor = UIColor(hex: 0x009FA1).cgColor
        addReadingListView.layer.cornerRadius = 8
        actionView.addSubview(addReadingListView)
        addReadingListView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.centerY.equalTo(actionView)
            make.width.equalTo(220)
            make.height.equalTo(50)
        }
        addReadingListTextLabel = UILabel()
        addReadingListTextLabel.text = "Add to Reading List"
        addReadingListTextLabel.textColor = UIColor(hex: 0x009FA1)
        addReadingListTextLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addReadingListView.addSubview(addReadingListTextLabel)
        addReadingListTextLabel.snp.makeConstraints { (make) in
            make.center.equalTo(addReadingListView)
        }
        downloadView = UIView()
        downloadView.layer.masksToBounds = true
        downloadView.layer.cornerRadius = 8
        actionView.addSubview(downloadView)
        downloadView.snp.makeConstraints { (make) in
            make.left.equalTo(addReadingListView.snp.right).offset(32)
            make.centerY.equalTo(actionView)
            make.width.height.equalTo(addReadingListView)
        }
        progressBar = UIProgressView()
        progressBar.isUserInteractionEnabled = true
        progressBar.layer.masksToBounds = true
        progressBar.progressTintColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
        progressBar.backgroundColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
        downloadView.addSubview(progressBar)
        progressBar.snp.makeConstraints { (make) in
            make.edges.equalTo(downloadView)
        }
        downloadLabel = UILabel()
        downloadLabel.font = UIFont.boldSystemFont(ofSize: 20)
        downloadLabel.textColor = UIColor.white
        downloadView.addSubview(downloadLabel)
        downloadLabel.snp.makeConstraints { (make) in
            make.center.equalTo(downloadView)
        }

        introductionTitleLabel = UILabel()
        introductionTitleLabel.font = UIFont.systemFont(ofSize: 24)
        introductionTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        contentView.addSubview(introductionTitleLabel)
        introductionTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(actionView.snp.bottom).offset(60)
            make.left.equalTo(35)
        }
        introductionLabel = UILabel()
        introductionLabel.font = UIFont.systemFont(ofSize: 18)
        introductionLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        introductionLabel.numberOfLines = 0
        contentView.addSubview(introductionLabel)
        introductionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(introductionTitleLabel.snp.bottom).offset(30)
            make.left.equalTo(introductionTitleLabel)
            make.right.equalTo(-35)
        }

        reviewView = UIView()
        contentView.addSubview(reviewView)
        reviewView.snp.makeConstraints { (make) in
            make.top.equalTo(introductionLabel.snp.bottom).offset(60)
            make.bottom.equalTo(-30)
            make.left.equalTo(35)
            make.right.equalTo(-35)
        }
    }

    fileprivate func setReviews() {
        let reviewTitleLabel = UILabel()
        reviewTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        reviewTitleLabel.textColor = UIColor(hex: 0x333333)
        reviewTitleLabel.text = "User Reviews:"
        reviewView.addSubview(reviewTitleLabel)
        reviewTitleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
        }
        let commentsView = ReviewsView(reviews: reviews)
        reviewFooter = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreReviews))
        commentsView.mj_footer = reviewFooter
        reviewView.addSubview(commentsView)
        commentsView.snp.makeConstraints { (make) in
            make.top.equalTo(reviewTitleLabel.snp.bottom).offset(30)
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(500)
        }
    }

    fileprivate func setStatistic() {
        ratingLabel?.text = "\(String(describing: bookStatistic?.reviews ?? 0)) Ratings"
        let rating = ceil(bookStatistic?.rating ?? 0)
        starImageView?.image = UIImage(named: "icon-star-\(rating)")
        if let inReadingList = bookStatistic?.inReadingList, inReadingList {
            addReadingListTextLabel.text = "Remove from Reading List"
        } else {
            addReadingListTextLabel.text = "Add to Reading List"
        }
    }

    fileprivate func setObject() {
        if let thumbnail = book.thumbnail {
            bookImageView.kf.setImage(with: URL(string: thumbnail))
        } else {
            bookImageView.image = UIImage(named: "default-book-cover")
        }
        titleLabel.text = book.title
        introductionTitleLabel.text = "Introduction"
        introductionLabel.text = book.abstract
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
        actionView.isHidden = false
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        path = paths[0] + "/" + book.id
        if (checkFileExisted(path)) {
            progressBar.progress = 100
            downloadLabel.text = "Start Reading"
            progressBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOpenBookTapped)))
        } else {
            progressBar.progress = 0
            
            if (book.downloadUrl == "") {
                downloadLabel.text = "Currently unavailable"
                progressBar.backgroundColor = UIColor.init(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
            } else if (book.pdf) {
                downloadLabel.text = "Download PDF"
            } else {
                downloadLabel.text = "Download EPUB"
            }
            progressBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDownloadTapped)))
        }
    }

    @objc func onOpenBookTapped() {
        if book.pdf {
            let url = URL(fileURLWithPath: path)
            let pdfReaderViewController = PdfReaderViewController(url: url, book: book)
            self.present(pdfReaderViewController, animated: true, completion: nil)
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
    }
    
    @objc func onDownloadTapped(_ sender: Any) {
        if downloadWithWifiOnly && AFNetworkReachabilityManager.shared().networkReachabilityStatus != .reachableViaWiFi {
            PopupView.showWithContent("Download on Wifi Only")
            return
        }
        guard book.downloadUrl != "" else {
            //PopupView.showWithContent("Download link not found")
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
                self.notifyServer()
            } else {
                PopupView.showWithContent("Download failed, Please try again")
            }
        })
        downloadTask.resume()
    }

    fileprivate func notifyServer() {
        NetworkManager.sharedInstance().POST(path: "rest/statistic/downloaded/" + bookId,
            parameters: nil,
            modelClass: BookStatistic.self,
            success: { (pageDTO) in
            },
            failure: nil)
    }

    fileprivate func saveBook() {
        let realm = try! Realm()

        let predicate = NSPredicate(format: "id == %@", book.id)
        if !realm.objects(Book.self).filter(predicate).isEmpty {
            PopupView.showWithContent("Book already exists")
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
        AppDelegate.getTopViewController().present(viewController, animated: true)

        if let popOver = viewController.popoverPresentationController {
            popOver.barButtonItem = shareBarButton
        }
    }

}

extension DownloadViewController: FolioReaderDelegate {
    func folioReader(_ folioReader: FolioReader, didFinishedLoading book: FRBook) {
        let centerViewController = (AppDelegate.getTopViewController() as! FolioReaderContainer).centerViewController!
        let rightBarButtonItems = centerViewController.navigationItem.rightBarButtonItems!
        let item1 = UIBarButtonItem(image: UIImage(named: "icon-navbar-more"), style: .plain, target: self, action: #selector(onMoreTapped))
        let item2 = rightBarButtonItems[0]
        shareBarButton = UIBarButtonItem(image: UIImage(named: "icon-navbar-share"), style: .plain, target: self, action: #selector(onShareTapped))
        centerViewController.navigationItem.rightBarButtonItems = [item1, item2, shareBarButton]
    }
}

extension DownloadViewController: NavigationItemDelegate {
    func onOneActionTapped(action: NaviAction) {
        switch action {
            case .writeReview:
                if let writeReviewView = writeReviewView {
                    writeReviewView.display()
                } else {
                    writeReviewView = WriteReviewView(book: book)
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
                    citeView = CiteView(book: book)
                    AppDelegate.getTopView().addSubview(citeView!)
                    citeView?.snp.makeConstraints({ (make) in
                        make.edges.equalTo(AppDelegate.getTopView())
                    })
                    citeView?.display()
                }
                break
            case .gotoInfo:
                self.dismiss(animated: true, completion: nil)
                self.folioReader.close()
                break
        }
    }
}
