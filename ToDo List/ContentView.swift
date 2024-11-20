//
//  ContentView.swift
//  ToDo List
//
//  Created by Swift Developer on 20.11.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var presenter: TodoListPresenter = TodoListPresenter()
    @State private var searchText = ""
    @State private var isAddingNewTask = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText, onSearchButtonClicked: {
                    presenter.searchTasks(query: searchText)
                })
                .padding(.top)
                
                // Task List
                List {
                    ForEach(presenter.tasks, id: \.id) { task in
                        NavigationLink(
                            destination: TaskDetailView(task: task),
                            label: {
                                TodoTaskRow(task: task) { updatedTask in
                                    presenter.updateTask(updatedTask)
                                }
                            }
                        )
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.black)
                
                // Bottom Bar with Task Count and Add Button
                HStack {
                    Spacer()
                    Text("\(presenter.tasks.count) Задач")
                        .foregroundColor(.gray)
                        .font(.system(size: 13))
                    Spacer()
                    
                    NavigationLink(isActive: $isAddingNewTask) {
                        NewTaskView { newTask in
                            presenter.addTask(newTask)
                            isAddingNewTask = false
                            presenter.viewDidLoad()
                        }
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(height: 50)
                .background(Color(hex: "272729").edgesIgnoringSafeArea(.bottom))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color.gray.opacity(0.3)),
                    alignment: .top
                )
            }
            .navigationTitle("Задачи")
            .preferredColorScheme(.dark)
        }
        .onAppear {
            presenter.viewDidLoad()
        }
    }
}

