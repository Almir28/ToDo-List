import SwiftUI
import AVFoundation

struct VoiceRecorderView: View {
    @State private var audioRecorder: AVAudioRecorder? // Аудио рекордер для записи
    @State private var isRecording = false // Статус записи
    @State private var recordingURL: URL? // URL для сохранения записи
    
    /// Функция для начала записи
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance() // Получение экземпляра аудио сессии
        
        do {
            // Настройка категории и активация аудио сессии
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            // Получение пути для сохранения записи
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("recording.m4a") // Имя файла записи
            
            // Настройки для аудио рекордера
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC), // Формат аудио
                AVSampleRateKey: 12000, // Частота дискретизации
                AVNumberOfChannelsKey: 1, // Количество каналов
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue // Качество кодирования
            ]
            
            // Инициализация аудио рекордера
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record() // Начало записи
            isRecording = true // Установка статуса записи
            recordingURL = audioFilename // Сохранение URL записи
            
        } catch {
            print("Ошибка записи: \(error.localizedDescription)") // Обработка ошибок
        }
    }
    
    /// Функция для остановки записи
    func stopRecording() {
        audioRecorder?.stop() // Остановка записи
        isRecording = false // Сброс статуса записи
    }
    
    var body: some View {
        VStack {
            // Кнопка для начала/остановки записи
            Button(action: {
                if isRecording {
                    stopRecording() // Остановка записи
                } else {
                    startRecording() // Начало записи
                }
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill") // Иконка кнопки
                    .font(.system(size: 44)) // Размер иконки
                    .foregroundColor(isRecording ? .red : .yellow) // Цвет иконки в зависимости от статуса записи
            }
            
            // Текстовое сообщение о статусе записи
            Text(isRecording ? "Запись..." : "Нажмите для записи")
                .foregroundColor(.gray) // Цвет текста
                .font(.system(size: 14)) // Размер шрифта
        }
    }
}
