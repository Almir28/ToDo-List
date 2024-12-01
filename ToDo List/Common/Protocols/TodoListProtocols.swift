import Foundation
import CoreData
import SwiftUI

/// Протоколы для реализации VIPER архитектуры
/// Определяет контракты между компонентами: View, Interactor, Presenter, Entity, Router

// MARK: - View Protocol
protocol TodoListViewProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set } // Презентер, который управляет представлением
    
    /// Отображение списка задач
    func showTasks(_ tasks: [TodoTask])
    /// Отображение ошибки
    func showError(_ error: Error)
    /// Показать индикатор загрузки
    func showLoading()
    /// Скрыть индикатор загрузки
    func hideLoading()
    /// Обновление пользовательского интерфейса
    func updateUI()
}

// MARK: - Presenter Protocol
protocol TodoListPresenterProtocol: AnyObject {
    var view: TodoListViewProtocol? { get set } // Представление, с которым работает презентер
    var interactor: TodoListInteractorProtocol? { get set } // Интерактор для работы с данными
    var router: TodoListRouterProtocol? { get set } // Роутер для навигации
    
    /// Состояние презентера
    var tasks: [TodoTask] { get } // Список задач
    var isLoading: Bool { get } // Статус загрузки
    
    /// Методы управления задачами
    func viewDidLoad() // Метод, вызываемый при загрузке представления
    func showNewTaskScreen() // Показать экран для создания новой задачи
    func addNewTask(title: String, description: String) // Добавить новую задачу
    func updateTask(_ task: TodoTask) // Обновить существующую задачу
    func deleteTasks(at indexSet: IndexSet) // Удалить задачи по индексу
    func searchTasks(query: String) // Поиск задач по запросу
    
    /// Колбэки от интерактора
    func didFetchTasks(_ tasks: [TodoTask]) // Обработка полученных задач
    func didFailFetchingTasks(_ error: Error) // Обработка ошибки при получении задач
}

// MARK: - Interactor Protocol
protocol TodoListInteractorProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set } // Презентер, с которым работает интерактор
    var dataManager: TodoListDataManagerProtocol { get } // Менеджер данных для работы с хранилищем
    
    /// Методы работы с данными
    func fetchTasks() // Получение списка задач
    func addTask(title: String, description: String) // Добавление новой задачи
    func updateTask(_ task: TodoTask) // Обновление задачи
    func deleteTask(_ task: TodoTask) // Удаление задачи
    func searchTasks(query: String) // Поиск задач по запросу
    
    /// Методы синхронизации
    func loadInitialData() // Загрузка начальных данных
    func syncWithAPI() async throws // Синхронизация с API
}

// MARK: - Router Protocol
protocol TodoListRouterProtocol: AnyObject {
    /// Создание экрана для новой задачи
    func makeNewTaskView() -> UIViewController
    /// Создание экрана для редактирования задачи
    func makeEditTaskView(task: TodoTask) -> UIViewController
    /// Создание экрана для деталей задачи
    func makeTaskDetailView(task: TodoTask) -> UIViewController
}

// MARK: - Entity Protocol
/// Протокол для сущности задачи
protocol TodoEntityProtocol {
    var id: Int64 { get set } // Уникальный идентификатор задачи
    var title: String? { get set } // Заголовок задачи
    var todoDescription: String? { get set } // Описание задачи
    var createdAt: Date? { get set } // Дата создания задачи
    var isCompleted: Bool { get set } // Статус выполнения задачи
    var userId: Int64 { get set } // Идентификатор пользователя
}
