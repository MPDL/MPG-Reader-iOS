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
import RealmSwift

class FirstViewController: UIViewController {

    fileprivate var pdfView: PDFView!
    fileprivate var tableView: UITableView!

    fileprivate var histories: Queue<Book>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: String(describing: BookTableViewCell.self))
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(self.view).offset(30)
            make.bottom.equalTo(-50)
        }

        if let histories = prefs.value(forKey: bookHistoryKey) as? Queue<Book> {
            self.histories = histories
        }
    }

    @IBAction func onEpubTapped(_ sender: Any) {
        let config = FolioReaderConfig()
        config.scrollDirection = .horizontal
        let bookPath = Bundle.main.path(forResource: "2013_Book_YogaTraveling", ofType: "epub")
        let folioReader = FolioReader()
        folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
    }

    @IBAction func onPdfTapped(_ sender: Any) {
        let url = Bundle.main.url(forResource: "2016_Book_YogaUndMeditationFürFührungskr", withExtension: "pdf")!
//        let url = Bundle.main.url(forResource: "swift", withExtension: "pdf")!
        let pdfReaderViewController = PdfReaderViewController(url: url)
        pdfReaderViewController.hidesBottomBarWhenPushed = true
        self.present(pdfReaderViewController, animated: true, completion: nil)
    }
    @IBAction func onSearchTapped(_ sender: Any) {
        let searchViewController = SearchBookViewController()
        searchViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
}

extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let histories = self.histories {
            return histories.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BookTableViewCell.self)) as! BookTableViewCell
        if var histories = self.histories, let book = histories.get(index: indexPath.row) {
            cell.setObject(book: book)
        }
        return cell
    }


}
