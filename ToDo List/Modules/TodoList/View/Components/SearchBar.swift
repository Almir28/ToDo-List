import SwiftUI
import Speech
import AVFoundation

struct SearchBar: View {
    @Binding var text: String // Привязка текста для поиска
    let onSearchButtonClicked: () -> Void // Замыкание для обработки нажатия кнопки поиска
    @State private var isRecording = false // Статус записи
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru_RU")) // Распознаватель речи для русского языка
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? // Запрос на распознавание речи
    @State private var recognitionTask: SFSpeechRecognitionTask? // Задача распознавания речи
    @State private var audioEngine = AVAudioEngine() // Аудио движок для записи

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass") // Иконка поиска
                .foregroundColor(.gray)
            
            TextField("Поиск", text: $text) // Поле ввода для текста поиска
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .onSubmit(onSearchButtonClicked) // Обработка нажатия клавиши "Enter"
            
            Button(action: {
                // Переключение между началом и остановкой записи
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill") // Иконка микрофона или остановки записи
                    .foregroundColor(isRecording ? .red : .gray)
                    .font(.system(size: 20))
            }
            
            // Кнопка для очистки текста поиска
            if !text.isEmpty {
                Button(action: {
                    text = "" // Очистка текста
                    onSearchButtonClicked() // Обработка нажатия кнопки поиска
                }) {
                    Image(systemName: "xmark.circle.fill") // Иконка очистки
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8) // Вертикальные отступы
        .padding(.horizontal, 12) // Горизонтальные отступы
        .background(Color(hex: "#272729")) // Фоновый цвет
        .cornerRadius(10) // Закругление углов
        .padding(.horizontal) // Отступы по горизонтали
        .onAppear {
            setupSpeechRecognition() // Настройка распознавания речи при появлении
        }
    }
    
    /// Настройка распознавания речи и запрос разрешений
    private func setupSpeechRecognition() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Разрешение получено") // Разрешение на использование распознавания речи
                case .denied:
                    print("Пользователь отказал в доступе") // Пользователь отказал в доступе
                case .restricted:
                    print("Распознавание речи недоступно") // Распознавание речи недоступно
                case .notDetermined:
                    print("Разрешение не запрошено") // Разрешение не запрашивалось
                @unknown default:
                    print("Неизвестный статус") // Обработка неизвестного статуса
                }
            }
        }
    }
    
    /// Начало записи и распознавания речи
    private func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Распознавание речи недоступно") // Проверка доступности распознавания речи
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance() // Получение экземпляра аудио сессии
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers) // Настройка категории аудио
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation) // Активация аудио сессии
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest() // Создание запроса на распознавание
            recognitionRequest?.shouldReportPartialResults = true // Сообщать о промежуточных результатах
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.text = result.bestTranscription.formattedString // Обновление текста поиска
                        if !self.text.isEmpty {
                            self.onSearchButtonClicked() // Обработка нажатия кнопки поиска
                        }
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
            print("Ошибка записи: \(error)") // Обработка ошибки записи
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
