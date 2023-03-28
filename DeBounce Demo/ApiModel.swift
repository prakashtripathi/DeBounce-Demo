//
//  ApiModel.swift
//  DeBounce Demo
//
//  Created by Prakash Tripathi on 29/03/23.
//

import Foundation

// MARK: - QuizModel
struct ApiModel: Codable {
    let posts: [Post]
    let total, skip, limit: Int
}

// MARK: - Post
struct Post: Codable {
    let id: Int
    let title, body: String
    let userID: Int
    let tags: [String]
    let reactions: Int

    enum CodingKeys: String, CodingKey {
        case id, title, body
        case userID = "userId"
        case tags, reactions
    }
}
