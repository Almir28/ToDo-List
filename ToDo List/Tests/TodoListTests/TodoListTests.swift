//
//  TodoListTests.swift
//  TodoListTests
//
//  Created by Swift Developer on 21.11.2024.
//

import XCTest
import CoreData
@testable import ToDo_List
/// Модульные тесты для VIPER модуля списка задач
/// Тестирует основной функционал и взаимодействие между компонентами
final class TodoListTests: XCTestCase {
    var presenter: TodoListPresenter!
    var view: MockTodoListView!
    var interactor: MockTodoListInteractor!
    var router: MockTodoListRouter!
    var dataManager: MockTodoListDataManager!
    var coreDataStack: TestCoreDataStack!
    
    override func setUpWithError() throws {
            super.setUp()
            coreDataStack = TestCoreDataStack.shared
            try coreDataStack.clearStore()
            
            dataManager = MockTodoListDataManager(context: coreDataStack.context)
            view = MockTodoListView()
            interactor = MockTodoListInteractor(dataManager: dataManager)
            presenter = TodoListPresenter(context: coreDataStack.context)
            router = MockTodoListRouter()
            
            view.presenter = presenter
            presenter.view = view
            presenter.interactor = interactor
            presenter.router = router
            interactor.presenter = presenter
        }
        
        override func tearDownWithError() throws {
            try coreDataStack.clearStore()
            
            presenter = nil
            view = nil
            interactor = nil
            router = nil
            dataManager = nil
            super.tearDown()
        }
    
    func testAddTask() async throws {
        // Выполняем операцию
        presenter.addNewTask(title: "Новая задача", description: "Описание")
        
        // Проверяем результаты
        XCTAssertTrue(view.updateUICalled)
        XCTAssertEqual(presenter.tasks.count, 1)
        XCTAssertEqual(presenter.tasks.first?.title, "Новая задача")
    }
    
    func testDeleteTask() async throws {
        let expectation = XCTestExpectation(description: "Delete task")
        
        presenter.addNewTask(title: "Test", description: "Test")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        XCTAssertEqual(presenter.tasks.count, 1)
        presenter.deleteTasks(at: IndexSet(integer: 0))
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertTrue(view.updateUICalled)
        XCTAssertEqual(presenter.tasks.count, 0)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 3)
    }
    
    func testSearchTasks() async throws {
        let expectation = XCTestExpectation(description: "Search task")
        
        presenter.addNewTask(title: "Тестовая задача", description: "Test")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        presenter.searchTasks(query: "тест")
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertTrue(view.updateUICalled)
        XCTAssertTrue(presenter.tasks.first?.title?.contains("тест") ?? false)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 3)
    }
    
    func testUpdateTask() async throws {
        let expectation = XCTestExpectation(description: "Update task")
        
        presenter.addNewTask(title: "Test", description: "Test")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        guard let task = presenter.tasks.first else {
            XCTFail("Task not created")
            return
        }
        
        task.title = "Обновленная задача"
        task.todoDescription = "Новое описание"
        task.isCompleted = true
        
        presenter.updateTask(task)
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertTrue(view.updateUICalled)
        XCTAssertEqual(presenter.tasks.first?.title, "Обновленная задача")
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 3)
    }
    
    func testVIPERFlow() async throws {
        presenter.viewDidLoad()
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        XCTAssertTrue(view.showLoadingCalled)
        XCTAssertTrue(view.showTasksCalled)
        XCTAssertFalse(view.showErrorCalled)
    }
    
    func testNavigationFlow() async throws {
        presenter.showNewTaskScreen()
        XCTAssertTrue(router.makeNewTaskViewCalled)
        
        let task = TodoTask(context: coreDataStack.context)
        task.id = 1
        task.title = "Test"
        task.todoDescription = "Test"
        task.createdAt = Date()
        task.isCompleted = false
        task.userId = 1
        
        presenter.updateTask(task)
        XCTAssertTrue(router.makeEditTaskViewCalled)
        
        _ = router.makeTaskDetailView(task: task)
        XCTAssertTrue(router.makeTaskDetailViewCalled)
    }
}
