//
//  ThirdViewController.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/29.
//  Copyright © 2020 CN. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

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

        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        
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
        headerView.backgroundColor = UIColor.white
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
        nameLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        nameLabel.text = "Jack Jordan"
        headerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(headerView)
            make.top.equalTo(avatarImageView.snp.bottom).offset(26)
            make.bottom.equalTo(-40)
        }

        let settingView = UIView()
        settingView.backgroundColor = UIColor.white
        contentView.addSubview(settingView)
        settingView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.left.right.equalTo(0)
        }
        let settingTitleLabel = UILabel()
        settingTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        settingTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        settingTitleLabel.text = "Setting"
        settingView.addSubview(settingTitleLabel)
        settingTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(23)
            make.left.equalTo(55)
        }
        let wifiLabel = UILabel()
        wifiLabel.text = "Download on Wifi Only"
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
        screenLabel.snp.makeConstraints { (make) in
            make.top.equalTo(wifiLabel.snp.bottom).offset(32)
            make.left.equalTo(settingTitleLabel)
            make.bottom.equalTo(-16)
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

        let aboutUsView = UIView()
        aboutUsView.backgroundColor = UIColor.white
        contentView.addSubview(aboutUsView)
        aboutUsView.snp.makeConstraints { (make) in
            make.top.equalTo(settingView.snp.bottom).offset(16)
            make.left.right.equalTo(0)
        }
        let aboutUsTitleLabel = UILabel()
        aboutUsTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        aboutUsTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
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
        versionView.addSubview(versionTitleLabel)
        versionTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(versionView)
            make.left.equalTo(aboutUsTitleLabel)
        }
        let versionContentLabel = UILabel()
        versionContentLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        versionContentLabel.text = "v1.0.1"
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
        contactUsView.backgroundColor = UIColor.white
        contentView.addSubview(contactUsView)
        contactUsView.snp.makeConstraints { (make) in
            make.top.equalTo(aboutUsView.snp.bottom).offset(16)
            make.left.right.equalTo(0)
            make.bottom.equalTo(-16)
        }
        let contactTitleLabel = UILabel()
        contactTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        contactTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
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
        emailView.addSubview(emailTitleLabel)
        emailTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(emailView)
            make.left.equalTo(contactTitleLabel)
        }
        let emailContentLabel = UILabel()
        emailContentLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        emailContentLabel.text = "reader@mpdl.mpg.de"
        emailView.addSubview(emailContentLabel)
        emailContentLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(emailView)
            make.right.equalTo(-40)
        }
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
        viewController.urlString = "https://register.qa-mpad.mpdl.mpg.de/mpgReaderTerms.html"
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func onPpTapped() {
        let viewController = WebviewViewController()
        viewController.titleLabel = "Privacy Policy"
        viewController.urlString = "https://register.qa-mpad.mpdl.mpg.de/mpgReaderPrivacyPolicy.html"
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func onDisTapped() {
        let viewController = WebviewViewController()
        viewController.titleLabel = "Disclaimer"
        viewController.urlString = "https://register.qa-mpad.mpdl.mpg.de/mpgReaderDisclaimer.html"
        self.navigationController?.pushViewController(viewController, animated: true)
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
