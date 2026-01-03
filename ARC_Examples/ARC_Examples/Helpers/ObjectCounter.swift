//
//  ObjectCounter.swift
//  ARC_Examples
//
//  Created by Menkov Dmitriy on 03.01.2026.
//

import Foundation

/// Класс для подсчета живых объектов каждого типа
/// Позволяет отслеживать утечки памяти
class ObjectCounter {

    // MARK: - Хранилище счетчиков

    /// Словарь: тип объекта -> количество живых экземпляров
    private static var counters: [String: Int] = [:]

    /// Lock для thread-safety (на случай многопоточности)
    private static let lock = NSLock()

    // MARK: - Публичные методы

    /// Увеличивает счетчик для типа объекта
    /// - Parameter type: Название типа (например, "Person", "CreditCard")
    /// - Returns: Новое количество живых объектов этого типа
    @discardableResult
    static func increment(_ type: String) -> Int {
        lock.lock()
        defer { lock.unlock() }

        counters[type, default: 0] += 1
        return counters[type]!
    }

    /// Уменьшает счетчик для типа объекта
    /// - Parameter type: Название типа
    /// - Returns: Новое количество живых объектов этого типа
    @discardableResult
    static func decrement(_ type: String) -> Int {
        lock.lock()
        defer { lock.unlock() }

        counters[type, default: 0] -= 1
        return counters[type]!
    }

    /// Получает текущее количество живых объектов
    /// - Parameter type: Название типа
    /// - Returns: Количество живых объектов
    static func count(for type: String) -> Int {
        lock.lock()
        defer { lock.unlock() }

        return counters[type, default: 0]
    }

    /// Сбрасывает счетчик для типа
    /// - Parameter type: Название типа
    static func reset(_ type: String) {
        lock.lock()
        defer { lock.unlock() }

        counters[type] = 0
    }

    /// Сбрасывает все счетчики
    static func resetAll() {
        lock.lock()
        defer { lock.unlock() }

        counters.removeAll()
    }

    // MARK: - Печать сводки

    /// Печатает сводку по всем объектам
    static func printSummary(title: String = "СВОДКА ПО ОБЪЕКТАМ") {
        lock.lock()
        let snapshot = counters
        lock.unlock()

        print("\n" + String(repeating: "═", count: 60))
        print("📊 \(title)")
        print(String(repeating: "─", count: 60))

        if snapshot.isEmpty {
            print("   (нет отслеживаемых объектов)")
        } else {
            // Сортируем по имени типа для стабильного вывода
            let sorted = snapshot.sorted { $0.key < $1.key }

            for (type, count) in sorted {
                let emoji = count > 0 ? "⚠️" : "✅"
                let status = count > 0 ? "УТЕЧКА" : "OK"
                print("   \(emoji) \(type): \(count) объектов (\(status))")
            }
        }

        print(String(repeating: "═", count: 60) + "\n")
    }

    /// Проверяет есть ли утечки памяти
    /// - Returns: true если есть объекты с count > 0
    static func hasLeaks() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        return counters.values.contains { $0 > 0 }
    }

    /// Печатает только утечки (count > 0)
    static func printLeaksOnly() {
        lock.lock()
        let snapshot = counters.filter { $0.value > 0 }
        lock.unlock()

        print("\n" + String(repeating: "═", count: 60))
        print("⚠️  ОБНАРУЖЕННЫЕ УТЕЧКИ ПАМЯТИ")
        print(String(repeating: "─", count: 60))

        if snapshot.isEmpty {
            print("   ✅ Утечек не обнаружено")
        } else {
            let sorted = snapshot.sorted { $0.key < $1.key }

            for (type, count) in sorted {
                print("   💀 \(type): \(count) объектов не удалено")
            }
        }

        print(String(repeating: "═", count: 60) + "\n")
    }
}

// MARK: - Расширение для удобства использования

extension ObjectCounter {

    /// Удобный helper для инкремента с логированием
    static func incrementWithLog(_ type: String, name: String) -> Int {
        let count = increment(type)
        ConsoleLogger.log("\(type) '\(name)' создан | Всего в памяти: \(count)", level: .success)
        return count
    }

    /// Удобный helper для декремента с логированием
    static func decrementWithLog(_ type: String, name: String) -> Int {
        let count = decrement(type)
        ConsoleLogger.log("\(type) '\(name)' удален | Осталось в памяти: \(count)", level: .info)
        return count
    }
}

// MARK: - Примеры использования (для справки)

/*
 ПРИМЕР 1: Базовое использование

 class Person {
     let name: String

     init(name: String) {
         self.name = name
         ObjectCounter.increment("Person")
         print("✅ Person создан | Всего: \(ObjectCounter.count(for: "Person"))")
     }

     deinit {
         ObjectCounter.decrement("Person")
         print("❌ Person удален | Осталось: \(ObjectCounter.count(for: "Person"))")
     }
 }


 ПРИМЕР 2: С логированием

 class CreditCard {
     let number: String

     init(number: String) {
         self.number = number
         ObjectCounter.incrementWithLog("CreditCard", name: number)
     }

     deinit {
         ObjectCounter.decrementWithLog("CreditCard", name: number)
     }
 }


 ПРИМЕР 3: Проверка утечек

 func testMemoryLeaks() {
     // ... создаем объекты ...

     ObjectCounter.printSummary()

     if ObjectCounter.hasLeaks() {
         print("⚠️ ОБНАРУЖЕНЫ УТЕЧКИ!")
         ObjectCounter.printLeaksOnly()
     }
 }
 */
