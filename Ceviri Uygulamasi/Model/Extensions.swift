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
//MARK: - In the detection process and to start automatic translation, we run the function after the user has typed at least 5 characters.
extension ViewController: UITextViewDelegate {
    func translateText() {
        guard let currentLanguage = yourLanguage.text, !currentLanguage.isEmpty else {
            print("Your language is empty")
            showAlert(message: "Please select your language")
            return
        }
        
        guard let targetLanguage = targetLanguage.text, !targetLanguage.isEmpty else {
            print("Target language is empty")
            showAlert(message: "Please select target language")
            return
        }
        
        guard let currentLanguageCode = languages.first(where: { $0.name == currentLanguage })?.code else {
            print("Invalid current language")
            showAlert(message: "Invalid current language")
            return
        }
        
        guard let targetLanguageCode = languages.first(where: { $0.name == targetLanguage })?.code else {
            print("Invalid target language")
            showAlert(message: "Invalid target language")
            return
        }
        
        if apiKey.isEmpty {
            print("API key is missing")
            return
        }
        
        let sourceText = currentText.text ?? ""
        
        TranslationService.performTranslation(currentLanguageCode: currentLanguageCode, targetLanguageCode: targetLanguageCode, apiKey: apiKey, sourceText: sourceText) { (translatedText, error) in
            if let translatedText = translatedText {
                DispatchQueue.main.async {
                    self.TargetText.text = translatedText
                }
            } else if let error = error {
                print("Translation error: \(error.localizedDescription)")
            } else {
                print("Translation failed with unknown error")
            }
        }
    }
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
                            
                            self.translateText() // Çeviri işlemini burada tetikleyin
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
