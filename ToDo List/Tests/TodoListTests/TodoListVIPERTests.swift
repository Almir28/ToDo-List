import XCTest
import CoreData
import UIKit
@testable import ToDo_List

/// Интеграционные тесты VIPER архитектуры для Todo приложения
/// Проверяет взаимодействие между всеми слоями и CoreData
final class TodoListVIPERTests: XCTestCase {
    var view: MockTodoListView! // Мок-вью для тестирования
    var interactor: TodoListInteractorProtocol! // Интерактор для тестирования
    var presenter: TodoListPresenter! // Презентер для тестирования
    var router: MockTodoListRouter! // Мок-роутер для тестирования
    var dataManager: MockTodoListDataManager! // Мок-менеджер данных для тестирования
    var coreDataStack: TestCoreDataStack! // Тестовый стек Core Data
    
    override func setUpWithError() throws {
        super.setUp()
        coreDataStack = TestCoreDataStack() // Инициализация тестового стека
        try setupTest() // Настройка тестовой среды
    }
    
    private func setupTest() throws {
        // Инициализация всех компонентов для тестирования
        dataManager = MockTodoListDataManager(context: coreDataStack.context)
        view = MockTodoListView()
        interactor = MockTodoListInteractor(dataManager: dataManager)
        presenter = TodoListPresenter(context: coreDataStack.context)
        router = MockTodoListRouter()
        
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
        view = nil
        interactor = nil
        presenter = nil
        router = nil
        dataManager = nil
        coreDataStack = nil
        super.tearDown()
    }
    
    /// Тестирование общего потока VIPER
    @MainActor
    func testVIPERFlow() async throws {
        await presenter.viewDidLoad() // Загрузка представления
        try await Task.sleep(for: .seconds(2)) // Задержка для асинхронной операции
        
        // Проверка, что индикатор загрузки был показан и задачи были загружены
        XCTAssertTrue(view.showLoadingCalled)
        XCTAssertTrue(view.showTasksCalled)
        XCTAssertFalse(view.showErrorCalled) // Проверка, что ошибки не было
    }
    
    /// Тестирование добавления задачи в потоке VIPER
    @MainActor
    func testAddTaskVIPERFlow() async throws {
        try await presenter.addNewTask(title: "Test Task", description: "Test Description") // Добавление новой задачи
        try await Task.sleep(for: .seconds(1)) // Задержка для асинхронной операции
        
        // Проверка, что UI был обновлен и задача добавлена
        XCTAssertTrue(view.updateUICalled)
        XCTAssertEqual(presenter.tasks.count, 1) // Проверка количества задач
        XCTAssertEqual(presenter.tasks.first?.title, "Test Task") // Проверка заголовка задачи
        
        // Проверка, что задача сохранена в Core Data
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        let count = try coreDataStack.context.count(for: fetchRequest)
        XCTAssertEqual(count, 1) // Проверка количества задач в хранилище
    }
    
    /// Тестирование удаления задачи в потоке VIPER
    @MainActor
    func testDeleteTaskVIPERFlow() async throws {
        // Создаем задачу
        try await presenter.addNewTask(title: "Test Task", description: "Test Description")
        try await Task.sleep(for: .seconds(1)) // Задержка для асинхронной операции
        
        XCTAssertEqual(presenter.tasks.count, 1) // Проверка, что задача добавлена
        
        // Удаляем задачу
        try await presenter.deleteTasks(at: IndexSet(integer: 0))
        try await Task.sleep(for: .seconds(1)) // Задержка для асинхронной операции
        
        XCTAssertEqual(presenter.tasks.count, 0) // Проверка, что задачи удалены
        
        // Проверка, что задача удалена из Core Data
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        let count = try coreDataStack.context.count(for: fetchRequest)
        XCTAssertEqual(count, 0) // Проверка количества задач в хранилище
    }
}
