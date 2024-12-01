import XCTest
import CoreData
@testable import ToDo_List

/// Модульные тесты для VIPER модуля списка задач
/// Тестирует основной функционал и взаимодействие между компонентами
final class TodoListTests: XCTestCase {
    var presenter: TodoListPresenter! // Презентер для тестирования
    var view: MockTodoListView! // Мок-вью для тестирования
    var interactor: MockTodoListInteractor! // Мок-интерактор для тестирования
    var router: MockTodoListRouter! // Мок-роутер для тестирования
    var dataManager: MockTodoListDataManager! // Мок-менеджер данных для тестирования
    var coreDataStack: TestCoreDataStack! // Тестовый стек Core Data
    
    override func setUpWithError() throws {
        super.setUp()
        coreDataStack = TestCoreDataStack.shared // Инициализация тестового стека
        try coreDataStack.clearStore() // Очистка хранилища перед каждым тестом
        
        dataManager = MockTodoListDataManager(context: coreDataStack.context) // Инициализация мок-менеджера данных
        view = MockTodoListView() // Инициализация мок-вью
        interactor = MockTodoListInteractor(dataManager: dataManager) // Инициализация мок-интерактора
        presenter = TodoListPresenter(context: coreDataStack.context) // Инициализация презентера
        router = MockTodoListRouter() // Инициализация мок-роутера
        
        // Установка связей между компонентами
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
    }
    
    override func tearDownWithError() throws {
        try coreDataStack.clearStore() // Очистка хранилища после каждого теста
        
        // Сброс всех компонентов
        presenter = nil
        view = nil
        interactor = nil
        router = nil
        dataManager = nil
        super.tearDown()
    }
    
    /// Тестирование добавления новой задачи
    func testAddTask() async throws {
        // Выполняем операцию
        presenter.addNewTask(title: "Новая задача", description: "Описание")
        
        // Проверяем результаты
        XCTAssertTrue(view.updateUICalled) // Проверка, что UI был обновлен
        XCTAssertEqual(presenter.tasks.count, 1) // Проверка, что количество задач равно 1
        XCTAssertEqual(presenter.tasks.first?.title, "Новая задача") // Проверка заголовка задачи
    }
    
    /// Тестирование удаления задачи
    func testDeleteTask() async throws {
        let expectation = XCTestExpectation(description: "Delete task")
        
        presenter.addNewTask(title: "Test", description: "Test") // Добавление задачи
        try await Task.sleep(nanoseconds: 1_000_000_000) // Задержка для асинхронной операции
        
        XCTAssertEqual(presenter.tasks.count, 1) // Проверка, что задача добавлена
        presenter.deleteTasks(at: IndexSet(integer: 0)) // Удаление задачи
        
        try await Task.sleep(nanoseconds: 1_000_000_000) // Задержка для асинхронной операции
        XCTAssertTrue(view.updateUICalled) // Проверка, что UI был обновлен
        XCTAssertEqual(presenter.tasks.count, 0) // Проверка, что задачи удалены
        expectation.fulfill() // Завершение ожидания
        
        await fulfillment(of: [expectation], timeout: 3) // Ожидание выполнения
    }
    
    /// Тестирование поиска задач
    func testSearchTasks() async throws {
        let expectation = XCTestExpectation(description: "Search task")
        
        presenter.addNewTask(title: "Тестовая задача", description: "Test") // Добавление задачи
        try await Task.sleep(nanoseconds: 1_000_000_000) // Задержка для асинхронной операции
        
        presenter.searchTasks(query: "тест") // Поиск задачи
        
        try await Task.sleep(nanoseconds: 1_000_000_000) // Задержка для асинхронной операции
        XCTAssertTrue(view.updateUICalled) // Проверка, что UI был обновлен
        XCTAssertTrue(presenter.tasks.first?.title?.contains("тест") ?? false) // Проверка, что задача найдена
        expectation.fulfill() // Завершение ожидания
        
        await fulfillment(of: [expectation], timeout: 3) // Ожидание выполнения
    }
    
    /// Тестирование обновления задачи
    func testUpdateTask() async throws {
        let expectation = XCTestExpectation(description: "Update task")
        
        presenter.addNewTask(title: "Test", description: "Test") // Добавление задачи
        try await Task.sleep(nanoseconds: 1_000_000_000) // Задержка для асинхронной операции
        
        guard let task = presenter.tasks.first else {
            XCTFail("Task not created") // Проверка, что задача была создана
            return
        }
        
        // Обновление свойств задачи
        task.title = "Обновленная задача"
        task.todoDescription = "Новое описание"
        task.isCompleted = true
        
        presenter.updateTask(task) // Обновление задачи
        
        try await Task.sleep(nanoseconds: 1_000_000_000) // Задержка для асинхронной операции
        XCTAssertTrue(view.updateUICalled) // Проверка, что UI был обновлен
        XCTAssertEqual(presenter.tasks.first?.title, "Обновленная задача") // Проверка заголовка обновленной задачи
        expectation.fulfill() // Завершение ожидания
        
        await fulfillment(of: [expectation], timeout: 3) // Ожидание выполнения
    }
    
    /// Тестирование общего потока VIPER
    func testVIPERFlow() async throws {
        presenter.viewDidLoad() // Загрузка представления
        
        try await Task.sleep(nanoseconds: 2_000_000_000) // Задержка для асинхронной операции
        
        XCTAssertTrue(view.showLoadingCalled) // Проверка, что индикатор загрузки был показан
        XCTAssertTrue(view.showTasksCalled) // Проверка, что задачи были показаны
        XCTAssertFalse(view.showErrorCalled) // Проверка, что ошибки не было
    }
    
    /// Тестирование потока навигации
    func testNavigationFlow() async throws {
        presenter.showNewTaskScreen() // Показ экрана создания новой задачи
        XCTAssertTrue(router.makeNewTaskViewCalled) // Проверка, что метод создания нового задания был вызван
        
        // Создание тестовой задачи
        let task = TodoTask(context: coreDataStack.context)
        task.id = 1
        task.title = "Test"
        task.todoDescription = "Test"
        task.createdAt = Date()
        task.isCompleted = false
        task.userId = 1
        
        presenter.updateTask(task) // Обновление задачи
        XCTAssertTrue(router.makeEditTaskViewCalled) // Проверка, что метод редактирования задания был вызван
        
        _ = router.makeTaskDetailView(task: task) // Показ деталей задачи
        XCTAssertTrue(router.makeTaskDetailViewCalled) // Проверка, что метод показа деталей задания был вызван
    }
}
