import Foundation

// MARK: - View
protocol TodoListViewProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set }
    func showTasks(_ tasks: [TodoTask])
    func showError(_ error: Error)
    func showLoading()
    func hideLoading()
}

// MARK: - Presenter
protocol TodoListPresenterProtocol: AnyObject {
    var view: TodoListViewProtocol? { get set }
    var interactor: TodoListInteractorProtocol? { get set }
    var router: TodoListRouterProtocol? { get set }
    
    func viewDidLoad()
    func addTask(_ task: TodoTask)
    func updateTask(_ task: TodoTask)
    func deleteTask(_ task: TodoTask)
    func searchTasks(query: String)
}

// MARK: - Interactor
protocol TodoListInteractorProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set }
    
    func fetchTasks()
    func saveTask(_ task: TodoTask)
    func removeTask(_ task: TodoTask)
    func updateTask(_ task: TodoTask)
    func searchTasks(matching query: String)
}

// MARK: - Router
protocol TodoListRouterProtocol: AnyObject {
    static func createTodoListModule() -> ContentView
    func navigateToTaskDetail(from view: TodoListViewProtocol, task: TodoTask?)
} 