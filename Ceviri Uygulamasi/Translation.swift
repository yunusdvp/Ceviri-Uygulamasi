//
//  Translation.swift
//  Ceviri Uygulamasi
//
//  Created by Yunus Emre ÖZŞAHİN on 4.07.2023.
//

import Foundation

func translateText(sourceText: String, targetLanguage: String, completionHandler: @escaping (Result<String, Error>) -> Void) {
    let baseURL = "https://translate.googleapis.com/v3/projects/{pure-coda-391706}:translateText"  // {YOUR_PROJECT_ID} kısmını kendi Google Cloud projenizin ID'si ile değiştirin
    let url = URL(string: baseURL)!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // İstek verilerini oluşturma
    let requestBody: [String: Any] = [
        "contents": [sourceText],
        "targetLanguageCode": targetLanguage,
        "sourceLanguageCode": "", // Kaynak dilin otomatik tespit edilmesini isterseniz boş bırakın
        // Diğer isteğe bağlı parametreleri de burada belirtebilirsiniz
    ]
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = jsonData
    } catch {
        completionHandler(.failure(error))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completionHandler(.failure(error))
            return
        }
        
        guard let data = data else {
            completionHandler(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            return
        }
        
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            // Yanıtı işleyerek çevrilen metni alın
            if let translations = jsonResponse?["translations"] as? [[String: Any]],
               let translatedText = translations.first?["translatedText"] as? String {
                completionHandler(.success(translatedText))
            } else {
                completionHandler(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            }
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    task.resume()
}
