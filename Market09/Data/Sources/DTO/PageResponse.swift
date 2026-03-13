//
//  PageResponse.swift
//  Data
//
//  Created by Sangjin Lee
//

struct PageResponse<T: Decodable>: Decodable {
    let data: [T]
    let total: Int
    let page: Int
}
