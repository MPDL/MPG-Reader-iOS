//
//  HomeViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/11/5.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit
import ReactiveSwift
import AFNetworking
import MJRefresh

class HomeViewController: UIViewController {

    fileprivate var magazineView: UIView!
    fileprivate var searchHistoryGalleryView: BookGalleryView!
    fileprivate var readingListGalleryView: BookGalleryView!
    fileprivate var mostDownloadedGalleryView: BookGalleryView!
    fileprivate var topRatedGalleryView: BookGalleryView!
    fileprivate var refreshHeader: MJRefreshNormalHeader!

    fileprivate var readingListPage = 0
    fileprivate var topDownloadsPage = 0
    fileprivate var topScoresPage = 0

    fileprivate let pageSize = 10

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadHistory), name: .searchResultsDidReturn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadReadingList), name: .readingListDidChange, object: nil)

        manager.setReachabilityStatusChange { (status) in
            if status == .unknown || status == .notReachable {
                networkStatus = .notReachable
                self.setupEmptyView()
            } else {
                networkStatus = status
                self.setupView()
            }
        }

        checkVersion()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    fileprivate func checkVersion () {
        NetworkManager.sharedInstance().GET(path: "rest/info/version",
            parameters: nil,
            modelClass: Bool.self,
            success: { (hasNewVersion) in
                PopupView.showLoading(false)
                if let hasNewVersion = hasNewVersion, hasNewVersion {
                    PopupView.showWithContent("Please update your MPG Reader to the newest version!")
                }
            }, failure: nil)
    }

    fileprivate func generateMagazineView(image: UIImage, title: String, url: String) -> UIView {
        let view = UIControl()
        view.isUserInteractionEnabled = true
        view.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            let webviewController = WebviewViewController()
            webviewController.urlString = url
            self?.navigationController?.pushViewController(webviewController, animated: true)
        }
        let imageView = UIImageView()
        imageView.image = image
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(0)
        }
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = title
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(22)
            make.centerX.equalTo(view)
            make.bottom.equalTo(0)
            make.width.equalTo(120)
        }
        return view
    }

    fileprivate func setupEmptyView() {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "icon-home-logo")
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(46)
        }
        let separator = UIView()
        separator.backgroundColor = UIColor(hex: 0xCFCFCF)
        view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).offset(18)
            make.left.equalTo(33)
            make.right.equalTo(-33)
            make.height.equalTo(1)
        }
        let emptyView = UIView()
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(543)
        }
        let emptyTitleLabel = UILabel()
        emptyTitleLabel.text = "You are offline!"
        emptyTitleLabel.textColor = UIColor(hex: 0x333333)
        emptyTitleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        emptyView.addSubview(emptyTitleLabel)
        emptyTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.centerX.equalTo(emptyView)
        }
        let contentLabel = UILabel()
        contentLabel.text = "Please check your internet connection and try again."
        contentLabel.textColor = UIColor(hex: 0x999999)
        contentLabel.font = UIFont.systemFont(ofSize: 20)
        emptyView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(emptyView)
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(13)
        }
        let retryControl = UIControl()
        retryControl.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (control) in
            if let self = self, networkStatus != .notReachable {
                self.setupView()
            }
        }
        retryControl.backgroundColor = UIColor(hex: 0x009FA1)
        retryControl.layer.cornerRadius = 8
        emptyView.addSubview(retryControl)
        retryControl.snp.makeConstraints { (make) in
            make.width.equalTo(220)
            make.height.equalTo(50)
            make.top.equalTo(contentLabel.snp.bottom).offset(37)
            make.bottom.equalTo(0)
            make.centerX.equalTo(emptyView)
        }
        let retryLabel = UILabel()
        retryLabel.text = "RETRY"
        retryLabel.textColor = UIColor.white
        retryLabel.font = UIFont.boldSystemFont(ofSize: 20)
        retryControl.addSubview(retryLabel)
        retryLabel.snp.makeConstraints { (make) in
            make.center.equalTo(retryControl)
        }
    }

    fileprivate func setupView(){
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        let scrollView = UIScrollView()
        refreshHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(reloadData))
        refreshHeader.ignoredScrollViewContentInsetTop = 20
        scrollView.mj_header = refreshHeader
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "icon-home-logo")
        contentView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(46)
        }

        magazineView = UIView()
        contentView.addSubview(magazineView)
        magazineView.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).offset(18)
            make.left.equalTo(33)
            make.right.equalTo(-33)
        }
        let separator = UIView()
        separator.backgroundColor = UIColor(hex: 0xCFCFCF)
        magazineView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(1)
        }
        let titleLabel = UILabel()
        titleLabel.text = "MAGAZINES AND NEWSPAPER"
        titleLabel.textColor = UIColor(hex: 0x999999)
        magazineView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(separator.snp.bottom).offset(19)
            make.left.equalTo(15)
        }
        let magazineContentView = UIView()
        magazineView.addSubview(magazineContentView)
        magazineContentView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(37)
            make.left.equalTo(magazineView).offset(10)
            make.bottom.equalTo(-27)
        }
        let nyMagazineView = generateMagazineView(image: UIImage(named: "magazine-ny")!, title: "NY Times", url: "https://www.nytimes.com/")
        magazineContentView.addSubview(nyMagazineView)
        nyMagazineView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(0)
            make.width.equalTo(160)
        }
        let prMagazineView = generateMagazineView(image: UIImage(named: "magazine-pr")!, title: "PressReader", url: "https://www.pressreader.com/catalog/")
        magazineContentView.addSubview(prMagazineView)
        prMagazineView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalTo(0)
            make.left.equalTo(nyMagazineView.snp.right)
            make.width.equalTo(160)
        }
//        let fazMagazineView = generateMagazineView(image: UIImage(named: "magazine-faz")!, title: "FAZ", url: "https://www.faz.net/")
//        magazineContentView.addSubview(fazMagazineView)
//        fazMagazineView.snp.makeConstraints { (make) in
//            make.top.bottom.right.equalTo(0)
//            make.left.equalTo(prMagazineView.snp.right)
//            make.width.equalTo(160)
//        }
        
        searchHistoryGalleryView = BookGalleryView(title: "SEARCH HISTORY", galleryType: GalleryType.searchHistory, delegate: self)
        contentView.addSubview(searchHistoryGalleryView)
        searchHistoryGalleryView.snp.makeConstraints { (make) in
            make.left.right.equalTo(magazineView)
            make.top.equalTo(magazineView.snp.bottom)
            make.height.equalTo(0)
        }

        readingListGalleryView = BookGalleryView(title: "MY READING LIST", galleryType: GalleryType.readingList, delegate: self)
        contentView.addSubview(readingListGalleryView)
        readingListGalleryView.snp.makeConstraints { (make) in
            make.left.right.equalTo(magazineView)
            make.top.equalTo(searchHistoryGalleryView.snp.bottom)
            make.height.equalTo(0)
        }

        mostDownloadedGalleryView = BookGalleryView(title: "MOST DOWNLOADED BOOKS", galleryType: GalleryType.mostDownloaded, delegate: self)
        contentView.addSubview(mostDownloadedGalleryView)
        mostDownloadedGalleryView.snp.makeConstraints { (make) in
            make.left.right.equalTo(magazineView)
            make.top.equalTo(readingListGalleryView.snp.bottom)
            make.height.equalTo(0)
        }

        topRatedGalleryView = BookGalleryView(title: "TOP RATED BOOKS", galleryType: GalleryType.topRated, delegate: self)
        contentView.addSubview(topRatedGalleryView)
        topRatedGalleryView.snp.makeConstraints { (make) in
            make.left.right.equalTo(magazineView)
            make.top.equalTo(mostDownloadedGalleryView.snp.bottom)
            make.bottom.equalTo(0)
            make.height.equalTo(0)
        }

        reloadData()
    }

    @objc fileprivate func loadHistoryBooks() {
        var histories: [Book] = []
        if let data = prefs.value(forKey: bookHistoryKey) as? Data {
            do {
                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
                if let saved = try unarchiver.decodeTopLevelDecodable([Book].self, forKey: NSKeyedArchiveRootObjectKey) {
                    histories = saved
                }
            } catch {
                print("unarchiving failure: \(error)")
            }
        }
        if histories.count > 0 {
            searchHistoryGalleryView.snp.remakeConstraints { (make) in
                make.left.right.equalTo(magazineView)
                make.top.equalTo(magazineView.snp.bottom)
            }
            var bookStatisticList: [BookStatistic] = []
            for history in histories {
                let bookStatistic = BookStatistic()
                bookStatistic.bookCoverURL = history.thumbnail
                bookStatistic.bookName = history.title
                bookStatistic.bookId = history.id
                bookStatisticList.append(bookStatistic)
            }
            searchHistoryGalleryView.clear()
            searchHistoryGalleryView.appendBooks(books: bookStatisticList)
        } else {
            searchHistoryGalleryView.snp.remakeConstraints { (make) in
                make.left.right.equalTo(magazineView)
                make.top.equalTo(magazineView.snp.bottom)
                make.height.equalTo(0)
            }
        }
        view.layoutIfNeeded()
    }

    fileprivate func loadTopDownloads() {
        let parameters = ["pageNumber": topDownloadsPage, "pageSize": pageSize]
        NetworkManager.sharedInstance().POST(
            path: "rest/statistic/topDownloads",
            parameters: parameters,
            modelClass: PageDTO<BookStatistic>.self,
            success: { (pageDTO) in
                PopupView.showLoading(false)
                if let pageDTO = pageDTO, let bookStatisticList = pageDTO.content, bookStatisticList.count > 0 {
                    self.mostDownloadedGalleryView.snp.remakeConstraints { (make) in
                        make.left.right.equalTo(self.magazineView)
                        make.top.equalTo(self.readingListGalleryView.snp.bottom)
                    }
                    if self.topDownloadsPage == 0 {
                        self.mostDownloadedGalleryView.clear()
                    }
                    self.mostDownloadedGalleryView.appendBooks(books: bookStatisticList)
                    self.view.layoutIfNeeded()
                } else if self.topDownloadsPage == 0 {
                    // no data
                    self.mostDownloadedGalleryView.snp.remakeConstraints { (make) in
                        make.left.right.equalTo(self.magazineView)
                        make.top.equalTo(self.readingListGalleryView.snp.bottom)
                        make.height.equalTo(0)
                    }
                    self.view.layoutIfNeeded()
                } else {
                    // no more data
                    self.topDownloadsPage = self.topDownloadsPage - 1
                    PopupView.showWithContent("No more results")
                }
            }, failure: nil)
    }

    fileprivate func loadTopScores() {
        let parameters = ["pageNumber": topScoresPage, "pageSize": pageSize]
        NetworkManager.sharedInstance().POST(
            path: "rest/statistic/topScores",
            parameters: parameters,
            modelClass: PageDTO<BookStatistic>.self,
            success: { (pageDTO) in
                PopupView.showLoading(false)
                if let pageDTO = pageDTO, let bookStatisticList = pageDTO.content, bookStatisticList.count > 0 {
                    self.topRatedGalleryView.snp.remakeConstraints { (make) in
                        make.left.right.equalTo(self.magazineView)
                        make.top.equalTo(self.mostDownloadedGalleryView.snp.bottom)
                        make.bottom.equalTo(0)
                    }
                    if self.topScoresPage == 0 {
                        self.topRatedGalleryView.clear()
                    }
                    self.topRatedGalleryView.appendBooks(books: bookStatisticList)
                    self.view.layoutIfNeeded()
                } else if self.topScoresPage == 0 {
                    // no data
                    self.topRatedGalleryView.snp.remakeConstraints { (make) in
                        make.left.right.equalTo(self.magazineView)
                        make.top.equalTo(self.mostDownloadedGalleryView.snp.bottom)
                        make.bottom.equalTo(0)
                        make.height.equalTo(0)
                    }
                    self.view.layoutIfNeeded()
                } else {
                    // no more data
                    self.topScoresPage = self.topScoresPage - 1
                    PopupView.showWithContent("No more results")
                }
            }, failure: nil)
    }

    @objc fileprivate func loadReadingList() {
        let parameters = ["pageNumber": readingListPage, "pageSize": pageSize]
        NetworkManager.sharedInstance().POST(
            path: "rest/user/readinglist",
            parameters: parameters,
            modelClass: PageDTO<BookStatistic>.self,
            success: { (pageDTO) in
                PopupView.showLoading(false)
                if let pageDTO = pageDTO, let bookStatisticList = pageDTO.content, bookStatisticList.count > 0 {
                    self.readingListGalleryView.snp.remakeConstraints { (make) in
                        make.left.right.equalTo(self.magazineView)
                        make.top.equalTo(self.searchHistoryGalleryView.snp.bottom)
                    }
                    if self.readingListPage == 0 {
                        self.readingListGalleryView.clear()
                    }
                    self.readingListGalleryView.appendBooks(books: bookStatisticList)
                    self.view.layoutIfNeeded()
                } else if self.readingListPage == 0 {
                    // no data
                    self.readingListGalleryView.snp.remakeConstraints { (make) in
                        make.left.right.equalTo(self.magazineView)
                        make.top.equalTo(self.searchHistoryGalleryView.snp.bottom)
                        make.height.equalTo(0)
                    }
                    self.view.layoutIfNeeded()
                } else {
                    // no more data
                    self.readingListPage = self.readingListPage - 1
                    PopupView.showWithContent("No more results")
                }
            }, failure: nil)
    }

    fileprivate func loadData() {
        loadHistoryBooks()
        loadTopScores()
        loadTopDownloads()
        loadReadingList()
    }

    @objc fileprivate func reloadHistory() {
        searchHistoryGalleryView.clear()
        loadHistoryBooks()
    }

    @objc fileprivate func reloadReadingList() {
        readingListPage = 0
        readingListGalleryView.clear()
        loadReadingList()
    }

    @objc fileprivate func reloadData() {
        topScoresPage = 0
        topDownloadsPage = 0
        readingListPage = 0

        searchHistoryGalleryView.clear()
        readingListGalleryView.clear()
        topRatedGalleryView.clear()
        mostDownloadedGalleryView.clear()

        loadData()
        refreshHeader.endRefreshing()
    }

}

extension HomeViewController: BookGalleryViewDelegate {
    func onScrollViewReachBottom(galleryType: GalleryType) {
        switch galleryType {
            case .searchHistory:
                break
            case .readingList:
                readingListPage += 1
                loadReadingList()
                break
            case .mostDownloaded:
                topDownloadsPage += 1
                loadTopDownloads()
                break
            case .topRated:
                topScoresPage += 1
                loadTopScores()
                break
        }
    }

    func onBookSelected(bookId: String) {
        let viewController = DownloadViewController(bookId: bookId)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
