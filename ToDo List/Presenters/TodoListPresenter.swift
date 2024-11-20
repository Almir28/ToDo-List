import Foundation
import CoreData
import SwiftUI

class TodoListPresenter: ObservableObject {
    @Published var tasks: [TodoTask] = []
    private var context: NSManagedObjectContext
    
    init() {
        self.context = CoreDataStack.shared.context
    }
    
    func viewDidLoad() {
        fetchTasks()
    }
    
    func fetchTasks() {
        let request = NSFetchRequest<TodoTask>(entityName: "TodoTask")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoTask.createdAt, ascending: false)]
        
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Ошибка загрузки задач: \(error)")
        }
    }
    
    func addTask(_ task: TodoTask) {
        tasks.insert(task, at: 0)
        objectWillChange.send()
    }
    
    func updateTask(_ task: TodoTask) {
        do {
            try context.save()
            fetchTasks()
        } catch {
            print("Ошибка обновления задачи: \(error)")
        }
    }
    
    func searchTasks(query: String) {
        let request = NSFetchRequest<TodoTask>(entityName: "TodoTask")
        if !query.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR todoDescription CONTAINS[cd] %@", query, query)
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoTask.createdAt, ascending: false)]
        
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Ошибка поиска задач: \(error)")
        }
    }
} 