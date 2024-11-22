//
//  MockTodoListDataManager.swift
//  TodoListTests
//
//  Created by Swift Developer on 22.11.2024.
//

import CoreData
@testable import ToDo_List
/// Мок-реализация менеджера данных для тестирования
/// Имитирует работу TodoListDataManager для модульных тестов
class MockTodoListDataManager: TodoListDataManagerProtocol {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTasks() async throws -> [TodoTask] {
        return []
    }
    
    func saveTask(_ task: TodoTask) async throws {}
    
    func deleteTask(_ task: TodoTask) async throws {}
    
    func searchTasks(query: String) async throws -> [TodoTask] {
        return []
    }
    
    func updateTask(_ task: TodoTask) async throws {}
}
