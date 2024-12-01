import SwiftUI
import CoreData
import Speech
import AVFoundation

/// Главный экран приложения со списком задач и голосовым поиском
/// Реализует отображение списка, поиск, создание задач и распознавание речи
struct TodoListView: View {
    @Environment(\.managedObjectContext) private var viewContext // Контекст для работы с Core Data
    @StateObject private var presenter: TodoListPresenter // Презентер для управления задачами
    @State private var searchText = "" // Текст для поиска задач
    @State private var showingNewTask = false // Статус отображения экрана создания новой задачи
    @State private var isLoading = true // Статус загрузки задач
    @State private var isRecording = false // Статус записи голоса
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US")) // Распознаватель речи
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? // Запрос на распознавание речи
    @State private var recognitionTask: SFSpeechRecognitionTask? // Задача распознавания речи
    @State private var audioEngine = AVAudioEngine() // Аудио движок для записи

    init(context: NSManagedObjectContext) {
        _presenter = StateObject(wrappedValue: TodoListPresenter(context: context)) // Инициализация презентера
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass") // Иконка поиска
                            .foregroundColor(.gray)
                        
                        TextField("Search", text: $searchText) // Поле для ввода текста поиска
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                            .onChange(of: searchText) { newValue in
                                presenter.searchTasks(query: newValue) // Поиск задач при изменении текста
                            }
                        
                        Button(action: {
                            // Переключение между началом и остановкой записи
                            if isRecording {
                                stopRecording()
                            } else {
                                startRecording()
                            }
                        }) {
                            Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill") // Иконка для записи
                                .foregroundColor(isRecording ? .red : .gray)
                                .font(.system(size: 20))
                        }
                        
                        // Кнопка для очистки текста поиска
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = "" // Очистка текста
                                presenter.searchTasks(query: "") // Сброс поиска
                            }) {
                                Image(systemName: "xmark.circle.fill") // Иконка очистки
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(hex: "#272729")) // Фоновый цвет поля поиска
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onAppear {
                        setupSpeechRecognition() // Настройка распознавания речи при появлении
                    }
                    
                    TaskListView(
                        presenter: presenter, // Передача презентера в список задач
                        searchText: $searchText // Привязка текста поиска
                    )
                    
                    BottomBarView(
                        presenter: presenter, // Передача презентера в нижнюю панель
                        showingNewTask: $showingNewTask, // Привязка статуса отображения нового задания
                        viewContext: viewContext // Передача контекста
                    )
                }
                
                // Показ загрузки, если задачи загружаются
                if isLoading && presenter.tasks.isEmpty {
                    LoadingView()
                }
            }
            .navigationTitle("Tasks") // Заголовок навигации
            .preferredColorScheme(.dark) // Предпочтительная цветовая схема
        }
        .onAppear {
            // Задержка перед скрытием индикатора загрузки
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
    
    /// Настройка распознавания речи и запрос разрешений
    private func setupSpeechRecognition() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Permission granted") // Разрешение получено
                case .denied:
                    print("User denied access") // Пользователь отказал в доступе
                case .restricted:
                    print("Speech recognition restricted") // Распознавание речи ограничено
                case .notDetermined:
                    print("Permission not requested") // Разрешение не запрашивалось
                @unknown default:
                    print("Unknown status") // Обработка неизвестного статуса
                }
            }
        }
    }
    
    /// Начало записи и распознавания речи
    private func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognition not available") // Проверка доступности распознавания речи
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance() // Получение экземпляра аудио сессии
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers) // Настройка категории
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation) // Активация аудио сессии
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest() // Создание запроса на распознавание
            recognitionRequest?.shouldReportPartialResults = true // Сообщать о промежуточных результатах
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.searchText = result.bestTranscription.formattedString // Обновление текста поиска
                        presenter.searchTasks(query: self.searchText) // Поиск задач
                    }
                }
                
                if error != nil || result?.isFinal == true {
                    stopRecording() // Остановка записи при ошибке или завершении распознавания
                }
            }
            
            let inputNode = audioEngine.inputNode // Получение входного узла аудио движка
            let recordingFormat = inputNode.outputFormat(forBus: 0) // Получение формата записи
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer) // Добавление буфера в запрос распознавания
            }
            
            audioEngine.prepare() // Подготовка аудио движка
            try audioEngine.start() // Запуск аудио движка
            isRecording = true // Установка статуса записи
            
        } catch {
            print("Recording error: \(error)") // Обработка ошибки записи
            stopRecording() // Остановка записи при ошибке
        }
    }
    
    /// Остановка записи и распознавания речи
    private func stopRecording() {
        audioEngine.stop() // Остановка аудио движка
        audioEngine.inputNode.removeTap(onBus: 0) // Удаление захвата на входном узле
        recognitionRequest?.endAudio() // Завершение аудио запроса
        recognitionTask?.cancel() // Отмена задачи распознавания
        isRecording = false // Сброс статуса записи
    }
}

private struct TaskListView: View {
    @ObservedObject var presenter: TodoListPresenter // Презентер для управления задачами
    @Binding var searchText: String // Привязка текста поиска
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(presenter.tasks) { task in
                    TodoTaskRow(
                        task: task,
                        onUpdate: { updatedTask in
                            presenter.updateTask(updatedTask) // Обновление задачи
                        },
                        onDelete: {
                            withAnimation {
                                presenter.viewDidLoad() // Обновление списка задач после удаления
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                    
                    // Разделитель между задачами
                    if task != presenter.tasks.last {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(hex: "#272729"))
                            .padding(.horizontal, 32)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Максимальная ширина для списка задач
        }
        .background(Color.black) // Фоновый цвет списка задач
    }
}

private struct BottomBarView: View {
    @ObservedObject var presenter: TodoListPresenter // Презентер для управления задачами
    @Binding var showingNewTask: Bool // Привязка статуса отображения нового задания
    let viewContext: NSManagedObjectContext // Контекст для работы с Core Data
    
    var body: some View {
        HStack {
            Spacer()
            Text("\(presenter.tasks.count) Tasks") // Отображение количества задач
                .foregroundColor(.gray)
                .font(.system(size: 13))
            Spacer()
            
            // Кнопка для добавления новой задачи
            NavigationLink(
                isActive: $showingNewTask,
                destination: {
                    NewTaskView()
                        .environment(\.managedObjectContext, viewContext) // Передача контекста
                        .navigationBarBackButtonHidden(true) // Скрытие кнопки "Назад"
                        .onDisappear {
                            presenter.viewDidLoad() // Обновление списка задач при возврате
                        }
                },
                label: {
                    AddTaskButton(showingNewTask: $showingNewTask) // Кнопка добавления задачи
                }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(height: 50)
        .background(Color(hex: "#272729").edgesIgnoringSafeArea(.bottom)) // Фоновый цвет нижней панели
        .overlay(
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(Color(hex: "#272729"))
                .padding(.horizontal, 20),
            alignment: .top // Разделитель в верхней части нижней панели
        )
    }
}

private struct AddTaskButton: View {
    @Binding var showingNewTask: Bool // Привязка статуса отображения нового задания
    
    var body: some View {
        Image(systemName: "square.and.pencil") // Иконка добавления задачи
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(.yellow)
            .onTapGesture {
                showingNewTask = true // Показать экран добавления новой задачи
            }
    }
}

private struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Фоновый цвет загрузки
            ProgressView("Loading tasks...") // Индикатор загрузки
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .yellow)) // Стиль индикатора
                .foregroundColor(.white)
        }
    }
}
