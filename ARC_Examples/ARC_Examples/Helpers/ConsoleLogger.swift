//
//  ConsoleLogger.swift
//  ARC_Examples
//
//  Created by Menkov Dmitriy on 03.01.2026.
//

import Foundation

/// Класс для красивого форматированного вывода в консоль
/// Использует эмодзи и разделители для наглядности
class ConsoleLogger {

    // MARK: - Log Levels

    /// Уровни логирования с соответствующими эмодзи
    enum LogLevel {
        case info       // Информационное сообщение
        case success    // Успешная операция
        case warning    // Предупреждение
        case error      // Ошибка
        case debug      // Отладочная информация

        var emoji: String {
            switch self {
            case .info:     return "ℹ️"
            case .success:  return "✅"
            case .warning:  return "⚠️"
            case .error:    return "❌"
            case .debug:    return "🔍"
            }
        }
    }

    // MARK: - Базовое логирование

    /// Печатает сообщение с уровнем
    /// - Parameters:
    ///   - message: Текст сообщения
    ///   - level: Уровень логирования
    static func log(_ message: String, level: LogLevel = .info) {
        print("\(level.emoji) \(message)")
    }

    /// Печатает несколько сообщений
    static func log(_ messages: [String], level: LogLevel = .info) {
        for message in messages {
            log(message, level: level)
        }
    }

    // MARK: - Разделители и секции

    /// Печатает заголовок секции
    /// - Parameter title: Название секции
    static func section(_ title: String) {
        print("\n" + String(repeating: "═", count: 60))
        print("📍 \(title)")
        print(String(repeating: "─", count: 60))
    }

    /// Печатает подсекцию
    /// - Parameter title: Название подсекции
    static func subsection(_ title: String) {
        print("\n--- \(title) ---")
    }

    /// Печатает разделитель
    static func separator() {
        print(String(repeating: "─", count: 60))
    }

    /// Печатает двойной разделитель (конец секции)
    static func doubleSeparator() {
        print(String(repeating: "═", count: 60))
    }

    // MARK: - Специализированные методы

    /// Печатает заголовок демо
    /// - Parameter title: Название демо
    static func demoHeader(_ title: String) {
        print("\n" + String(repeating: "═", count: 60))
        print("🎬 DEMO: \(title)")
        print(String(repeating: "═", count: 60) + "\n")
    }

    /// Печатает подзаголовок примера
    /// - Parameter title: Название примера
    static func exampleHeader(_ title: String) {
        print("\n" + String(repeating: "─", count: 60))
        print("📝 Пример: \(title)")
        print(String(repeating: "─", count: 60))
    }

    /// Печатает результат операции
    /// - Parameters:
    ///   - message: Описание результата
    ///   - success: Успешно ли выполнилось
    static func result(_ message: String, success: Bool) {
        let emoji = success ? "✅" : "❌"
        let status = success ? "УСПЕХ" : "ПРОВАЛ"
        print("\n\(emoji) РЕЗУЛЬТАТ (\(status)): \(message)\n")
    }

    /// Печатает важное примечание
    /// - Parameter note: Текст примечания
    static func note(_ note: String) {
        print("\n💡 ВАЖНО: \(note)\n")
    }

    /// Печатает вывод/заключение
    /// - Parameter conclusion: Текст вывода
    static func conclusion(_ conclusion: String) {
        print("\n🎯 ВЫВОД: \(conclusion)\n")
    }

    // MARK: - Форматированный вывод

    /// Печатает список с буллетами
    /// - Parameters:
    ///   - items: Элементы списка
    ///   - title: Опциональный заголовок списка
    static func list(_ items: [String], title: String? = nil) {
        if let title = title {
            print("\n\(title):")
        }

        for item in items {
            print("   • \(item)")
        }
        print()
    }

    /// Печатает нумерованный список
    /// - Parameters:
    ///   - items: Элементы списка
    ///   - title: Опциональный заголовок списка
    static func numberedList(_ items: [String], title: String? = nil) {
        if let title = title {
            print("\n\(title):")
        }

        for (index, item) in items.enumerated() {
            print("   \(index + 1). \(item)")
        }
        print()
    }

    /// Печатает код с отступом
    /// - Parameter code: Строка кода
    static func code(_ code: String) {
        print("\n```")
        print(code)
        print("```\n")
    }

    // MARK: - Специальные индикаторы

    /// Печатает индикатор создания объекта
    /// - Parameters:
    ///   - type: Тип объекта
    ///   - name: Имя/идентификатор объекта
    static func objectCreated(type: String, name: String) {
        log("\(type) '\(name)' создан", level: .success)
    }

    /// Печатает индикатор удаления объекта
    /// - Parameters:
    ///   - type: Тип объекта
    ///   - name: Имя/идентификатор объекта
    static func objectDestroyed(type: String, name: String) {
        log("\(type) '\(name)' удален", level: .info)
    }

    /// Печатает индикатор утечки памяти
    /// - Parameter message: Описание утечки
    static func memoryLeak(_ message: String) {
        log("УТЕЧКА ПАМЯТИ: \(message)", level: .error)
    }

    /// Печатает индикатор retain cycle
    /// - Parameter objects: Объекты в цикле
    static func retainCycle(_ objects: [String]) {
        log("RETAIN CYCLE обнаружен: \(objects.joined(separator: " ↔ "))", level: .error)
    }

    // MARK: - Задачи с собеседований

    /// Печатает заголовок задачи с собеседования
    /// - Parameter title: Название задачи
    static func interviewTask(_ title: String) {
        print("\n" + String(repeating: "═", count: 60))
        print("💼 ЗАДАЧА С СОБЕСЕДОВАНИЯ")
        print(String(repeating: "─", count: 60))
        print("📋 \(title)")
        print(String(repeating: "═", count: 60) + "\n")
    }

    /// Печатает вопрос
    /// - Parameter question: Текст вопроса
    static func question(_ question: String) {
        print("\n❓ ВОПРОС: \(question)\n")
    }

    /// Печатает правильный ответ
    /// - Parameter answer: Текст ответа
    static func answer(_ answer: String) {
        print("\n✅ ОТВЕТ: \(answer)\n")
    }

    // MARK: - Прогресс и статус

    /// Печатает индикатор шага
    /// - Parameters:
    ///   - number: Номер шага
    ///   - description: Описание шага
    static func step(_ number: Int, _ description: String) {
        print("\n▶️  Шаг \(number): \(description)")
    }

    /// Печатает пустую строку (для читаемости)
    static func blank() {
        print()
    }
}

// MARK: - Примеры использования (для справки)

/*
 ПРИМЕР 1: Базовое логирование

 ConsoleLogger.log("Приложение запущено", level: .success)
 ConsoleLogger.log("Проверка памяти...", level: .info)
 ConsoleLogger.log("Обнаружена утечка!", level: .error)


 ПРИМЕР 2: Секции

 ConsoleLogger.section("RETAIN CYCLES DEMO")
 ConsoleLogger.subsection("Person и CreditCard")


 ПРИМЕР 3: Объекты

 ConsoleLogger.objectCreated(type: "Person", name: "Alex")
 ConsoleLogger.objectDestroyed(type: "Person", name: "Alex")


 ПРИМЕР 4: Задача с собеседования

 ConsoleLogger.interviewTask("Найди Retain Cycle")
 ConsoleLogger.question("Где в этом коде утечка памяти?")
 ConsoleLogger.answer("В строке 10 - strong ссылка создает цикл")


 ПРИМЕР 5: Списки

 ConsoleLogger.list([
     "Создали Person",
     "Создали CreditCard",
     "Связали их"
 ], title: "Что произошло")
 */

