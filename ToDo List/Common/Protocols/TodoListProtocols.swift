import Foundation
import CoreData
import SwiftUI
/// Протоколы для реализации VIPER архитектуры
/// Определяет контракты между компонентами: View, Interactor, Presenter, Entity, Router

// MARK: - View Protocol
protocol TodoListViewProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set }
    
    func showTasks(_ tasks: [TodoTask])
    func showError(_ error: Error)
    func showLoading()
    func hideLoading()
    func updateUI()
}

// MARK: - Presenter Protocol
protocol TodoListPresenterProtocol: AnyObject {
    var view: TodoListViewProtocol? { get set }
    var interactor: TodoListInteractorProtocol? { get set }
    var router: TodoListRouterProtocol? { get set }
    
    /// Состояние презентера
    var tasks: [TodoTask] { get }
    var isLoading: Bool { get }
    
    /// Методы управления задачами
    func viewDidLoad()
    func showNewTaskScreen()
    func addNewTask(title: String, description: String)
    func updateTask(_ task: TodoTask)
    func deleteTasks(at indexSet: IndexSet)
    func searchTasks(query: String)
    
    /// Колбэки от интерактора
    func didFetchTasks(_ tasks: [TodoTask])
    func didFailFetchingTasks(_ error: Error)
}

// MARK: - Interactor Protocol
protocol TodoListInteractorProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set }
    var dataManager: TodoListDataManagerProtocol { get }
    
    /// Методы работы с данными
    func fetchTasks()
    func addTask(title: String, description: String)
    func updateTask(_ task: TodoTask)
    func deleteTask(_ task: TodoTask)
    func searchTasks(query: String)
    
    /// Методы синхронизации
    func loadInitialData()
    func syncWithAPI() async throws
}

// MARK: - Router Protocol
protocol TodoListRouterProtocol: AnyObject {
    func makeNewTaskView() -> UIViewController
    func makeEditTaskView(task: TodoTask) -> UIViewController
    func makeTaskDetailView(task: TodoTask) -> UIViewController
}

// MARK: - Entity Protocol
/// Протокол для сущности задачи
protocol TodoEntityProtocol {
    var id: Int64 { get set }
    var title: String? { get set }
    var todoDescription: String? { get set }
    var createdAt: Date? { get set }
    var isCompleted: Bool { get set }
    var userId: Int64 { get set }
}
