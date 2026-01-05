//
//  MemoryLayoutDemo.swift
//  ARC_Examples
//
//  Created by Menkov Dmitriy on 03.01.2026.
//

import Foundation

class Video01_MinimalDemo {
    static func runForVideo() {
        ConsoleLogger.section("TAGGED POINTERS НА ARM64")
        demonstrateTaggedPointers()
    }

    private static func demonstrateTaggedPointers() {
        let small = NSNumber(value: 42)
        let large = NSNumber(value: Int64.max)

        checkTagged(small, "NSNumber(42)")
        checkTagged(large, "NSNumber(Int64.max)")
    }

    private static func checkTagged(_ obj: NSObject, _ name: String) {
        let ptr = Unmanaged.passUnretained(obj).toOpaque()
        let addr = UInt(bitPattern: ptr)
        let isTagged = (addr & 0x8000000000000000) != 0

        if isTagged {
            ConsoleLogger.log("""
            ✅ \(name): TAGGED POINTER
               └─ Адрес: \(String(format: "0x%016llX", addr))
               └─ Старший бит (bit 63) = 1
               └─ Значение закодировано В указателе
               └─ НЕТ аллокации в Heap ⚡
            """, level: .success)
        } else {
            ConsoleLogger.log("""
            ℹ️ \(name): Обычный объект в Heap
               └─ Адрес: \(String(format: "0x%016llX", addr))
               └─ Старший бит (bit 63) = 0
               └─ Объект выделен в памяти
               └─ Требует ARC для управления
            """, level: .info)
        }
    }
}
