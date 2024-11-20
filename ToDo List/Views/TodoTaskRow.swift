import SwiftUI

struct TodoTaskRow: View {
    let task: TodoTask
    let onUpdate: (TodoTask) -> Void
    @State private var isCompleted: Bool
    @State private var showingActionSheet = false
    @State private var showingEditView = false
    @Environment(\.managedObjectContext) private var viewContext
    
    init(task: TodoTask, onUpdate: @escaping (TodoTask) -> Void) {
        self.task = task
        self.onUpdate = onUpdate
        _isCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        ZStack {
            // Основной контент задачи
            HStack(spacing: 12) {
                // Checkbox
                Button(action: {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isCompleted.toggle()
                        var updatedTask = task
                        updatedTask.isCompleted = isCompleted
                        onUpdate(updatedTask)
                    }
                }) {
                    Circle()
                        .stroke(isCompleted ? Color.gray.opacity(0.6) : Color.orange, lineWidth: 2)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .fill(isCompleted ? Color.gray.opacity(0.6) : Color.clear)
                                .frame(width: 18, height: 18)
                        )
                        .animation(.spring(response: 0.2), value: isCompleted)
                }
                
                // Task Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.wrappedTitle)
                        .font(.system(size: 17))
                        .foregroundColor(isCompleted ? Color.gray.opacity(0.6) : .white)
                        .strikethrough(isCompleted, color: Color.gray.opacity(0.6))
                    
                    if !task.wrappedDescription.isEmpty {
                        Text(task.wrappedDescription)
                            .font(.system(size: 15))
                            .foregroundColor(Color.gray.opacity(0.8))
                            .lineLimit(1)
                    }
                    
                    Text(formattedDate(task.wrappedCreatedAt))
                        .font(.system(size: 13))
                        .foregroundColor(Color.gray.opacity(0.6))
                }
                .opacity(isCompleted ? 0.6 : 1)
                .animation(.easeInOut(duration: 0.2), value: isCompleted)
                
                Spacer()
            }
            .padding(.vertical, 6)
            .background(Color.black)
            .onLongPressGesture {
                withAnimation {
                    showingActionSheet = true
                }
            }
            
            // Меню действий
            if showingActionSheet {
                ActionMenu(
                    onEdit: {
                        withAnimation {
                            showingActionSheet = false
                            showingEditView = true
                        }
                    },
                    onShare: {
                        withAnimation {
                            showingActionSheet = false
                            shareTask()
                        }
                    },
                    onDelete: {
                        withAnimation {
                            showingActionSheet = false
                            deleteTask()
                        }
                    },
                    onDismiss: {
                        withAnimation {
                            showingActionSheet = false
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showingEditView) {
            TaskDetailView(task: task)
        }
    }
    
    private func deleteTask() {
        viewContext.delete(task)
        try? viewContext.save()
    }
    
    private func shareTask() {
        let textToShare = "\(task.wrappedTitle)\n\(task.wrappedDescription)"
        let activityVC = UIActivityViewController(
            activityItems: [textToShare],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = []
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
} 