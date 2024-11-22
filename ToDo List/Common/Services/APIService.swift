import Foundation

struct Todo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

struct TodoResponse: Codable {
    let todos: [Todo]
    let total: Int
    let skip: Int
    let limit: Int
}

class APIService {
    static let shared = APIService()
    var baseURL = "https://dummyjson.com/todos"
    
    func fetchTodos() async throws -> [Todo] {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let todoResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
        return todoResponse.todos
    }
}
