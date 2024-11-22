import CoreData
/// Контроллер персистентности для управления CoreData стеком
/// Реализует синглтон паттерн для централизованного доступа к хранилищу
struct PersistenceController {
    /// Общий экземпляр для использования во всем приложении
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "TodoList")
        
        // Загрузка хранилища
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        // Автоматическое слияние изменений из родительского контекста
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
