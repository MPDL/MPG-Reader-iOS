//
//  Color.swift
//  EbookReader
//
//  Created by ysq on 2021/4/1.
//  Copyright © 2021 CN. All rights reserved.
//

import Foundation
import UIKit

func color(light: UIColor, dark: UIColor) -> UIColor {
    return UIColor { (tc) -> UIColor in
       return tc.userInterfaceStyle == .light ? light : dark
    }
}

let COLOR_background = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1) : UIColor(red: 15/255.0, green: 15/255.0, blue: 15/255.0, alpha: 1)
}
let COLOR_text = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(hex: 0x333333) : UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
}
let COLOR_recordView = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1) : UIColor(red: 64/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1)
}
let COLOR_recordLabel = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}
let COLOR_bookshelfBackground = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(hex: 0xF9F9F9) : UIColor(red: 15/255.0, green: 15/255.0, blue: 15/255.0, alpha: 1)
}
let COLOR_profileCell = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor.white : UIColor(red: 27/255.0, green: 27/255.0, blue: 27/255.0, alpha: 1)
}
let COLOR_profileCellTitleText = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}
let COLOR_bookTableViewCellTitle = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1) : UIColor.white
}
let COLOR_bookTableViewCellAuthor = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}
let COLOR_bookTableViewCellDate = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1) : UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
}

let COLOR_bookTableViewCellPress = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) : UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
}


let COLOR_downloadViewTitle = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1) : UIColor(red: 0/255.0, green: 159/255.0, blue: 161/255.0, alpha: 1)
}
let COLOR_downloadViewAuthor = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.25, green: 0.31, blue: 0.36,alpha:1) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}

let COLOR_downloadViewPress = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1) : UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
}

let COLOR_downloadViewDate = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.25, green: 0.31, blue: 0.36, alpha: 1) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}
let COLOR_downloadViewIntro = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}
let COLOR_downloadViewReview = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(hex: 0x333333) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}
let COLOR_downloadViewReviewComment = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(hex: 0x333333) : UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
}
let COLOR_navItem = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor.white : UIColor(red: 64/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1)
}
let COLOR_navItemText = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(hex: 0x333333) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}
let COLOR_pdfReaderHeader = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(white: 1, alpha: 0.9) : UIColor(red: 15/255.0, green: 15/255.0, blue: 15/255.0, alpha: 1)
}
    
let COLOR_pdfReaderOutlineTitle = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor.black : UIColor(red: 0/255.0, green: 159/255.0, blue: 161/255.0, alpha: 1)
}
    
let COLOR_pdfReaderOutlineSubTitle = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor.gray : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}
    
let COLOR_pdfSearchText = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}

let COLOR_citeBackground = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor.white : UIColor(red: 64/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1)
}
let COLOR_citeTitle = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(hex: 0x333333) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}
let COLOR_citeContent = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor.black : UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
}

let COLOR_navBar = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}

let COLOR_buttonBackground = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(hex: 0xF9F9F9) : UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1)
}
let COLOR_buttonBackground_disable = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(hex: 0xF9F9F9) : UIColor(red: 15/255.0, green: 15/255.0, blue: 15/255.0, alpha: 1)
}
let COLOR_buttonText = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0, green: 0.62, blue: 0.63, alpha: 1) : UIColor.white
}

let COLOR_overlayText = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) : UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
}
let COLOR_overlayView = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1) : UIColor(red: 64/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1)
}

let COLOR_reviewView = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(hex: 0xF2F2F5) : UIColor(hex: 0x333333)
}

let COLOR_reviewText = UIColor { (tc) -> UIColor in
    return tc.userInterfaceStyle == .light ? UIColor(hex: 0x333333) : UIColor(hex: 0xffffff)
}
