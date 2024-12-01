import CoreData
@testable import ToDo_List

/// Мок-реализация менеджера данных для тестирования
/// Имитирует работу TodoListDataManager для модульных тестов
class MockTodoListDataManager: TodoListDataManagerProtocol {
    let context: NSManagedObjectContext // Контекст для работы с Core Data
    
    init(context: NSManagedObjectContext) {
        self.context = context // Инициализация контекста
    }
    
    /// Имитация получения задач
    func fetchTasks() async throws -> [TodoTask] {
        return [] // Возвращает пустой массив задач
    }
    
    /// Имитация сохранения задачи
    func saveTask(_ task: TodoTask) async throws {
        // Пустая реализация для тестирования
    }
    
    /// Имитация удаления задачи
    func deleteTask(_ task: TodoTask) async throws {
        // Пустая реализация для тестирования
    }
    
    /// Имитация поиска задач по запросу
    func searchTasks(query: String) async throws -> [TodoTask] {
        return [] // Возвращает пустой массив задач
    }
    
    /// Имитация обновления задачи
    func updateTask(_ task: TodoTask) async throws {
        // Пустая реализация для тестирования
    }
}
