//
//  Queue.swift
//  HP-Arize
//
//  Created by Alexandre Boyer Laporte on 2021-09-29.
//

import Foundation

struct Queue<T> {
    
    private(set) var elements: [T] = []
    
    mutating func enqueue(_ value: T) {
        elements.append(value)
    }
    
    mutating func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeFirst()
    }
    
    var head: T? {
        elements.first
    }
    
    var tail: T? {
        elements.last
    }
}
