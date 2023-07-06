//
//  Extensions.swift
//  Ceviri Uygulamasi
//
//  Created by Yunus Emre ÖZŞAHİN on 6.07.2023.
//
import Foundation
import UIKit

//MARK: - Conversion function to properly display the characters from the api to the user.
extension String {
    func htmlDecoded() -> String {
        guard let data = data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        } else {
            return self
        }
    }
}
//MARK: - In the Detect process, we run the function after the user has written at least 5 characters.
extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
        let minimumCharacterCount = 5
        
        if characterCount >= minimumCharacterCount {
            detectLanguage(text: textView.text, apiKey: apiKey) { (language, error) in
                if let error = error {
                    print("Hata: \(error)")
                } else if let language = language {
                    DispatchQueue.main.async {
                        if let languageName = LanguageManager.getLanguageName(for: language) {
                            self.yourLanguage.text = languageName
                        } else {
                            print("Language with code '\(language)' was not found.")
                        }
                    }
                } else {
                    print("Dil algılanamadı.")
                }
            }
        }
    }
}
