//
//  LanguageManager.swift
//  Ceviri Uygulamasi
//
//  Created by Yunus Emre ÖZŞAHİN on 3.07.2023.
//

import Foundation

struct Language: Codable {
    let code: String
    let name: String
    let nativeName: String
}

struct LanguageList: Codable {
    let languages: [Language]
}

class LanguageManager {
    static func getLanguageName(for code: String) -> String? {
            guard let path = Bundle.main.path(forResource: "Languages", ofType: "json") else {
                print("Language list JSON file not found.")
                return nil
            }
            
            do {
                let url = URL(fileURLWithPath: path)
                let jsonData = try Data(contentsOf: url)
                let languageList = try JSONDecoder().decode(LanguageList.self, from: jsonData)
                
                if let language = languageList.languages.first(where: { $0.code == code }) {
                    return language.name
                } else {
                    print("Language with code '\(code)' was not found.")
                    return nil
                }
            } catch {
                print("Error decoding language list JSON: \(error)")
                return nil
            }
        }
    
    static func getLanguages() -> [Language] {
        guard let path = Bundle.main.path(forResource: "Languages", ofType: "json") else {
                    print("Language list JSON file not found.")
                    return []
                }
        do {
            let url = URL(fileURLWithPath: path)
            let jsonData = try Data(contentsOf: url)
            let languageList = try JSONDecoder().decode(LanguageList.self, from: jsonData)
            return languageList.languages
        } catch {
            print("Hata oluştu: \(error)")
            return []
        }
    }
    
}
