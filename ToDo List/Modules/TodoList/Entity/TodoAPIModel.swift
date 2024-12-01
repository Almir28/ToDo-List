import Foundation

/// Структура для представления ответа API с задачами
struct TodoAPIResponse: Codable {
    let todos: [TodoAPIItem] // Массив задач, полученных от API
    let total: Int // Общее количество задач
    let skip: Int // Количество пропущенных задач (для пагинации)
    let limit: Int // Максимальное количество задач на странице
}

/// Структура для представления отдельной задачи из API
struct TodoAPIItem: Codable {
    let id: Int // Уникальный идентификатор задачи
    let todo: String // Описание задачи
    let completed: Bool // Статус выполнения задачи
    let userId: Int // Идентификатор пользователя, которому принадлежит задача
    
    // Ключи для декодирования JSON
    enum CodingKeys: String, CodingKey {
        case id // Ключ для идентификатора задачи
        case todo // Ключ для описания задачи
        case completed // Ключ для статуса выполнения
        case userId // Ключ для идентификатора пользователя
    }
}
