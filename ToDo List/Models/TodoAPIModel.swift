import Foundation

struct TodoAPIResponse: Codable {
    let todos: [TodoAPIItem]
    let total: Int
    let skip: Int
    let limit: Int
}

struct TodoAPIItem: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
} 