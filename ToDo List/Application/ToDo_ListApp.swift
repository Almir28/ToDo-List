import SwiftUI
import CoreData

@main
struct ToDo_ListApp: App {
    /// Стек CoreData для управления данными
    let persistenceController = CoreDataStack.shared // Использование синглтона CoreDataStack для доступа к контексту данных
    
    var body: some Scene {
        WindowGroup {
            // Основное представление списка задач, передающее контекст Core Data
            TodoListView(context: persistenceController.context)
                .environment(\.managedObjectContext, persistenceController.context) // Установка контекста для среды SwiftUI
        }
    }
}
