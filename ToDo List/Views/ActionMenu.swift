import SwiftUI
import UIKit

struct ActionMenu: View {
    let onEdit: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Размытый фон
            BlurView(style: .systemMaterial)
                .opacity(0.98)
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
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                Button(action: onShare) {
                    HStack {
                        Text("Поделиться")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                Button(action: onDelete) {
                    HStack {
                        Text("Удалить")
                            .font(.system(size: 17))
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(13)
            .frame(width: 300)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        .transition(.opacity.combined(with: .scale))
    }
}


