import Foundation

// Структура, представляющая задачу в списке дел
struct Todo: Codable {
    let id: Int // Уникальный идентификатор задачи
    let todo: String // Описание задачи
    let completed: Bool // Статус выполнения задачи
    let userId: Int // Идентификатор пользователя, которому принадлежит задача
}

// Структура для обработки ответа от API, содержащая массив задач и метаданные
struct TodoResponse: Codable {
    let todos: [Todo] // Массив задач, полученных от API
    let total: Int // Общее количество задач
    let skip: Int // Количество пропущенных задач (для пагинации)
    let limit: Int // Максимальное количество задач на странице
}

class APIService {
    static let shared = APIService() // Реализация паттерна Singleton для доступа к APIService
    var baseURL = "https://dummyjson.com/todos" // Базовый URL для API запросов
    
    /// Асинхронная функция для получения списка задач
    /// - Throws: Ошибка, если URL некорректен или сервер возвращает ошибку
    /// - Returns: Массив задач
    func fetchTodos() async throws -> [Todo] {
        // Проверка корректности формирования URL
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL) // Генерация ошибки, если URL некорректен
        }
        
        // Выполнение асинхронного запроса к API
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Проверка статуса ответа от сервера
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse) // Генерация ошибки, если ответ сервера не успешен
        }
        
        // Декодирование полученных данных в структуру TodoResponse
        let todoResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
        return todoResponse.todos // Возврат массива задач из ответа
    }
}
