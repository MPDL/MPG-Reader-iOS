//
//  FolderApi.swift
//  EbookReader
//
//  Created by ysq on 2021/4/16.
//  Copyright © 2021 CN. All rights reserved.
//

import Foundation

class FolderApi {
    static func bookshelf(success: ((Bookshelf?) -> Void)?, failure: ((NSError) -> Void)?){
        NetworkManager.sharedInstance().GET(
            path: "rest/bookshelf",
            parameters: nil,
            modelClass: Bookshelf.self,
            success: { (baseDTOContent) in
                success?(baseDTOContent)
            }, failure: failure)
    }
    static func books(folderName: String, success: ((Bookshelf?) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.sharedInstance().POST(
            path: "rest/bookshelf/folder/books?folderName=" + folderName,
            parameters: nil,
            modelClass: Bookshelf.self,
            success: { (baseDTOContent) in
                success?(baseDTOContent)
            }, failure: failure)
    }
    static func createFolder(folderName: String, success: ((Bookshelf?) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.sharedInstance().POST(
            path: "rest/bookshelf/createFolder",
            parameters: ["folderName": folderName],
            modelClass: Bookshelf.self,
            success: { (baseDTOContent) in
                success?(baseDTOContent)
            }, failure: failure)
    }
    static func addBook(bookId: String, success: ((Bookshelf?) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.sharedInstance().POST(
            path: "rest/bookshelf/addBook?bookId=" + bookId,
            parameters: nil,
            modelClass: Bookshelf.self,
            success: { (baseDTOContent) in
                success?(baseDTOContent)
            }, failure: failure)
    }
    static func moveIn(destFolderName: String, bookIds: Array<String>, success: ((Bookshelf?) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.sharedInstance().POST(
            path: "rest/bookshelf/moveIn",
            parameters: ["destFolderName": destFolderName, "bookIds": bookIds],
            modelClass: Bookshelf.self,
            success: { (baseDTOContent) in
                success?(baseDTOContent)
            }, failure: failure)
    }
    static func moveOut(srcFolderName: String, bookIds: Array<String>, success: ((Bookshelf?) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.sharedInstance().POST(
            path: "rest/bookshelf/folder/moveOut",
            parameters: ["srcFolderName": srcFolderName, "bookIds": bookIds],
            modelClass: Bookshelf.self,
            success: { (baseDTOContent) in
                success?(baseDTOContent)
            }, failure: failure)
    }
    static func removeBooks(folderName: String, bookIds: Array<String>, success: ((Bookshelf?) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.sharedInstance().POST(
            path: "rest/bookshelf/folder/removeBooks",
            parameters: ["folderName": folderName, "bookIds": bookIds],
            modelClass: Bookshelf.self,
            success: { (baseDTOContent) in
                success?(baseDTOContent)
            }, failure: failure)
    }
    static func moveBetween(srcFolderName: String, destFolderName: String, bookIds: Array<String>, success: ((Bookshelf?) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.sharedInstance().POST(
            path: "rest/bookshelf/folder/moveBetween",
            parameters: ["srcFolderName": srcFolderName, "destFolderName": destFolderName, "bookIds": bookIds],
            modelClass: Bookshelf.self,
            success: { (baseDTOContent) in
                success?(baseDTOContent)
            }, failure: failure)
    }
    static func rename(folderName: String, folderNameNew: String, success: ((Bookshelf?) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.sharedInstance().POST(
            path: "rest/bookshelf/folder/rename",
            parameters: ["folderName": folderName, "folderNameNew": folderNameNew],
            modelClass: Bookshelf.self,
            success: { (baseDTOContent) in
                success?(baseDTOContent)
            }, failure: failure)
    }
    static func remove(folderName: String, success: ((Bookshelf?) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.sharedInstance().POST(
            path: "rest/bookshelf/folder/remove?folderName=" + folderName,
            parameters: nil,
            modelClass: Bookshelf.self,
            success: { (baseDTOContent) in
                success?(baseDTOContent)
            }, failure: failure)
    }
}
