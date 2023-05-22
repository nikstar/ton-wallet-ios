//
//  File.swift
//  
//
//  Created by nikstar on 22.05.2023.
//

import Foundation


final class AppStorage {
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func get<T: Codable>(_ key: String, ofType: T.Type = T.self, default: T) -> T {
        return _get(key: key, type: T.self) ?? `default`
    }
    
    func get<T: Codable>(_ key: String, ofType: T.Type = T.self, orThrow: @autoclosure () -> Error) throws -> T {
        if let value = _get(key: key, type: T.self) {
            return value
        }
        throw orThrow()
    }
    
    func getOptional<T: Codable>(_ key: String, ofType: T.Type = T.self, default: T) -> T? {
        return _get(key: key, type: T.self)
    }
    
    private func _get<T: Codable>(key: String, type: T.Type) -> T? {
        if let string = UserDefaults.standard.string(forKey: key), let data = string.data(using: .utf8), let value = try? decoder.decode(T.self, from: data) {
            return value
        }
        return nil
    }
    
    func set<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? encoder.encode(value), let string = String(data: data, encoding: .utf8) {
            UserDefaults.standard.set(string, forKey: key)
        }
    }

    func delete(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func removeAll() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }
    }
}



typealias AppCache = AppStorage
