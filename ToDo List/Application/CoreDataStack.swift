import CoreData
/// Синглтон для управления Core Data стеком приложения
/// Реализует базовую конфигурацию хранилища данных
class CoreDataStack {
    /// Общий экземпляр для использования во всем приложении
    static let shared = CoreDataStack()
    
    private let persistentContainer: NSPersistentContainer
    
    /// Контекст для работы с данными
    /// - Returns: Настроенный NSManagedObjectContext с политикой слияния
    var context: NSManagedObjectContext {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    /// Приватный инициализатор для реализации синглтона
    /// Настраивает модель данных и хранилище
    private init() {
        // Создание модели данных программно
        let model = NSManagedObjectModel()
        
        // Конфигурация сущности TodoTask
        let taskEntity = NSEntityDescription()
        taskEntity.name = "TodoTask"
        taskEntity.managedObjectClassName = String(describing: TodoTask.self)
        
        // Определение атрибутов
        let attributes: [(String, NSAttributeType, Bool)] = [
            ("id", .integer64AttributeType, false),
            ("title", .stringAttributeType, true),
            ("todoDescription", .stringAttributeType, true),
            ("createdAt", .dateAttributeType, true),
            ("isCompleted", .booleanAttributeType, false),
            ("userId", .integer64AttributeType, false)
        ]
        
        taskEntity.properties = attributes.map { name, type, isOptional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            return attribute
        }
        
        model.entities = [taskEntity]
        
        // Настройка контейнера и хранилища
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
        
        // Синхронная загрузка хранилища
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
