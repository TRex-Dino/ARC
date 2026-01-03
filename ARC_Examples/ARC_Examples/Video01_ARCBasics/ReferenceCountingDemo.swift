//
//  ReferenceCountingDemo.swift
//  ARC_Examples
//
//  Created by Menkov Dmitriy on 03.01.2026.
//

import Foundation

// MARK: - Reference Counting Demo

/// Демонстрация работы Reference Counting
class ReferenceCountingDemo {

    // MARK: - Класс для демонстрации

    class User {
        let name: String
        let id: Int

        init(name: String) {
            self.name = name
            self.id = ObjectCounter.increment("User")

            let objectID = ObjectIdentifier(self)
            ConsoleLogger.log("User #\(id) '\(name)' создан | ObjectID: \(objectID) | Всего в памяти: \(id)", level: .success)
        }

        deinit {
            let remaining = ObjectCounter.decrement("User")
            ConsoleLogger.log("User #\(id) '\(name)' удален | Осталось в памяти: \(remaining)", level: .info)
        }
    }

    // MARK: - Главная функция демо

    static func runReferenceCountingDemo() {
        ConsoleLogger.section("REFERENCE COUNTING DEMO")

        exampleOneReference()
        exampleMultipleReferences()
        exampleScopeBasedDeallocation()
        demonstrateThreeRules()

        ObjectCounter.printSummary()
        ConsoleLogger.doubleSeparator()
    }

    // MARK: - Пример 1: Одна ссылка

    private static func exampleOneReference() {
        ConsoleLogger.subsection("Пример 1: Одна ссылка")

        ARCVisualizer.printStep(
            number: 1,
            code: "var user = User(\"Alex\")",
            description: "Создаем объект и присваиваем переменной",
            objectsAlive: []
        )

        var user: User? = User(name: "Alex")
        // RC = 1 (user держит объект)

        ARCVisualizer.printStep(
            number: 2,
            code: "user = nil",
            description: "Обнуляем переменную",
            objectsAlive: ["User 'Alex'"]
        )

        user = nil
        // RC = 0 → deinit вызывается

        ConsoleLogger.conclusion("""
        Когда единственная ссылка исчезает → RC = 0 → объект удаляется
        """)
    }

    // MARK: - Пример 2: Несколько ссылок

    private static func exampleMultipleReferences() {
        ConsoleLogger.subsection("Пример 2: Несколько ссылок на один объект")

        ARCVisualizer.startTimeline()

        ARCVisualizer.logEvent("▶️ Создаем первую ссылку")
        var user1: User? = User(name: "Bob")
        // RC = 1

        ARCVisualizer.logEvent("▶️ Создаем вторую ссылку")
        var user2 = user1
        // RC = 2 (user1 и user2 указывают на один объект)

        ARCVisualizer.logEvent("▶️ Создаем третью ссылку")
        var user3 = user1
        // RC = 3 (user1, user2, user3 указывают на один объект)

        ConsoleLogger.note("""
        Все три переменные указывают на ОДИН объект в памяти.
        ObjectIdentifier у всех одинаковый.
        """)

        ARCVisualizer.logEvent("▶️ user1 = nil (RC уменьшается)")
        user1 = nil
        // RC = 2 (объект еще жив)
        ConsoleLogger.log("user1 = nil, объект все еще жив (RC = 2)", level: .info)

        ARCVisualizer.logEvent("▶️ user2 = nil (RC уменьшается)")
        user2 = nil
        // RC = 1 (объект еще жив)
        ConsoleLogger.log("user2 = nil, объект все еще жив (RC = 1)", level: .info)

        ARCVisualizer.logEvent("▶️ user3 = nil (RC = 0 → deinit)")
        user3 = nil
        // RC = 0 → deinit вызывается

        ARCVisualizer.logEvent("✅ Объект удален")
        ARCVisualizer.printTimeline(title: "Жизненный цикл объекта с 3 ссылками")

        ConsoleLogger.conclusion("""
        Объект живет пока есть хотя бы ОДНА strong ссылка.
        Только когда ВСЕ ссылки исчезают → RC = 0 → deinit.
        """)
    }

    // MARK: - Пример 3: Scope-based deallocation

    private static func exampleScopeBasedDeallocation() {
        ConsoleLogger.subsection("Пример 3: Автоматическое удаление при выходе из scope")

        ConsoleLogger.log("Входим в inner scope...", level: .info)

        do {
            ConsoleLogger.log("Внутри scope - создаем объект", level: .debug)
            let user = User(name: "Charlie")
            // RC = 1

            ConsoleLogger.log("Используем объект: \(user.name)", level: .debug)

            ConsoleLogger.log("Достигли конца scope...", level: .debug)
            // При выходе из scope переменная user уничтожается
            // RC = 0 → deinit вызывается автоматически
        }

        ConsoleLogger.log("Вышли из scope", level: .info)

        ConsoleLogger.conclusion("""
        Локальные переменные автоматически уничтожаются при выходе из scope.
        Это триггерит уменьшение RC → если RC = 0, объект удаляется.
        """)
    }

    // MARK: - Три правила ARC

    private static func demonstrateThreeRules() {
        ConsoleLogger.subsection("Три правила ARC")

        ConsoleLogger.log("""
        ╔═══════════════════════════════════════════════╗
        ║           ТРИ ПРАВИЛА ARC                     ║
        ╠═══════════════════════════════════════════════╣
        ║                                               ║
        ║  1️⃣ Создали ссылку → RC + 1                  ║
        ║     var person = Person()  ← RC увеличился    ║
        ║                                               ║
        ║  2️⃣ Удалили ссылку → RC - 1                  ║
        ║     person = nil  ← RC уменьшился             ║
        ║     Или выход из scope                        ║
        ║                                               ║
        ║  3️⃣ RC = 0 → объект удаляется                ║
        ║     deinit вызывается автоматически           ║
        ║                                               ║
        ╚═══════════════════════════════════════════════╝
        """, level: .info)

        ConsoleLogger.note("""
        По умолчанию все ссылки — STRONG.
        Strong ссылка увеличивает счетчик.
        Пока есть хотя бы одна strong ссылка, объект живет.
        """)
    }
}

// MARK: - Как использовать

/*
 В ViewController.swift раскомментируй:

 ReferenceCountingDemo.runReferenceCountingDemo()

 Ожидаемый вывод:

 ═══════════════════════════════════════════════════════════
 📍 REFERENCE COUNTING DEMO
 ───────────────────────────────────────────────────────────

 --- Пример 1: Одна ссылка ---

 ──────────────────────────────────────────────────────────
 ▶️  Шаг 1: var user = User("Alex")
 ──────────────────────────────────────────────────────────
 💡 Создаем объект и присваиваем переменной
 ──────────────────────────────────────────────────────────

 ✅ User #1 'Alex' создан | ObjectID: ... | Всего в памяти: 1

 ▶️  Шаг 2: user = nil
 ℹ️ User #1 'Alex' удален | Осталось в памяти: 0

 🎯 ВЫВОД: Когда единственная ссылка исчезает → RC = 0...

 --- Пример 2: Несколько ссылок на один объект ---
 ✅ User #2 'Bob' создан | ObjectID: ... | Всего в памяти: 1

 ℹ️ user1 = nil, объект все еще жив (RC = 2)
 ℹ️ user2 = nil, объект все еще жив (RC = 1)
 ℹ️ User #2 'Bob' удален | Осталось в памяти: 0

 ⏱️  TIMELINE:
 [0.000] ▶️ Создаем первую ссылку
 [0.001] ▶️ Создаем вторую ссылку
 ...

 --- Пример 3: Автоматическое удаление при выходе из scope ---
 ✅ User #3 'Charlie' создан | ObjectID: ... | Всего в памяти: 1
 ℹ️ User #3 'Charlie' удален | Осталось в памяти: 0

 --- Три правила ARC ---
 ╔═══════════════════════════════════════════════╗
 ║           ТРИ ПРАВИЛА ARC                     ║
 ...

 📊 СВОДКА ПО ОБЪЕКТАМ
 ───────────────────────────────────────────────────────────
 ✅ User: 0 объектов (OK)
 ═══════════════════════════════════════════════════════════
 */
