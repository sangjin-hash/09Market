//
//  HomeSectionModel.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import Domain

import RxDataSources

// MARK: - Section Item

enum HomeSectionItem: IdentifiableType, Equatable {
    case category(GroupBuyingCategory?, Bool)
    case top10Banner
    case post(Post)
    case skeleton(Int)

    var identity: String {
        switch self {
        case .category(let category, _):
            return "category_\(category?.rawValue ?? "all")"

        case .top10Banner:
            return "top10Banner"

        case .post(let post):
            return "post_\(post.id)"
            
        case .skeleton(let index):
            return "skeleton_\(index)"
        }
    }

    static func == (lhs: HomeSectionItem, rhs: HomeSectionItem) -> Bool {
        switch (lhs, rhs) {
        case (.category(let lCat, let lSel), .category(let rCat, let rSel)):
            return lCat == rCat && lSel == rSel

        case (.top10Banner, .top10Banner):
            return true

        case (.post(let lPost), .post(let rPost)):
            return lPost.id == rPost.id
                && lPost.likesCount == rPost.likesCount
                && lPost.isLiked == rPost.isLiked
        
        case (.skeleton(let l), .skeleton(let r)):
            return l == r

        default:
            return false
        }
    }
}


// MARK: - Section Model

enum HomeSectionModel {
    case category(items: [HomeSectionItem])
    case top10Banner(items: [HomeSectionItem])
    case postList(items: [HomeSectionItem])
}

extension HomeSectionModel: AnimatableSectionModelType {
    typealias Item = HomeSectionItem

    var identity: String {
        switch self {
        case .category:
            return "category"

        case .top10Banner:
            return "top10Banner"

        case .postList:
            return "postList"
        }
    }

    var items: [HomeSectionItem] {
        switch self {
        case .category(let items):
            return items

        case .top10Banner(let items):
            return items

        case .postList(let items):
            return items
        }
    }

    init(original: HomeSectionModel, items: [HomeSectionItem]) {
        switch original {
        case .category:
            self = .category(items: items)

        case .top10Banner:
            self = .top10Banner(items: items)

        case .postList:
            self = .postList(items: items)
        }
    }
}
