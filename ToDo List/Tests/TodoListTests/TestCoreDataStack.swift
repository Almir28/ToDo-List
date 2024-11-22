//
//  TestCoreDataStack.swift
//  TodoListTests
//
//  Created by Swift Developer on 21.11.2024.
//
import CoreData
@testable import ToDo_List
/// Тестовый стек CoreData для модульных тестов
/// Реализует in-memory хранилище и методы очистки данных
class TestCoreDataStack {
    static let shared = TestCoreDataStack()
    
    let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init() {
        let model = NSManagedObjectModel()
        
        let taskEntity = NSEntityDescription()
        taskEntity.name = "TodoTask"
        taskEntity.managedObjectClassName = String(describing: TodoTask.self)
        
        let attributes: [(String, NSAttributeType, Bool)] = [
            ("id", .integer64AttributeType, false),
            ("title", .stringAttributeType, true),
            ("todoDescription", .stringAttributeType, true),
            ("createdAt", .dateAttributeType, true),
            ("isCompleted", .booleanAttributeType, false),
            ("userId", .integer64AttributeType, false)
        ]
        
        let properties = attributes.map { name, type, isOptional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            return attribute
        }
        
        taskEntity.properties = properties
        model.entities = [taskEntity]
        
        persistentContainer = NSPersistentContainer(name: "TodoList", managedObjectModel: model)
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
    }
    
    func clearStore() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TodoTask.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDelete.resultType = .resultTypeObjectIDs
        
        let result = try context.execute(batchDelete) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
    }
}

