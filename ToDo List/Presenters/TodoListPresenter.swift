import Foundation
import CoreData
import SwiftUI

class TodoListPresenter: ObservableObject {
    @Published var tasks: [TodoTask] = []
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchTasks()
        Task {
            await loadInitialTasks()
        }
    }
    
    private func fetchTasks() {
        let request = TodoTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoTask.createdAt, ascending: false)]
        
        do {
            tasks = try viewContext.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
    
    private func loadInitialTasks() async {
        let request = TodoTask.fetchRequest()
        let count = (try? viewContext.count(for: request)) ?? 0
        
        if count == 0 {
            do {
                let apiTodos = try await APIService.shared.fetchTodos()
                
                await MainActor.run {
                    for apiTodo in apiTodos {
                        let newTask = TodoTask(context: viewContext)
                        newTask.id = Int64(apiTodo.id)
                        newTask.title = apiTodo.todo
                        newTask.todoDescription = ""
                        newTask.createdAt = Date()
                        newTask.isCompleted = apiTodo.completed
                        newTask.userId = Int64(apiTodo.userId)
                    }
                    
                    do {
                        try viewContext.save()
                        fetchTasks()
                    } catch {
                        print("Error saving initial tasks: \(error)")
                    }
                }
            } catch {
                print("Error loading initial tasks: \(error)")
            }
        }
    }
    
    func updateTask(_ task: TodoTask) {
        do {
            try viewContext.save()
            objectWillChange.send()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func deleteTasks(at indexSet: IndexSet) {
        indexSet.forEach { index in
            viewContext.delete(tasks[index])
        }
        
        do {
            try viewContext.save()
            fetchTasks()
        } catch {
            print("Error deleting task: \(error)")
        }
    }
    
    func addNewTask() {
        let newTask = TodoTask(context: viewContext)
        newTask.id = Int64(Date().timeIntervalSince1970)
        newTask.title = "Новая задача"
        newTask.todoDescription = ""
        newTask.createdAt = Date()
        newTask.isCompleted = false
        
        do {
            try viewContext.save()
            fetchTasks()
        } catch {
            print("Error adding new task: \(error)")
        }
    }
    
    func searchTasks(query: String) {
        let request = TodoTask.fetchRequest()
        if !query.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR todoDescription CONTAINS[cd] %@", query, query)
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoTask.createdAt, ascending: false)]
        
        do {
            tasks = try viewContext.fetch(request)
        } catch {
            print("Error searching tasks: \(error)")
        }
    }
    
    func refreshTasks() {
        fetchTasks()
    }
} 