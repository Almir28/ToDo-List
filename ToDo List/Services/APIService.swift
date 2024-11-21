import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func fetchTodos() async throws -> [TodoAPIItem] {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(TodoAPIResponse.self, from: data)
        return apiResponse.todos
    }
} 