//
//  ARCVisualizer.swift
//  ARC_Examples
//
//  Created by Menkov Dmitriy on 03.01.2026.
//

import Foundation

/// Класс для визуализации графов зависимостей и таймлайнов
/// БЕЗ фейкового Reference Count (т.к. его нельзя получить в Swift)
class ARCVisualizer {

    // MARK: - Граф зависимостей (концептуальный)

    /// Печатает концептуальный граф зависимостей между объектами
    /// - Parameters:
    ///   - title: Заголовок графа
    ///   - nodes: Узлы графа (объекты)
    ///   - edges: Ребра графа (ссылки между объектами)
    static func printGraph(
        title: String,
        nodes: [String],
        edges: [(from: String, to: String, type: ReferenceType)]
    ) {
        print("\n" + String(repeating: "═", count: 60))
        print("📊 \(title)")
        print(String(repeating: "═", count: 60))

        // Печатаем узлы
        print("\n🔷 Объекты:")
        for node in nodes {
            print("   • \(node)")
        }

        // Печатаем ребра (связи)
        print("\n🔗 Связи:")
        for edge in edges {
            let arrow = edge.type.arrow
            print("   \(edge.from) \(arrow) \(edge.to)")
        }

        print(String(repeating: "═", count: 60) + "\n")
    }

    /// Печатает ASCII-граф для retain cycle
    static func printRetainCycleGraph(object1: String, object2: String, hasCycle: Bool) {
        print("\n" + String(repeating: "═", count: 60))
        if hasCycle {
            print("❌ RETAIN CYCLE DETECTED")
        } else {
            print("✅ NO RETAIN CYCLE")
        }
        print(String(repeating: "═", count: 60))

        if hasCycle {
            // Цикл: оба держат strong
            print("""
            
            \(object1) ──strong──> \(object2)
                ↑                    │
                │                    │
                └────strong──────────┘
            
            ⚠️  Оба объекта держат друг друга strongly
            💀 Даже без внешних ссылок они не удалятся
            """)
        } else {
            // Без цикла: один держит weak
            print("""
            
            \(object1) ──strong──> \(object2)
                ↑                    │
                │                    │
                └────weak────────────┘
            
            ✅ weak ссылка не создает цикл
            🎯 Объекты удалятся правильно
            """)
        }

        print(String(repeating: "═", count: 60) + "\n")
    }

    // MARK: - Timeline (таймлайн событий)

    private static var timelineStartTime: Date?
    private static var timelineEvents: [(time: TimeInterval, event: String)] = []

    /// Начинает новый таймлайн
    static func startTimeline() {
        timelineStartTime = Date()
        timelineEvents = []
    }

    /// Добавляет событие в таймлайн
    static func logEvent(_ event: String) {
        guard let startTime = timelineStartTime else {
            print("⚠️ Timeline не запущен. Вызовите startTimeline() сначала.")
            return
        }

        let elapsed = Date().timeIntervalSince(startTime)
        timelineEvents.append((time: elapsed, event: event))
    }

    /// Печатает весь таймлайн
    static func printTimeline(title: String = "TIMELINE") {
        print("\n" + String(repeating: "═", count: 60))
        print("⏱️  \(title)")
        print(String(repeating: "─", count: 60))

        if timelineEvents.isEmpty {
            print("   (нет событий)")
        } else {
            for event in timelineEvents {
                let timeStr = String(format: "[%06.3f]", event.time)
                print("   \(timeStr) \(event.event)")
            }
        }

        print(String(repeating: "═", count: 60) + "\n")
    }

    // MARK: - Step-by-Step визуализация

    /// Печатает пошаговое выполнение с визуализацией
    static func printStep(
        number: Int,
        code: String,
        description: String,
        objectsAlive: [String]
    ) {
        print("\n" + String(repeating: "─", count: 60))
        print("▶️  Шаг \(number): \(code)")
        print(String(repeating: "─", count: 60))
        print("💡 \(description)")

        if !objectsAlive.isEmpty {
            print("\n📦 Объекты в памяти:")
            for obj in objectsAlive {
                print("   ✅ \(obj)")
            }
        } else {
            print("\n📦 Объектов в памяти: нет")
        }

        print(String(repeating: "─", count: 60))
    }

    // MARK: - До/После сравнение

    /// Печатает сравнение "До" и "После"
    static func printBeforeAfter(
        title: String,
        before: String,
        after: String,
        beforeObjects: [String],
        afterObjects: [String]
    ) {
        print("\n" + String(repeating: "═", count: 60))
        print("🔄 \(title)")
        print(String(repeating: "═", count: 60))

        // До
        print("\n❌ ДО (\(before)):")
        print(String(repeating: "─", count: 60))
        if !beforeObjects.isEmpty {
            for obj in beforeObjects {
                print("   💀 \(obj) - ЖИВ (утечка)")
            }
        } else {
            print("   (объектов нет)")
        }

        // После
        print("\n✅ ПОСЛЕ (\(after)):")
        print(String(repeating: "─", count: 60))
        if !afterObjects.isEmpty {
            for obj in afterObjects {
                print("   💀 \(obj) - ЖИВ (утечка)")
            }
        } else {
            print("   ✅ Все объекты удалены")
        }

        print(String(repeating: "═", count: 60) + "\n")
    }

    // MARK: - Концептуальная визуализация состояния памяти

    /// Печатает концептуальное состояние памяти
    static func printMemoryState(
        title: String,
        objects: [(name: String, isAlive: Bool, heldBy: [String])]
    ) {
        print("\n" + String(repeating: "═", count: 60))
        print("🧠 \(title)")
        print(String(repeating: "═", count: 60))

        for obj in objects {
            let status = obj.isAlive ? "✅ ЖИВ" : "❌ УДАЛЕН"
            print("\n📦 \(obj.name): \(status)")

            if !obj.heldBy.isEmpty {
                print("   Удерживается:")
                for holder in obj.heldBy {
                    print("      • \(holder)")
                }
            } else if obj.isAlive {
                print("   ⚠️  Никто не держит, но жив (утечка!)")
            }
        }

        print(String(repeating: "═", count: 60) + "\n")
    }

    // MARK: - Вспомогательные функции

    /// Печатает разделитель секции
    static func printSectionHeader(_ title: String) {
        print("\n" + String(repeating: "═", count: 60))
        print("📍 \(title)")
        print(String(repeating: "─", count: 60))
    }

    /// Печатает подсекцию
    static func printSubsection(_ title: String) {
        print("\n--- \(title) ---")
    }
}

// MARK: - Типы ссылок

/// Тип ссылки для визуализации
enum ReferenceType {
    case strong
    case weak
    case unowned

    var arrow: String {
        switch self {
        case .strong:
            return "──strong──>"
        case .weak:
            return "──weak────>"
        case .unowned:
            return "──unowned─>"
        }
    }
}

// MARK: - Примеры использования (для справки)

/*
 ПРИМЕР 1: Граф зависимостей

 ARCVisualizer.printGraph(
     title: "Person и CreditCard",
     nodes: ["Person", "CreditCard"],
     edges: [
         (from: "Person", to: "CreditCard", type: .strong),
         (from: "CreditCard", to: "Person", type: .weak)
     ]
 )


 ПРИМЕР 2: Timeline

 ARCVisualizer.startTimeline()
 ARCVisualizer.logEvent("✅ Person создан")
 ARCVisualizer.logEvent("✅ CreditCard создан")
 ARCVisualizer.logEvent("❌ Person удален")
 ARCVisualizer.printTimeline(title: "Жизненный цикл объектов")


 ПРИМЕР 3: Пошаговая визуализация

 ARCVisualizer.printStep(
     number: 1,
     code: "var person = Person()",
     description: "Создаем объект Person",
     objectsAlive: ["Person('Alex')"]
 )


 ПРИМЕР 4: До/После

 ARCVisualizer.printBeforeAfter(
     title: "Исправление Retain Cycle",
     before: "Strong ссылка",
     after: "Weak ссылка",
     beforeObjects: ["Person", "CreditCard"],
     afterObjects: []
 )
 */
