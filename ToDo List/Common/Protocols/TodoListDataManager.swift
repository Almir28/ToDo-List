//
//  TodoListDataManager.swift
//  ToDo List
//
//  Created by Swift Developer on 21.11.2024.
//

import CoreData

protocol TodoListDataManagerProtocol {
    func fetchTasks() async throws -> [TodoTask]
    func saveTask(_ task: TodoTask) async throws
    func deleteTask(_ task: TodoTask) async throws
    func searchTasks(query: String) async throws -> [TodoTask]
    func updateTask(_ task: TodoTask) async throws
}

class TodoListDataManager: TodoListDataManagerProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTasks() async throws -> [TodoTask] {
        let request = NSFetchRequest<TodoTask>(entityName: "TodoTask")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return try context.fetch(request)
    }
    
    func saveTask(_ task: TodoTask) async throws {
        try context.save()
    }
    
    func deleteTask(_ task: TodoTask) async throws {
        context.delete(task)
        try context.save()
    }
    
    func searchTasks(query: String) async throws -> [TodoTask] {
        let request = TodoTask.fetchRequest()
        if !query.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR todoDescription CONTAINS[cd] %@", query, query)
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoTask.createdAt, ascending: false)]
        return try context.fetch(request)
    }
    
    func updateTask(_ task: TodoTask) async throws {
        try context.save()
    }
}
