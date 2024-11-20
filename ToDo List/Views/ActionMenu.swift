import SwiftUI

struct ActionMenu: View {
    let onEdit: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Размытый фон
            Color.black
                .opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        onDismiss()
                    }
                }
            
            // Меню действий
            VStack(spacing: 0) {
                Button(action: onEdit) {
                    HStack {
                        Text("Редактировать")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                }
                
                Divider()
                
                Button(action: onShare) {
                    HStack {
                        Text("Поделиться")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                }
                
                Divider()
                
                Button(action: onDelete) {
                    HStack {
                        Text("Удалить")
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                }
            }
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(13)
            .frame(width: 300)
        }
    }
}
