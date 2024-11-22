import SwiftUI
import UIKit

struct TodoTaskRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    let task: TodoTask
    let onUpdate: (TodoTask) -> Void
    let onDelete: () -> Void
    @State private var isCompleted: Bool
    @State private var isEditingNote = false
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var showingEditSheet = false
    
    init(task: TodoTask, onUpdate: @escaping (TodoTask) -> Void, onDelete: @escaping () -> Void) {
        self.task = task
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _isCompleted = State(initialValue: task.isCompleted)
        _editedTitle = State(initialValue: task.wrappedTitle)
        _editedDescription = State(initialValue: task.wrappedDescription)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            taskContentView
                .padding(.vertical, 8)
                .background(Color.black)
                .contextMenu {
                    VStack {
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Label {
                                Text("Редактировать")
                                    .foregroundColor(.black)
                            } icon: {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.black)
                            }
                        }
                        .background(.white)
                        
                        Button(action: {
                            shareNote()
                        }) {
                            Label {
                                Text("Поделиться")
                                    .foregroundColor(.black)
                            } icon: {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.black)
                            }
                        }
                        .background(.white)
                        
                        Button(role: .destructive, action: {
                            deleteNote()
                        }) {
                            Label {
                                Text("Удалить")
                                    .foregroundColor(.red)
                            } icon: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .background(.white)
                    }
                    .background(.white)
                } preview: {
                    ZStack {
                        Color(hex: "#272729")
                            .edgesIgnoringSafeArea(.all)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(task.wrappedTitle)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                if !task.wrappedDescription.isEmpty {
                                    Text(task.wrappedDescription)
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineSpacing(4)
                                }
                                
                                Text(formattedDate(task.wrappedCreatedAt))
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.gray)
                            }
                            .padding(20)
                        }
                    }
                    .frame(idealWidth: UIScreen.main.bounds.width - 60)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                EditTaskView(task: task, onUpdate: onUpdate)
            }
        }
    }
    
    private var checkboxView: some View {
        ZStack {
            Circle()
                .stroke(isCompleted ? Color.yellow : Color.gray.opacity(0.6), lineWidth: 1)
                .frame(width: 20, height: 20)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(.yellow)
            }
        }
        .contentShape(Circle())
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isCompleted.toggle()
                task.isCompleted = isCompleted
                onUpdate(task)
            }
        }
    }
    
    private var taskContentView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 12) {
                checkboxView
                
                Text(task.wrappedTitle)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isCompleted ? .gray : .white)
                    .strikethrough(isCompleted, color: .gray)
                    .lineLimit(1)
            }
            
            if !task.wrappedDescription.isEmpty {
                Text(task.wrappedDescription)
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(isCompleted ? .gray : .white)
                    .lineLimit(2)
                    .padding(.leading, 32)
            }
            
            Text(formattedDate(task.wrappedCreatedAt))
                .font(.system(size: 11, weight: .light))
                .foregroundColor(.gray.opacity(0.6))
                .padding(.leading, 32)
        }
        .opacity(isCompleted ? 0.6 : 1)
    }
    
    private func shareNote() {
        let text = "\(task.wrappedTitle)\n\(task.wrappedDescription)"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let viewController = window.rootViewController {
            viewController.present(av, animated: true)
        }
    }
    
    private func deleteNote() {
        viewContext.delete(task)
        do {
            try viewContext.save()
            onDelete()
        } catch {
            print("Error deleting note: \(error)")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}

extension View {
    func menuButtonStyle() -> some View {
        self
            .foregroundColor(.black)
            .background(.white)
    }
}
