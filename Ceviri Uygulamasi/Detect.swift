//
//  Detect.swift
//  Ceviri Uygulamasi
//
//  Created by Yunus Emre ÖZŞAHİN on 5.07.2023.
//

import Foundation

struct DetectLanguageResponse: Codable {
    let data: LanguageDetectionData
}

struct LanguageDetection: Codable {
    let language: String
    let isReliable: Bool?
    let confidence: Float?
}
struct LanguageDetectionData: Codable {
    let detections: [[LanguageDetection]]
}
func detectLanguage(text: String, apiKey: String, completion: @escaping (String?, Error?) -> Void) {
    let url = URL(string: "https://translation.googleapis.com/language/translate/v2/detect")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let parameters: [String: Any] = [
        "q": text,
        "key": apiKey
    ]
    
    let parameterString = parameters.map { (key, value) in
        return "\(key)=\(value)"
    }.joined(separator: "&")
    
    request.httpBody = parameterString.data(using: .utf8)
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completion(nil, error)
            return
        }
        
        if let data = data {
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(DetectLanguageResponse.self, from: data)
                if let firstDetection = response.data.detections.first?.first {
                    completion(firstDetection.language, nil)
                } else {
                    completion(nil, nil)
                }
            } catch {
                completion(nil, error)
            }
        } else {
            completion(nil, nil)
        }
    }
    
    task.resume()
}
