//
//  TodoListVIPERTests.swift
//  ToDo List
//
//  Created by Swift Developer on 21.11.2024.
//

import XCTest
import CoreData
import UIKit
@testable import ToDo_List
/// Интеграционные тесты VIPER архитектуры для Todo приложения
/// Проверяет взаимодействие между всеми слоями и CoreData
final class TodoListVIPERTests: XCTestCase {
    var view: MockTodoListView!
    var interactor: TodoListInteractorProtocol!
    var presenter: TodoListPresenter!
    var router: MockTodoListRouter!
    var dataManager: MockTodoListDataManager!
    var coreDataStack: TestCoreDataStack!
    
    override func setUpWithError() throws {
        super.setUp()
        coreDataStack = TestCoreDataStack()
        try setupTest()
    }
    
    private func setupTest() throws {
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
        view = nil
        interactor = nil
        presenter = nil
        router = nil
        dataManager = nil
        coreDataStack = nil
        super.tearDown()
    }
    
    @MainActor
    func testVIPERFlow() async throws {
        await presenter.viewDidLoad()
        try await Task.sleep(for: .seconds(2))
        
        XCTAssertTrue(view.showLoadingCalled)
        XCTAssertTrue(view.showTasksCalled)
        XCTAssertFalse(view.showErrorCalled)
    }
    
    @MainActor
    func testAddTaskVIPERFlow() async throws {
        try await presenter.addNewTask(title: "Test Task", description: "Test Description")
        try await Task.sleep(for: .seconds(1))
        
        XCTAssertTrue(view.updateUICalled)
        XCTAssertEqual(presenter.tasks.count, 1)
        XCTAssertEqual(presenter.tasks.first?.title, "Test Task")
        
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        let count = try coreDataStack.context.count(for: fetchRequest)
        XCTAssertEqual(count, 1)
    }
    
    @MainActor
    func testDeleteTaskVIPERFlow() async throws {
        // Создаем задачу
        try await presenter.addNewTask(title: "Test Task", description: "Test Description")
        try await Task.sleep(for: .seconds(1))
        
        XCTAssertEqual(presenter.tasks.count, 1)
        
        // Удаляем задачу
        try await presenter.deleteTasks(at: IndexSet(integer: 0))
        try await Task.sleep(for: .seconds(1))
        
        XCTAssertEqual(presenter.tasks.count, 0)
        
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        let count = try coreDataStack.context.count(for: fetchRequest)
        XCTAssertEqual(count, 0)
    }
}
