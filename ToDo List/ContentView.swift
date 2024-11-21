//
//  ContentView.swift
//  ToDo List
//
//  Created by Swift Developer on 20.11.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var presenter: TodoListPresenter
    @State private var searchText = ""
    @State private var showingNewTask = false
    @State private var isLoading = true
    
    init() {
        let context = CoreDataStack.shared.context
        _presenter = StateObject(wrappedValue: TodoListPresenter(context: context))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $searchText, onSearchButtonClicked: {
                        presenter.searchTasks(query: searchText)
                    })
                    .padding(.top)
                    .padding(.bottom, 8)
                    
                    // Task List
                    List {
                        ForEach(presenter.tasks, id: \.id) { task in
                            TodoTaskRow(task: task) { updatedTask in
                                presenter.updateTask(updatedTask)
                            }
                        }
                        .onDelete { indexSet in
                            presenter.deleteTasks(at: indexSet)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.black)
                    .scrollContentBackground(.hidden)
                    
                    // Bottom Bar with Task Count and Add Button
                    HStack {
                        Spacer()
                        Text("\(presenter.tasks.count) Задач")
                            .foregroundColor(.gray)
                            .font(.system(size: 13))
                        Spacer()
                        
                        NavigationLink(
                            isActive: $showingNewTask,
                            destination: {
                                NewTaskView()
                                    .environment(\.managedObjectContext, viewContext)
                                    .navigationBarBackButtonHidden(true)
                                    .onDisappear {
                                        presenter.refreshTasks()
                                    }
                            },
                            label: {
                                Image(systemName: "square.and.pencil")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        showingNewTask = true
                                    }
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(height: 50)
                    .background(Color(hex: "#272729").edgesIgnoringSafeArea(.bottom))
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color.gray.opacity(0.3)),
                        alignment: .top
                    )
                }
                
                if isLoading && presenter.tasks.isEmpty {
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        ProgressView("Загрузка задач...")
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("Задачи")
            .preferredColorScheme(.dark)
        }
        .onAppear {
            // Скрываем индикатор загрузки через 2 секунды
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
}

