//
//  Page.swift
//  Domain
//
//  Created by Sangjin Lee
//

public struct Page<Item> {
    public let data: [Item]
    public let total: Int
    public let page: Int

    public init(data: [Item], total: Int, page: Int) {
        self.data = data
        self.total = total
        self.page = page
    }
}
