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
        context.automaticallyMergesChangesFromParent = true // Автоматическое слияние изменений из родительского контекста
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy // Политика слияния, при которой изменения объекта имеют приоритет
        return context
    }
    
    /// Приватный инициализатор для реализации синглтона
    /// Настраивает модель данных и хранилище
    private init() {
        // Создание модели данных программно
        let model = NSManagedObjectModel()
        
        // Конфигурация сущности TodoTask
        let taskEntity = NSEntityDescription()
        taskEntity.name = "TodoTask" // Имя сущности
        taskEntity.managedObjectClassName = String(describing: TodoTask.self) // Класс управляемого объекта
        
        // Определение атрибутов
        let attributes: [(String, NSAttributeType, Bool)] = [
            ("id", .integer64AttributeType, false), // Идентификатор задачи
            ("title", .stringAttributeType, true), // Заголовок задачи
            ("todoDescription", .stringAttributeType, true), // Описание задачи
            ("createdAt", .dateAttributeType, true), // Дата создания задачи
            ("isCompleted", .booleanAttributeType, false), // Статус выполнения задачи
            ("userId", .integer64AttributeType, false) // Идентификатор пользователя
        ]
        
        // Создание атрибутов для сущности
        taskEntity.properties = attributes.map { name, type, isOptional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            return attribute
        }
        
        model.entities = [taskEntity] // Добавление сущности в модель данных
        
        // Настройка контейнера и хранилища
        persistentContainer = NSPersistentContainer(name: "TodoList", managedObjectModel: model)
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // Использование временного хранилища для тестирования
        description.shouldAddStoreAsynchronously = false // Синхронная загрузка хранилища
        
        #if DEBUG
        description.url = URL(fileURLWithPath: "/dev/null") // Для отладки
        #else
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            description.url = documentsDirectory.appendingPathComponent("TodoList.sqlite") // Путь к файлу базы данных
        }
        #endif
        
        persistentContainer.persistentStoreDescriptions = [description]
        
        // Синхронная загрузка хранилища
        let group = DispatchGroup()
        group.enter()
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)") // Завершение работы приложения в случае ошибки
            }
            group.leave()
        }
        
        group.wait() // Ожидание завершения загрузки хранилища
    }
}
