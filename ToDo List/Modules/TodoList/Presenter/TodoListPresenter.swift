
import Foundation
import CoreData
import SwiftUI
/// Презентер для управления списком задач в VIPER архитектуре
/// Обеспечивает загрузку, отображение и управление задачами через CoreData и API
class TodoListPresenter: ObservableObject, TodoListPresenterProtocol {
    @Published var tasks: [TodoTask] = []
    @Published var isLoading = false
    private let viewContext: NSManagedObjectContext
    
    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorProtocol?
    var router: TodoListRouterProtocol?
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchTasks()
        Task {
            await loadInitialData()
        }
    }
    
    func viewDidLoad() {
        view?.showLoading()
        fetchTasks()
        view?.hideLoading()
    }
    
    func showNewTaskScreen() {
        guard let router = router else { return }
        _ = router.makeNewTaskView()
    }
    
    private func fetchTasks() {
        let request = TodoTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoTask.createdAt, ascending: false)]
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchedTasks = try self.viewContext.fetch(request)
                DispatchQueue.main.async {
                    self.tasks = fetchedTasks
                    self.view?.showTasks(fetchedTasks)
                }
            } catch {
                self.view?.showError(error)
            }
        }
    }
    
    func loadInitialData() async {
        let request = TodoTask.fetchRequest()
        let count = (try? viewContext.count(for: request)) ?? 0
        
        if count == 0 {
            await MainActor.run {
                isLoading = true
                view?.showLoading()
            }
            
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
                        view?.showError(error)
                    }
                    
                    isLoading = false
                    view?.hideLoading()
                }
            } catch {
                await MainActor.run {
                    view?.showError(error)
                    isLoading = false
                    view?.hideLoading()
                }
            }
        }
    }
    
    func addNewTask(title: String, description: String) {
        interactor?.addTask(title: title, description: description)
        view?.updateUI()
    }
    
    func updateTask(_ task: TodoTask) {
        interactor?.updateTask(task)
        view?.updateUI()
    }
    
    func deleteTasks(at indexSet: IndexSet) {
        indexSet.forEach { index in
            if let task = tasks[safe: index] {
                interactor?.deleteTask(task)
            }
        }
        view?.updateUI()
    }
    
    func searchTasks(query: String) {
        interactor?.searchTasks(query: query)
    }
    
    func didFetchTasks(_ tasks: [TodoTask]) {
        self.tasks = tasks
        view?.showTasks(tasks)
    }
    
    func didFailFetchingTasks(_ error: Error) {
        view?.showError(error)
    }
    
    func refreshTasks() {
            fetchTasks()
            view?.updateUI()
        }
    }


// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
