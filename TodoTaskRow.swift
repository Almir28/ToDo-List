struct TodoTaskRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    let task: TodoTask
    let onUpdate: (TodoTask) -> Void
    @State private var isCompleted: Bool
    
    init(task: TodoTask, onUpdate: @escaping (TodoTask) -> Void) {
        self.task = task
        self.onUpdate = onUpdate
        _isCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                checkboxView
                taskContentView
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color.black)
            .contextMenu {
                Button(action: {
                    // Действие редактирования
                }) {
                    Label("Редактировать", systemImage: "square.and.pencil")
                }
                
                Button(action: {
                    shareNote()
                }) {
                    Label("Поделиться", systemImage: "square.and.arrow.up")
                }
                
                Button(role: .destructive, action: {
                    deleteNote()
                }) {
                    Label("Удалить", systemImage: "trash")
                }
            } preview: {
                TaskPreviewContent(task: task)
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
    
    private var checkboxView: some View {
        ZStack {
            Circle()
                .stroke(isCompleted ? Color.yellow : Color.gray.opacity(0.6), lineWidth: 1)
                .frame(width: 22, height: 22)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .light))
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
        VStack(alignment: .leading, spacing: 4) {
            Text(task.wrappedTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(isCompleted ? .gray : .white)
                .strikethrough(isCompleted, color: .gray)
                .lineLimit(1)
            
            if !task.wrappedDescription.isEmpty {
                Text(task.wrappedDescription)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(isCompleted ? .gray : .white)
                    .lineLimit(2)
            }
            
            Text(formattedDate(task.wrappedCreatedAt))
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.gray.opacity(0.6))
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
        try? viewContext.save()
    }
} 