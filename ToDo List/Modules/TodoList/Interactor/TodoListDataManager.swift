import CoreData

/// Протокол и реализация слоя доступа к данным для ToDo приложения
/// Обеспечивает CRUD операции с задачами через CoreData

// MARK: - Protocol
protocol TodoListDataManagerProtocol {
    /// Получение списка задач
    func fetchTasks() async throws -> [TodoTask]
    
    /// Сохранение новой задачи
    func saveTask(_ task: TodoTask) async throws
    
    /// Удаление задачи
    func deleteTask(_ task: TodoTask) async throws
    
    /// Поиск задач по запросу
    func searchTasks(query: String) async throws -> [TodoTask]
    
    /// Обновление существующей задачи
    func updateTask(_ task: TodoTask) async throws
}

// MARK: - Implementation
class TodoListDataManager: TodoListDataManagerProtocol {
    private let context: NSManagedObjectContext // Контекст для работы с Core Data
    
    /// Инициализация менеджера данных с заданным контекстом
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    /// Получение списка задач из Core Data
    func fetchTasks() async throws -> [TodoTask] {
        let request = NSFetchRequest<TodoTask>(entityName: "TodoTask") // Создание запроса для получения задач
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)] // Сортировка по дате создания
        return try context.fetch(request) // Выполнение запроса и возврат результатов
    }
    
    /// Сохранение новой задачи в Core Data
    func saveTask(_ task: TodoTask) async throws {
        try context.save() // Сохранение изменений в контексте
    }
    
    /// Удаление задачи из Core Data
    func deleteTask(_ task: TodoTask) async throws {
        context.delete(task) // Удаление задачи из контекста
        try context.save() // Сохранение изменений
    }
    
    /// Поиск задач по заданному запросу
    func searchTasks(query: String) async throws -> [TodoTask] {
        let request = TodoTask.fetchRequest() // Создание запроса для получения задач
        if !query.isEmpty {
            // Установка предиката для фильтрации задач по заголовку или описанию
            request.predicate = NSPredicate(
                format: "title CONTAINS[cd] %@ OR todoDescription CONTAINS[cd] %@",
                query, query
            )
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoTask.createdAt, ascending: false)] // Сортировка по дате создания
        return try context.fetch(request) // Выполнение запроса и возврат результатов
    }
    
    /// Обновление существующей задачи в Core Data
    func updateTask(_ task: TodoTask) async throws {
        try context.save() // Сохранение изменений в контексте
    }
}
