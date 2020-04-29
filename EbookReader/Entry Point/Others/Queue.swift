//
//  Queue.swift
//  EbookReader
//
//  Created by 黄文博 on 2020/4/29.
//  Copyright © 2020 CN. All rights reserved.
//

import Foundation

public struct Queue<T> {
    fileprivate var array = [T]()
    public var isEmpty: Bool {
        return array.isEmpty
    }
    public var count: Int {
        return array.count
    }
    public mutating func get(index: Int) -> T? {
        return array[index]
    }
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    public mutating func dequeue() -> T? {
        if isEmpty {
           return nil
        } else {
           return array.removeFirst()
        }
     }
    public var front: T? {
        return array.first
    }
}
