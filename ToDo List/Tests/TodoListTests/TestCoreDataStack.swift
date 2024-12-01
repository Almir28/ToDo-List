import CoreData
@testable import ToDo_List

/// Тестовый стек CoreData для модульных тестов
/// Реализует in-memory хранилище и методы очистки данных
class TestCoreDataStack {
    static let shared = TestCoreDataStack() // Singleton для доступа к тестовому стеку
    
    let persistentContainer: NSPersistentContainer // Контейнер для хранения данных
    
    var context: NSManagedObjectContext { // Контекст для работы с данными
        return persistentContainer.viewContext
    }
    
    init() {
        let model = NSManagedObjectModel() // Создание модели данных
        
        let taskEntity = NSEntityDescription() // Описание сущности задачи
        taskEntity.name = "TodoTask" // Имя сущности
        taskEntity.managedObjectClassName = String(describing: TodoTask.self) // Класс управляемого объекта
        
        // Атрибуты сущности
        let attributes: [(String, NSAttributeType, Bool)] = [
            ("id", .integer64AttributeType, false),
            ("title", .stringAttributeType, true),
            ("todoDescription", .stringAttributeType, true),
            ("createdAt", .dateAttributeType, true),
            ("isCompleted", .booleanAttributeType, false),
            ("userId", .integer64AttributeType, false)
        ]
        
        // Создание свойств на основе атрибутов
        let properties = attributes.map { name, type, isOptional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            return attribute
        }
        
        taskEntity.properties = properties // Установка свойств для сущности
        model.entities = [taskEntity] // Добавление сущности в модель
        
        persistentContainer = NSPersistentContainer(name: "TodoList", managedObjectModel: model) // Инициализация контейнера
        
        let description = NSPersistentStoreDescription() // Описание хранилища
        description.type = NSInMemoryStoreType // Использование in-memory хранилища
        description.shouldAddStoreAsynchronously = false // Синхронная загрузка
        
        persistentContainer.persistentStoreDescriptions = [description] // Установка описания хранилища
        
        // Загрузка постоянных хранилищ
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)") // Обработка ошибок загрузки
            }
        }
    }
    
    /// Метод для очистки хранилища
    func clearStore() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TodoTask.fetchRequest() // Запрос для получения всех задач
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest) // Запрос на пакетное удаление
        batchDelete.resultType = .resultTypeObjectIDs // Установка типа результата
        
        let result = try context.execute(batchDelete) as? NSBatchDeleteResult // Выполнение запроса
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []] // Изменения для слияния
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context]) // Слияние изменений в контекст
    }
}
