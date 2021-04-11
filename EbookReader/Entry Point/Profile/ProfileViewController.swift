//
//  ProfileViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/29.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit

let READERTHEMEKEY = "ReaderThemeIsDark"

class ProfileViewController: UIViewController {
    
    fileprivate var colorTheme: UIUserInterfaceStyle = .light;
    fileprivate var colorThemeView: UIControl!
    fileprivate var colorThemeViewAllLabel: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = COLOR_background
        colorTheme = UserDefaults.standard.bool(forKey: READERTHEMEKEY) ? .dark : .light
        // Do any additional setup after loading the view.
        let scrollView = UIScrollView()
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

        let headerView = UIView()
        headerView.backgroundColor = COLOR_profileCell
        contentView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
        }
        let avatarImageView = UIImageView()
        avatarImageView.image = UIImage(named: "avatar")
        headerView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { (make) in
            make.top.equalTo(70)
            make.centerX.equalTo(headerView)
        }
        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
        nameLabel.textColor = COLOR_profileCellTitleText
        headerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(headerView)
            make.top.equalTo(avatarImageView.snp.bottom).offset(26)
            make.bottom.equalTo(-40)
        }

        let settingView = UIView()
        settingView.backgroundColor = COLOR_profileCell
        contentView.addSubview(settingView)
        settingView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.left.right.equalTo(0)
        }
        let settingTitleLabel = UILabel()
        settingTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        settingTitleLabel.textColor = COLOR_profileCellTitleText
        settingTitleLabel.text = "Settings"
        settingView.addSubview(settingTitleLabel)
        settingTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(23)
            make.left.equalTo(55)
        }
        let wifiLabel = UILabel()
        wifiLabel.text = "Download on Wifi Only"
        wifiLabel.textColor = COLOR_profileCellTitleText
        settingView.addSubview(wifiLabel)
        wifiLabel.snp.makeConstraints { (make) in
            make.top.equalTo(settingTitleLabel.snp.bottom).offset(43)
            make.left.equalTo(settingTitleLabel)
        }
        let wifiSwitch = UISwitch()
        wifiSwitch.onTintColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
        wifiSwitch.isOn = downloadWithWifiOnly
        wifiSwitch.addTarget(self, action: #selector(onWifiTapped), for: .touchUpInside)
        settingView.addSubview(wifiSwitch)
        wifiSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(wifiLabel)
            make.right.equalTo(-40)
        }
        let screenLabel = UILabel()
        screenLabel.text = "Keep Screen On While Reading"
        settingView.addSubview(screenLabel)
        screenLabel.textColor = COLOR_profileCellTitleText
        screenLabel.snp.makeConstraints { (make) in
            make.top.equalTo(wifiLabel.snp.bottom).offset(32)
            make.left.equalTo(settingTitleLabel)
        }
        let screenSwitch = UISwitch()
        screenSwitch.onTintColor = UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
        screenSwitch.isOn = keepScreenOnWhileReading
        screenSwitch.addTarget(self, action: #selector(onScreenTapped), for: .touchUpInside)
        settingView.addSubview(screenSwitch)
        screenSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(screenLabel)
            make.right.equalTo(wifiSwitch)
        }
        
        
        colorThemeView = UIControl()
        colorThemeView.reactive.controlEvents(.touchUpInside).observeValues {[weak self] (control) in
            self?.changeTheme()
        }
        colorThemeView.backgroundColor = COLOR_profileCell
        settingView.addSubview(colorThemeView)
        colorThemeView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(screenSwitch.snp.bottom).offset(15)
            make.height.equalTo(50)
        }
        let colorThemeLabel = UILabel()
        colorThemeLabel.text = "Color Theme"
        colorThemeLabel.textColor = COLOR_profileCellTitleText
        settingView.addSubview(colorThemeLabel)
        colorThemeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(screenLabel.snp.bottom).offset(32)
            make.left.equalTo(settingTitleLabel)
            make.bottom.equalTo(-16)
        }
        let colorThemeNextImageView = UIImageView()
        colorThemeNextImageView.image = UIImage(named: "arrow-next")
        settingView.addSubview(colorThemeNextImageView)
        colorThemeNextImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(colorThemeLabel)
            make.right.equalTo(-24)
        }
        colorThemeViewAllLabel = UILabel()
        colorThemeViewAllLabel.text = colorTheme != UIUserInterfaceStyle.dark ? "Light Mode" : "Drak Mode"
        colorThemeViewAllLabel.textColor = UIColor(hex: 0x999999)
        colorThemeViewAllLabel.font = UIFont.systemFont(ofSize: 18)
        settingView.addSubview(colorThemeViewAllLabel)
        colorThemeViewAllLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(colorThemeLabel)
            make.right.equalTo(colorThemeNextImageView.snp.left).offset(-15)
        }

        let readingListView = UIControl()
        readingListView.reactive.controlEvents(.touchUpInside).observeValues {[weak self] (control) in
            let viewController = ReadingListViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        readingListView.backgroundColor = COLOR_profileCell
        contentView.addSubview(readingListView)
        readingListView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(settingView.snp.bottom).offset(15)
            make.height.equalTo(72)
        }
        let readingListLabel = UILabel()
        readingListLabel.text = "My Reading List"
        readingListLabel.textColor = COLOR_profileCellTitleText
        readingListLabel.font = UIFont.boldSystemFont(ofSize: 22)
        readingListView.addSubview(readingListLabel)
        readingListLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(readingListView)
            make.left.equalTo(55)
        }
        let nextImageView = UIImageView()
        nextImageView.image = UIImage(named: "arrow-next")
        readingListView.addSubview(nextImageView)
        nextImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(readingListView)
            make.right.equalTo(-24)
        }
        let viewAllLabel = UILabel()
        viewAllLabel.text = "View All"
        viewAllLabel.textColor = UIColor(hex: 0x999999)
        viewAllLabel.font = UIFont.systemFont(ofSize: 18)
        readingListView.addSubview(viewAllLabel)
        viewAllLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(readingListView)
            make.right.equalTo(nextImageView.snp.left).offset(-15)
        }

        let aboutUsView = UIView()
        aboutUsView.backgroundColor = COLOR_profileCell
        contentView.addSubview(aboutUsView)
        aboutUsView.snp.makeConstraints { (make) in
            make.top.equalTo(readingListView.snp.bottom).offset(15)
            make.left.right.equalTo(0)
        }
        let aboutUsTitleLabel = UILabel()
        aboutUsTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        aboutUsTitleLabel.textColor = COLOR_profileCellTitleText
        aboutUsTitleLabel.text = "About Us"
        aboutUsView.addSubview(aboutUsTitleLabel)
        aboutUsTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(23)
            make.left.equalTo(55)
        }
        let versionView = UIView()
        aboutUsView.addSubview(versionView)
        versionView.snp.makeConstraints { (make) in
            make.height.equalTo(53)
            make.top.equalTo(aboutUsTitleLabel.snp.bottom).offset(27)
            make.left.right.equalTo(0)
        }
        let versionTitleLabel = UILabel()
        versionTitleLabel.text = "Version"
        versionTitleLabel.textColor = COLOR_profileCellTitleText
        versionView.addSubview(versionTitleLabel)
        versionTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(versionView)
            make.left.equalTo(aboutUsTitleLabel)
        }
        let versionContentLabel = UILabel()
        versionContentLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        versionView.addSubview(versionContentLabel)
        versionContentLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(versionView)
            make.right.equalTo(-40)
        }
        let termsView = UIView()
        termsView.isUserInteractionEnabled = true
        termsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTermsTapped)))
        aboutUsView.addSubview(termsView)
        termsView.snp.makeConstraints { (make) in
            make.height.equalTo(versionView)
            make.top.equalTo(versionView.snp.bottom)
            make.left.right.equalTo(0)
        }
        let termsTitleLabel = UILabel()
        termsTitleLabel.text = "Terms of Use"
        termsTitleLabel.textColor = COLOR_profileCellTitleText
        termsView.addSubview(termsTitleLabel)
        termsTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(termsView)
            make.left.equalTo(aboutUsTitleLabel)
        }
        let termsImageView = UIImageView()
        termsImageView.image = UIImage(named: "icon-next")
        termsView.addSubview(termsImageView)
        termsImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(termsView)
            make.right.equalTo(versionContentLabel)
        }
        let ppView = UIView()
        ppView.isUserInteractionEnabled = true
        ppView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPpTapped)))
        aboutUsView.addSubview(ppView)
        ppView.snp.makeConstraints { (make) in
            make.height.equalTo(versionView)
            make.top.equalTo(termsView.snp.bottom)
            make.left.right.equalTo(0)
        }
        let ppTitleLabel = UILabel()
        ppTitleLabel.text = "Privacy Policy"
        ppTitleLabel.textColor = COLOR_profileCellTitleText
        ppView.addSubview(ppTitleLabel)
        ppTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(ppView)
            make.left.equalTo(aboutUsTitleLabel)
        }
        let ppImageView = UIImageView()
        ppImageView.image = UIImage(named: "icon-next")
        ppView.addSubview(ppImageView)
        ppImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(ppView)
            make.right.equalTo(versionContentLabel)
        }
        let disView = UIView()
        disView.isUserInteractionEnabled = true
        disView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDisTapped)))
        aboutUsView.addSubview(disView)
        disView.snp.makeConstraints { (make) in
            make.height.equalTo(versionView)
            make.top.equalTo(ppView.snp.bottom)
            make.left.right.bottom.equalTo(0)
        }
        let disTitleLabel = UILabel()
        disTitleLabel.text = "Disclaimer"
        disTitleLabel.textColor = COLOR_profileCellTitleText
        disView.addSubview(disTitleLabel)
        disTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(disView)
            make.left.equalTo(aboutUsTitleLabel)
        }
        let disImageView = UIImageView()
        disImageView.image = UIImage(named: "icon-next")
        disView.addSubview(disImageView)
        disImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(disView)
            make.right.equalTo(versionContentLabel)
        }

        let contactUsView = UIView()
        contactUsView.backgroundColor = COLOR_profileCell
        contentView.addSubview(contactUsView)
        contactUsView.snp.makeConstraints { (make) in
            make.top.equalTo(aboutUsView.snp.bottom).offset(16)
            make.left.right.equalTo(0)
        }
        let contactTitleLabel = UILabel()
        contactTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        contactTitleLabel.textColor = COLOR_profileCellTitleText
        contactTitleLabel.text = "Contact Us"
        contactUsView.addSubview(contactTitleLabel)
        contactTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(23)
            make.left.equalTo(55)
        }
        let emailView = UIView()
        contactUsView.addSubview(emailView)
        emailView.snp.makeConstraints { (make) in
            make.height.equalTo(53)
            make.top.equalTo(contactTitleLabel.snp.bottom).offset(27)
            make.left.right.bottom.equalTo(0)
        }
        let emailTitleLabel = UILabel()
        emailTitleLabel.text = "Email Address"
        emailTitleLabel.textColor = COLOR_profileCellTitleText
        emailView.addSubview(emailTitleLabel)
        emailTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(emailView)
            make.left.equalTo(contactTitleLabel)
        }
        let emailContentLabel = UILabel()
        emailContentLabel.text = "mpgreader@mpdl.mpg.de"
        emailContentLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        emailView.addSubview(emailContentLabel)
        emailContentLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(emailView)
            make.right.equalTo(-40)
        }

        let footerView = UIView()
        contentView.addSubview(footerView)
        footerView.snp.makeConstraints { (make) in
            make.top.equalTo(contactUsView.snp.bottom).offset(30)
            make.bottom.equalTo(-30)
            make.centerX.equalTo(contentView)
        }
        let developLabel = UILabel()
        developLabel.text = "Developed by"
        developLabel.textColor = UIColor(hex: 0x999999)
        developLabel.font = UIFont.systemFont(ofSize: 14)
        footerView.addSubview(developLabel)
        developLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(footerView)
            make.top.equalTo(0)
        }
        let developImageView = UIImageView()
        developImageView.image = UIImage(named: "logo-profile.png")
        footerView.addSubview(developImageView)
        developImageView.snp.makeConstraints { (make) in
            make.top.equalTo(developLabel.snp.bottom).offset(9)
            make.bottom.equalTo(0)
            make.centerX.equalTo(footerView)
        }

        self.fetchAppConfiguration(fullnameLabel: nameLabel, versionLabel: versionContentLabel)
    }

    @objc func onWifiTapped() {
        downloadWithWifiOnly = !downloadWithWifiOnly
        prefs.set(downloadWithWifiOnly, forKey: wifiKey)
        prefs.synchronize()
    }

    @objc func onScreenTapped() {
        keepScreenOnWhileReading = !keepScreenOnWhileReading
        prefs.set(keepScreenOnWhileReading, forKey: screenKey)
        prefs.synchronize()
    }

    @objc func onTermsTapped() {
        let viewController = WebviewViewController()
        viewController.titleLabel = "Terms of Use"
        viewController.urlString = "http://dev-mpgreader.mpdl.mpg.de/mpgReaderTerms.html"
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func onPpTapped() {
        let viewController = WebviewViewController()
        viewController.titleLabel = "Privacy Policy"
        viewController.urlString = "http://dev-mpgreader.mpdl.mpg.de/mpgReaderPrivacyPolicy.html"
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func onDisTapped() {
        let viewController = WebviewViewController()
        viewController.titleLabel = "Disclaimer"
        viewController.urlString = "http://dev-mpgreader.mpdl.mpg.de/mpgReaderDisclaimer.html"
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    fileprivate func changeTheme() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let light = UIAlertAction(title: "Light Mode", style: .default) { (_) in
            UserDefaults.standard.setValue(false, forKey: READERTHEMEKEY)
            UIApplication.shared.windows[0].overrideUserInterfaceStyle = .light
            self.colorTheme = .light
            self.colorThemeViewAllLabel.text = "Light Mode"
        }
        let dark = UIAlertAction(title: "Dark Mode", style: .default) { (_) in
            UserDefaults.standard.setValue(true, forKey: READERTHEMEKEY)
            UIApplication.shared.windows[0].overrideUserInterfaceStyle = .dark
            self.colorTheme = .dark
            self.colorThemeViewAllLabel.text = "Drak Mode"
        }
        let popover = alert.popoverPresentationController
        popover?.sourceView = colorThemeView
        popover?.sourceRect = colorThemeView.bounds
        popover?.permittedArrowDirections  = .any
        alert.addAction(light)
        alert.addAction(dark)
        self.present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func fetchAppConfiguration(fullnameLabel
        : UILabel, versionLabel: UILabel) {
         if let managedConfigDict = UserDefaults.standard.dictionary(forKey: "com.apple.configuration.managed"){
            let firstname = managedConfigDict["firstname"] as? String ?? " "
            let lastname = managedConfigDict["lastname"] as? String ?? " "
            let fullname = firstname + " " + lastname
            DispatchQueue.main.async {
                fullnameLabel.text = fullname
            }
            
            
            if let version = managedConfigDict["version"] {
                DispatchQueue.main.async {
                    versionLabel.text = version as? String
                }
            }
         }else{
              print("Error fetching app config values. Please make sure your device is enrolled with Workspace ONE")
         }
    }
}
