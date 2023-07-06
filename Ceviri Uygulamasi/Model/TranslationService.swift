//
//  TranslationService.swift
//  Ceviri Uygulamasi
//
//  Created by Yunus Emre ÖZŞAHİN on 6.07.2023.
//

import Foundation

class TranslationService {
    static func performTranslation(currentLanguageCode: String, targetLanguageCode: String, apiKey: String, sourceText: String, completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let source = "\(currentLanguageCode)"
        let target = "\(targetLanguageCode)"
        let encodedSourceText = sourceText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let postString = "q=\(encodedSourceText)&target=\(target)&source=\(source)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let responseData = json?["data"] as? [String: Any], let translations = responseData["translations"] as? [[String: Any]], let translatedText = translations.first?["translatedText"] as? String {
                    let decodedTranslatedText = translatedText.htmlDecoded()
                    completion(decodedTranslatedText, nil)
                } else {
                    completion(nil, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}

