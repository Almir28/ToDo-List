//
//  TodoListVIPERTests.swift
//  ToDo List
//
//  Created by Swift Developer on 21.11.2024.
//

import Foundation

class TodoListVIPERTests: XCTestCase {
    var view: MockTodoListView!
    var interactor: TodoListInteractor!
    var presenter: TodoListPresenter!
    var router: MockTodoListRouter!
    var dataManager: TodoListDataManager!
    var coreDataStack: TestCoreDataStack!
    
    override func setUpWithError() throws {
        super.setUp()
        coreDataStack = TestCoreDataStack()
        dataManager = TodoListDataManager(context: coreDataStack.context)
        view = MockTodoListView()
        interactor = TodoListInteractor(dataManager: dataManager)
        presenter = TodoListPresenter()
        router = MockTodoListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
    }
    
    func testVIPERFlow() throws {
        let expectation = XCTestExpectation(description: "VIPER flow")
        
        presenter.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertTrue(self.view.showLoadingCalled)
            XCTAssertTrue(self.view.showTasksCalled)
            XCTAssertFalse(self.view.showErrorCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
}
