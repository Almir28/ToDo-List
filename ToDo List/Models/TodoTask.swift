import Foundation
import CoreData

@objc(TodoTask)
public class TodoTask: NSManagedObject {
}

// MARK: - Core Data properties
extension TodoTask {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoTask> {
        return NSFetchRequest<TodoTask>(entityName: "TodoTask")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var todoDescription: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var userId: Int64
}

// MARK: - Convenience methods
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