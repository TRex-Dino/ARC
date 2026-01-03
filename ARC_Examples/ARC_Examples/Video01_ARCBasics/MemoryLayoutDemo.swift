//
//  MemoryLayoutDemo.swift
//  ARC_Examples
//
//  Created by Menkov Dmitriy on 03.01.2026.
//

import Foundation

// MARK: - Memory Layout Demo

/// Демонстрация структуры памяти: Stack, Heap, Data Segment
class MemoryLayoutDemo {

    // MARK: - Типы данных для демонстрации

    // Value type (Stack)
    struct Point {
        var x: Int
        var y: Int
    }

    // Reference type (Heap)
    class PersonDemo {
        let name: String

        init(name: String) {
            self.name = name
            ObjectCounter.incrementWithLog("PersonDemo", name: name)
        }

        deinit {
            ObjectCounter.decrementWithLog("PersonDemo", name: name)
        }
    }

    // Global variable (Data Segment)
    static var globalCounter: Int = 100

    // MARK: - Главная функция демо

    static func runMemoryLayoutDemo() {
        ConsoleLogger.section("MEMORY LAYOUT DEMO")

        demonstrateStackVariables()
        demonstrateHeapObjects()
        demonstrateGlobalVariables()
        demonstrateAddresses()

        ConsoleLogger.doubleSeparator()
    }

    // MARK: - Stack Variables

    private static func demonstrateStackVariables() {
        ConsoleLogger.subsection("Stack Variables (Value Types)")

        // Value типы живут в Stack
        let point = Point(x: 10, y: 20)
        let message = "Hello World"
        let number = 42

        ConsoleLogger.log("Point: x=\(point.x), y=\(point.y)", level: .info)
        ConsoleLogger.log("String: \(message)", level: .info)
        ConsoleLogger.log("Int: \(number)", level: .info)

        ConsoleLogger.note("""
        Эти переменные хранятся в Stack:
        • Выделение памяти = мгновенно (просто сдвиг указателя)
        • Освобождение = автоматически при выходе из scope
        • Компактное расположение = хороший cache locality
        """)

        // При выходе из функции все эти переменные автоматически удалятся из Stack
    }

    // MARK: - Heap Objects

    private static func demonstrateHeapObjects() {
        ConsoleLogger.subsection("Heap Objects (Reference Types)")

        // Reference типы живут в Heap
        var person: PersonDemo? = PersonDemo(name: "Alex")

        // Получаем уникальный идентификатор объекта
        if let person = person {
            let objectID = ObjectIdentifier(person)
            ConsoleLogger.log("PersonDemo создан | ObjectID: \(objectID)", level: .info)
        }

        ConsoleLogger.note("""
        Объект PersonDemo хранится в Heap:
        • Выделение памяти = медленнее (нужно найти свободное место)
        • Освобождение = через ARC (когда RC = 0)
        • Требует управления временем жизни
        """)

        // Удаляем объект
        ConsoleLogger.log("\nОбнуляем переменную person...", level: .info)
        person = nil
        // deinit вызовется автоматически

        ConsoleLogger.conclusion("Переменная person (в Stack) удалилась, объект PersonDemo (в Heap) тоже удалился")
    }

    // MARK: - Global Variables

    private static func demonstrateGlobalVariables() {
        ConsoleLogger.subsection("Global Variables (Data Segment)")

        ConsoleLogger.log("globalCounter: \(globalCounter)", level: .info)

        globalCounter += 50
        ConsoleLogger.log("После изменения: \(globalCounter)", level: .info)

        ConsoleLogger.note("""
        Глобальная переменная хранится в Data Segment:
        • Живет все время работы приложения
        • Инициализируется при запуске
        • Занимает память постоянно
        • Вот почему глобальные переменные = плохая практика
        """)
    }

    // MARK: - Адреса памяти

    private static func demonstrateAddresses() {
        ConsoleLogger.subsection("Адреса памяти (концептуально)")

        // Value type
        var stackValue = 42

        // Reference type
        let heapObject = PersonDemo(name: "Bob")

        // Используем withUnsafePointer для демонстрации
        withUnsafePointer(to: &stackValue) { pointer in
            ConsoleLogger.log("Stack адрес переменной: \(pointer)", level: .debug)
        }

        // Для reference типа показываем ObjectIdentifier
        let objectID = ObjectIdentifier(heapObject)
        ConsoleLogger.log("Heap объект ID: \(objectID)", level: .debug)

        ConsoleLogger.note("""
        Обратите внимание:
        • Stack адреса обычно начинаются с 0x7ff... (высокие адреса)
        • Heap адреса обычно начинаются с 0x600... (средние адреса)
        • Это виртуальная память, не физические адреса
        """)

        ConsoleLogger.conclusion("""
        Stack vs Heap:
        ┌─────────────┬──────────────┬──────────────┐
        │  Критерий   │    Stack     │     Heap     │
        ├─────────────┼──────────────┼──────────────┤
        │ Типы данных │ Value типы   │ Reference    │
        │ Скорость    │ Быстро ⚡    │ Медленнее 🐌 │
        │ Размер      │ Ограничен    │ Большой      │
        │ Управление  │ Автоматом    │ ARC          │
        └─────────────┴──────────────┴──────────────┘
        """)
    }
}

// MARK: - Как использовать

/*
 В ViewController.swift раскомментируй:

 MemoryLayoutDemo.runMemoryLayoutDemo()

 Ожидаемый вывод:

 ═══════════════════════════════════════════════════════════
 📍 MEMORY LAYOUT DEMO
 ───────────────────────────────────────────────────────────

 --- Stack Variables (Value Types) ---
 ℹ️ Point: x=10, y=20
 ℹ️ String: Hello World
 ℹ️ Int: 42

 💡 ВАЖНО: Эти переменные хранятся в Stack...

 --- Heap Objects (Reference Types) ---
 ✅ PersonDemo 'Alex' создан | Всего в памяти: 1
 ℹ️ PersonDemo создан | ObjectID: ObjectIdentifier(0x...)

 ℹ️ Обнуляем переменную person...
 ℹ️ PersonDemo 'Alex' удален | Осталось в памяти: 0

 🎯 ВЫВОД: Переменная person (в Stack) удалилась...

 --- Global Variables (Data Segment) ---
 ℹ️ globalCounter: 100
 ℹ️ После изменения: 150

 --- Адреса памяти (концептуально) ---
 🔍 Stack адрес переменной: 0x00007ff7bfeff8c8
 ✅ PersonDemo 'Bob' создан | Всего в памяти: 1
 🔍 Heap объект ID: ObjectIdentifier(0x0000600000404080)
 ℹ️ PersonDemo 'Bob' удален | Осталось в памяти: 0

 ═══════════════════════════════════════════════════════════
 */
