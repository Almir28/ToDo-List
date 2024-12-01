import Foundation
import CoreData
import SwiftUI

/// Презентер для управления списком задач в VIPER архитектуре
/// Обеспечивает загрузку, отображение и управление задачами через CoreData и API
class TodoListPresenter: ObservableObject, TodoListPresenterProtocol {
    @Published var tasks: [TodoTask] = [] // Список задач, наблюдаемый для обновления UI
    @Published var isLoading = false // Статус загрузки
    private let viewContext: NSManagedObjectContext // Контекст для работы с Core Data
    
    weak var view: TodoListViewProtocol? // Ссылка на представление
    var interactor: TodoListInteractorProtocol? // Ссылка на интерактор
    var router: TodoListRouterProtocol? // Ссылка на роутер
    
    /// Инициализация презентера с заданным контекстом
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchTasks() // Загрузка задач при инициализации
        Task {
            await loadInitialData() // Загрузка начальных данных асинхронно
        }
    }
    
    /// Метод, вызываемый при загрузке представления
    func viewDidLoad() {
        view?.showLoading() // Показать индикатор загрузки
        fetchTasks() // Загрузить задачи
        view?.hideLoading() // Скрыть индикатор загрузки
    }
    
    /// Показать экран для создания новой задачи
    func showNewTaskScreen() {
        guard let router = router else { return }
        _ = router.makeNewTaskView() // Переход на экран создания новой задачи
    }
    
    /// Загрузка задач из Core Data
    private func fetchTasks() {
        let request = TodoTask.fetchRequest() // Создание запроса для получения задач
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoTask.createdAt, ascending: false)] // Сортировка по дате создания
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchedTasks = try self.viewContext.fetch(request) // Выполнение запроса
                DispatchQueue.main.async {
                    self.tasks = fetchedTasks // Обновление списка задач
                    self.view?.showTasks(fetchedTasks) // Отображение задач в представлении
                }
            } catch {
                self.view?.showError(error) // Обработка ошибки
            }
        }
    }
    
    /// Загрузка начальных данных из API, если в Core Data нет задач
    func loadInitialData() async {
        let request = TodoTask.fetchRequest() // Создание запроса для получения задач
        let count = (try? viewContext.count(for: request)) ?? 0 // Подсчет задач в Core Data
        
        if count == 0 { // Если задач нет
            await MainActor.run {
                isLoading = true // Установка статуса загрузки
                view?.showLoading() // Показать индикатор загрузки
            }
            
            do {
                let apiTodos = try await APIService.shared.fetchTodos() // Получение задач из API
                
                await MainActor.run {
                    for apiTodo in apiTodos {
                        let newTask = TodoTask(context: viewContext) // Создание новой задачи
                        newTask.id = Int64(apiTodo.id)
                        newTask.title = apiTodo.todo
                        newTask.todoDescription = ""
                        newTask.createdAt = Date()
                        newTask.isCompleted = apiTodo.completed
                        newTask.userId = Int64(apiTodo.userId)
                    }
                    
                    do {
                        try viewContext.save() // Сохранение новых задач в Core Data
                        fetchTasks() // Обновление списка задач
                    } catch {
                        view?.showError(error) // Обработка ошибки
                    }
                    
                    isLoading = false // Сброс статуса загрузки
                    view?.hideLoading() // Скрыть индикатор загрузки
                }
            } catch {
                await MainActor.run {
                    view?.showError(error) // Обработка ошибки
                    isLoading = false // Сброс статуса загрузки
                    view?.hideLoading() // Скрыть индикатор загрузки
                }
            }
        }
    }
    
    /// Добавление новой задачи
    func addNewTask(title: String, description: String) {
        interactor?.addTask(title: title, description: description) // Передача задачи интерактору
        view?.updateUI() // Обновление пользовательского интерфейса
    }
    
    /// Обновление существующей задачи
    func updateTask(_ task: TodoTask) {
        interactor?.updateTask(task) // Передача задачи интерактору
        view?.updateUI() // Обновление пользовательского интерфейса
    }
    
    /// Удаление задач по индексу
    func deleteTasks(at indexSet: IndexSet) {
        indexSet.forEach { index in
            if let task = tasks[safe: index] { // Безопасный доступ к задаче по индексу
                interactor?.deleteTask(task) // Передача задачи интерактору для удаления
            }
        }
        view?.updateUI() // Обновление пользовательского интерфейса
    }
    
    /// Поиск задач по запросу
    func searchTasks(query: String) {
        interactor?.searchTasks(query: query) // Передача запроса интерактору
    }
    
    /// Обработка полученных задач
    func didFetchTasks(_ tasks: [TodoTask]) {
        self.tasks = tasks // Обновление списка задач
        view?.showTasks(tasks) // Отображение задач в представлении
    }
    
    /// Обработка ошибки при получении задач
    func didFailFetchingTasks(_ error: Error) {
        view?.showError(error) // Отображение ошибки в представлении
    }
    
    /// Обновление списка задач
    func refreshTasks() {
        fetchTasks() // Повторная загрузка задач
        view?.updateUI() // Обновление пользовательского интерфейса
    }
}

// MARK: - Array Extension
extension Array {
    /// Безопасный доступ к элементам массива по индексу
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil // Возвращает элемент, если индекс допустим
    }
}
