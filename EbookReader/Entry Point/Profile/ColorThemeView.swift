//
//  ColorThemeView.swift
//  EbookReader
//
//  Created by ysq on 2021/4/26.
//  Copyright © 2021 CN. All rights reserved.
//

import UIKit

class ColorThemeView: UIView {

    var setLightMode: (()->())?
    var setDarkMode: (()->())?

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var darkModeView: UIView!
    @IBOutlet weak var lightModeView: UIView!
    @IBOutlet weak var lightModeStatusImageView: UIImageView!
    @IBOutlet weak var darkModeStatusImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = color(light: UIColor.white, dark: UIColor(hex: 0x404040))
        let tapLightMode = UITapGestureRecognizer(target: self, action: #selector(tapLightMode(_:)))
        lightModeView.addGestureRecognizer(tapLightMode)
        lightModeView.isUserInteractionEnabled = true
        let tapDarkMode = UITapGestureRecognizer(target: self, action: #selector(tapDarkMode(_:)))
        darkModeView.addGestureRecognizer(tapDarkMode)
        darkModeView.isUserInteractionEnabled = true
    }
    
    func show() {
        self.setStatus()
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        } completion: { (finish) in
            
        }
    }
    func hide() {
        self.setStatus()
        self.alpha = 1
        self.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { (finish) in
            self.isHidden = true
        }
    }

    @objc private func tapDarkMode(_ sender: Any) {
        self.setDarkMode?()
    }
    @objc private func tapLightMode(_ sender: Any) {
        self.setLightMode?()
    }
    
    func setStatus() {
        let isDarkMode = UserDefaults.standard.bool(forKey: READERTHEMEKEY) ? true : false
        darkModeStatusImageView.image = UIImage(named: isDarkMode ? "folder_select" : "folder_no_select")
        lightModeStatusImageView.image = UIImage(named: isDarkMode ? "folder_no_select" : "folder_select")
    }
}
