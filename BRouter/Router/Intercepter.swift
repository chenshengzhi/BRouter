//
//  Intercepter.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import Foundation

protocol Intercepter {
    func perform(url: URL)
}
