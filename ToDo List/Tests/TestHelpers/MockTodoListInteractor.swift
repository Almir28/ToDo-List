import Foundation
@testable import ToDo_List

/// Мок-реализация интерактора для тестирования VIPER модуля
class MockTodoListInteractor: TodoListInteractorProtocol {
    var presenter: TodoListPresenterProtocol? // Презентер для взаимодействия с UI
    var dataManager: TodoListDataManagerProtocol // Менеджер данных для работы с задачами
    private var tasks: [TodoTask] = [] // Хранение задач
    
    init(dataManager: TodoListDataManagerProtocol) {
        self.dataManager = dataManager // Инициализация менеджера данных
    }
    
    /// Получение задач
    func fetchTasks() {
        Task {
            do {
                tasks = try await dataManager.fetchTasks() // Получение задач из менеджера данных
                await MainActor.run {
                    presenter?.didFetchTasks(tasks) // Уведомление презентера о получении задач
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailFetchingTasks(error) // Уведомление о неудаче получения задач
                }
            }
        }
    }
    
    /// Добавление новой задачи
    func addTask(title: String, description: String) {
        guard let mockDataManager = dataManager as? MockTodoListDataManager else { return } // Проверка типа менеджера данных
        
        Task {
            let task = TodoTask(context: mockDataManager.context) // Создание новой задачи
            task.id = Int64(tasks.count + 1) // Установка уникального идентификатора
            task.title = title // Установка заголовка
            task.todoDescription = description // Установка описания
            task.createdAt = Date() // Установка даты создания
            task.isCompleted = false // Установка статуса завершенности
            task.userId = 1 // Установка идентификатора пользователя
            
            do {
                try await dataManager.saveTask(task) // Сохранение задачи в менеджере данных
                tasks.append(task) // Добавление задачи в локальный массив
                await MainActor.run {
                    presenter?.didFetchTasks(tasks) // Уведомление презентера о получении задач
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailFetchingTasks(error) // Уведомление о неудаче сохранения задачи
                }
            }
        }
    }
    
    /// Обновление существующей задачи
    func updateTask(_ task: TodoTask) {
        Task {
            do {
                try await dataManager.updateTask(task) // Обновление задачи в менеджере данных
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index] = task // Обновление задачи в локальном массиве
                }
                await MainActor.run {
                    presenter?.didFetchTasks(tasks) // Уведомление презентера о получении задач
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailFetchingTasks(error) // Уведомление о неудаче обновления задачи
                }
            }
        }
    }
    
    /// Удаление задачи
    func deleteTask(_ task: TodoTask) {
        Task {
            do {
                try await dataManager.deleteTask(task) // Удаление задачи из менеджера данных
                tasks.removeAll { $0.id == task.id } // Удаление задачи из локального массива
                await MainActor.run {
                    presenter?.didFetchTasks(tasks) // Уведомление презентера о получении задач
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailFetchingTasks(error) // Уведомление о неудаче удаления задачи
                }
            }
        }
    }
    
    /// Поиск задач по запросу
    func searchTasks(query: String) {
        Task {
            do {
                let filteredTasks = try await dataManager.searchTasks(query: query) // Поиск задач в менеджере данных
                await MainActor.run {
                    presenter?.didFetchTasks(filteredTasks) // Уведомление презентера о получении задач
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailFetchingTasks(error) // Уведомление о неудаче поиска задач
                }
            }
        }
    }
    
    /// Загрузка начальных данных
    func loadInitialData() {
        fetchTasks() // Получение задач
    }
    
    /// Синхронизация с API (имитация)
    func syncWithAPI() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000) // Имитация задержки
        await MainActor.run {
            presenter?.didFetchTasks(tasks) // Уведомление презентера о получении задач
        }
    }
}
