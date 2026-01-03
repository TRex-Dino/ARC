//
//  VirtualMemoryDemo.swift
//  ARC_Examples
//
//  Created by Menkov Dmitriy on 03.01.2026.
//

import Foundation
import UIKit

// MARK: - Virtual Memory Demo

/// Демонстрация виртуальной памяти и Memory Pressure
class VirtualMemoryDemo {

    // MARK: - Главная функция демо

    static func runVirtualMemoryDemo() {
        ConsoleLogger.section("ВИРТУАЛЬНАЯ ПАМЯТЬ И MEMORY PRESSURE")

        explainVirtualMemory()
        demonstrateVirtualAddresses()
        explainMemoryPressure()

        ConsoleLogger.doubleSeparator()
    }

    // MARK: - Объяснение Virtual Memory

    private static func explainVirtualMemory() {
        ConsoleLogger.subsection("Виртуальная память")

        ConsoleLogger.log("""
        Когда я говорю 'у iPhone 4GB RAM', это физическая память.
        Но твое приложение работает с виртуальной памятью.
        
        Виртуальная память — это абстракция:
        • iOS создает для каждого приложения иллюзию
        • Приложение видит весь адресный диапазон для себя
        • Реально эти адреса маппятся на физическую RAM через MMU
        """, level: .info)

        ConsoleLogger.note("""
        Зачем это нужно:
        1. Безопасность — одно приложение не может залезть в память другого
        2. Изоляция — краш одного приложения не роняет систему
        3. Эффективность — можно использовать swap (хранение на диске)
        """)
    }

    // MARK: - Демонстрация адресов

    private static func demonstrateVirtualAddresses() {
        ConsoleLogger.subsection("Пример адресов в виртуальной памяти")

        // Stack адрес
        var stackVariable = 42
        withUnsafePointer(to: &stackVariable) { pointer in
            ConsoleLogger.log("Stack адрес: \(pointer)", level: .debug)
        }

        // Heap адрес
        class TempObject {
            let value: Int
            init(value: Int) { self.value = value }
        }

        let heapObject = TempObject(value: 100)
        let objectID = ObjectIdentifier(heapObject)
        ConsoleLogger.log("Heap адрес: \(objectID)", level: .debug)

        ConsoleLogger.note("""
        Эти адреса — виртуальные!
        • Приложение видит эти адреса
        • MMU (Memory Management Unit) переводит их в физические
        • Другое приложение может видеть те же адреса, но для своих данных
        """)
    }

    // MARK: - Memory Pressure

    private static func explainMemoryPressure() {
        ConsoleLogger.subsection("Memory Pressure (давление на память)")

        ConsoleLogger.log("""
        Если RAM заканчивается, iOS начинает испытывать memory pressure.
        
        Что делает система:
        1. Отправляет Memory Warning всем приложениям
        2. Приложения должны освободить кеши, изображения
        3. Если не помогло — iOS убивает фоновые приложения
        4. Если совсем плохо — убивает твое приложение (jetsam event)
        """, level: .warning)

        ConsoleLogger.note("""
        Как разработчик, ты должен обрабатывать Memory Warnings:
        
        // В UIViewController
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Освобождаем кеши, изображения
            imageCache.removeAll()
        }
        
        // Для всего приложения
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Освобождаем ресурсы
        }
        """)

        ConsoleLogger.conclusion("""
        Если не обработаешь Memory Warning:
        • Приложение крашнется на слабых устройствах
        • Проблемы при многозадачности
        • Плохой user experience
        """)
    }
}

// MARK: - Memory Warning Handler (для реального использования)

/// Helper класс для мониторинга Memory Warnings
class MemoryWarningHandler {

    static let shared = MemoryWarningHandler()

    private var observer: NSObjectProtocol?

    func startMonitoring() {
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }

        ConsoleLogger.log("Memory Warning мониторинг запущен", level: .success)
    }

    func stopMonitoring() {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
            ConsoleLogger.log("Memory Warning мониторинг остановлен", level: .info)
        }
    }

    private func handleMemoryWarning() {
        ConsoleLogger.log("⚠️ MEMORY WARNING ПОЛУЧЕН!", level: .warning)
        ConsoleLogger.log("Приложение должно освободить кеши и ресурсы", level: .warning)

        // Здесь можно добавить логику освобождения памяти
        // Например: imageCache.removeAll()
    }

    deinit {
        stopMonitoring()
    }
}

// MARK: - Как использовать

/*
 В ViewController.swift раскомментируй:

 VirtualMemoryDemo.runVirtualMemoryDemo()

 // Опционально: запустить мониторинг Memory Warnings
 MemoryWarningHandler.shared.startMonitoring()

 Ожидаемый вывод:

 ═══════════════════════════════════════════════════════════
 📍 ВИРТУАЛЬНАЯ ПАМЯТЬ И MEMORY PRESSURE
 ───────────────────────────────────────────────────────────

 --- Виртуальная память ---
 ℹ️ Когда я говорю 'у iPhone 4GB RAM', это физическая память...

 💡 ВАЖНО: Зачем это нужно:
 1. Безопасность...

 --- Пример адресов в виртуальной памяти ---
 🔍 Stack адрес: 0x00007ff7bfeff8c8
 🔍 Heap адрес: ObjectIdentifier(0x0000600000404080)

 💡 ВАЖНО: Эти адреса — виртуальные!...

 --- Memory Pressure (давление на память) ---
 ⚠️ Если RAM заканчивается, iOS начинает испытывать memory pressure...

 💡 ВАЖНО: Как разработчик, ты должен обрабатывать...

 🎯 ВЫВОД: Если не обработаешь Memory Warning...

 ═══════════════════════════════════════════════════════════
 */
