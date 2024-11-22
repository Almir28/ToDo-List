import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    private init() {
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
        
        #if DEBUG
        description.url = URL(fileURLWithPath: "/dev/null")
        #else
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            description.url = documentsDirectory.appendingPathComponent("TodoList.sqlite")
        }
        #endif
        
        persistentContainer.persistentStoreDescriptions = [description]
        
        let group = DispatchGroup()
        group.enter()
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
            group.leave()
        }
        
        group.wait()
    }
}
