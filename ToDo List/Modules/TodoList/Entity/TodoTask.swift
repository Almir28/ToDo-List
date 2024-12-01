import CoreData

/// Модель данных TodoTask для CoreData
/// Реализует основную сущность задачи с поддержкой Identifiable
@objc(TodoTask)
public class TodoTask: NSManagedObject {
    /// Запрос для получения задач из Core Data
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoTask> {
        return NSFetchRequest<TodoTask>(entityName: "TodoTask") // Возвращает запрос для сущности "TodoTask"
    }
    
    // MARK: - Properties
    
    @NSManaged public var id: Int64 // Уникальный идентификатор задачи
    
    @NSManaged public var title: String? // Заголовок задачи
    
    @NSManaged public var todoDescription: String? // Описание задачи
    
    @NSManaged public var createdAt: Date? // Дата создания задачи
    
    @NSManaged public var isCompleted: Bool // Статус выполнения задачи
    
    @NSManaged public var userId: Int64 // Идентификатор пользователя, которому принадлежит задача
}

// MARK: - Protocol Conformance
extension TodoTask: TodoEntityProtocol {} // Поддержка протокола TodoEntityProtocol

// MARK: - Identifiable
extension TodoTask: Identifiable {
    
    /// Возвращает заголовок задачи, если он не установлен, возвращает "Новая задача"
    var wrappedTitle: String {
        title ?? "Новая задача"
    }
    
    /// Возвращает описание задачи, если оно не установлено, возвращает пустую строку
    var wrappedDescription: String {
        todoDescription ?? ""
    }
    
    /// Возвращает дату создания задачи, если она не установлена, возвращает текущую дату
    var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }
}
