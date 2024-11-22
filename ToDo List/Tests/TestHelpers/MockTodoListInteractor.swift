//
//  MockTodoListInteractor.swift
//  TodoListTests
//
//  Created by Swift Developer on 22.11.2024.
//

import Foundation
@testable import ToDo_List
/// Мок-реализация интерактора для тестирования VIPER модуля
class MockTodoListInteractor: TodoListInteractorProtocol {
    var presenter: TodoListPresenterProtocol?
    var dataManager: TodoListDataManagerProtocol
    private var tasks: [TodoTask] = []
    
    init(dataManager: TodoListDataManagerProtocol) {
        self.dataManager = dataManager
    }
    
    func fetchTasks() {
        Task {
            do {
                tasks = try await dataManager.fetchTasks()
                await MainActor.run {
                    presenter?.didFetchTasks(tasks)
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailFetchingTasks(error)
                }
            }
        }
    }
    
    func addTask(title: String, description: String) {
        guard let mockDataManager = dataManager as? MockTodoListDataManager else { return }
        
        Task {
            let task = TodoTask(context: mockDataManager.context)
            task.id = Int64(tasks.count + 1)
            task.title = title
            task.todoDescription = description
            task.createdAt = Date()
            task.isCompleted = false
            task.userId = 1
            
            do {
                try await dataManager.saveTask(task)
                tasks.append(task)
                await MainActor.run {
                    presenter?.didFetchTasks(tasks)
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailFetchingTasks(error)
                }
            }
        }
    }
    
    func updateTask(_ task: TodoTask) {
        Task {
            do {
                try await dataManager.updateTask(task)
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index] = task
                }
                await MainActor.run {
                    presenter?.didFetchTasks(tasks)
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailFetchingTasks(error)
                }
            }
        }
    }
    
    func deleteTask(_ task: TodoTask) {
        Task {
            do {
                try await dataManager.deleteTask(task)
                tasks.removeAll { $0.id == task.id }
                await MainActor.run {
                    presenter?.didFetchTasks(tasks)
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailFetchingTasks(error)
                }
            }
        }
    }
    
    func searchTasks(query: String) {
        Task {
            do {
                let filteredTasks = try await dataManager.searchTasks(query: query)
                await MainActor.run {
                    presenter?.didFetchTasks(filteredTasks)
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailFetchingTasks(error)
                }
            }
        }
    }
    
    func loadInitialData() {
        fetchTasks()
    }
    
    func syncWithAPI() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            presenter?.didFetchTasks(tasks)
        }
    }
}
