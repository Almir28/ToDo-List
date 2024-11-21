import SwiftUI
import CoreData

struct TodoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var presenter: TodoListPresenter
    @State private var searchText = ""
    
    init(context: NSManagedObjectContext) {
        _presenter = StateObject(wrappedValue: TodoListPresenter(context: context))
    }
    
    var body: some View {
        List {
            ForEach(presenter.tasks) { task in
                TodoTaskRow(task: task, onUpdate: { updatedTask in
                    presenter.updateTask(updatedTask)
                })
            }
            .onDelete { indexSet in
                presenter.deleteTasks(at: indexSet)
            }
        }
        .listStyle(PlainListStyle())
        .searchable(text: $searchText, prompt: "Поиск задач")
        .onChange(of: searchText) { newValue in
            presenter.searchTasks(query: newValue)
        }
        .navigationTitle("Задачи")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    presenter.addNewTask()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
} 
