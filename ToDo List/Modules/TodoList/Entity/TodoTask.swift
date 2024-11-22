import CoreData
/// Модель данных TodoTask для CoreData
/// Реализует основную сущность задачи с поддержкой Identifiable
@objc(TodoTask)
public class TodoTask: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoTask> {
        return NSFetchRequest<TodoTask>(entityName: "TodoTask")
    }
    // MARK: - Properties
    
    @NSManaged public var id: Int64
    
    @NSManaged public var title: String?
    
    @NSManaged public var todoDescription: String?
    
    @NSManaged public var createdAt: Date?
    
    @NSManaged public var isCompleted: Bool
    
    @NSManaged public var userId: Int64
}

// MARK: - Protocol Conformance
extension TodoTask: TodoEntityProtocol {}

// MARK: - Identifiable
extension TodoTask: Identifiable {
    
    var wrappedTitle: String {
        title ?? "Новая задача"
    }
    
    var wrappedDescription: String {
        todoDescription ?? ""
    }
    
    var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }
}
