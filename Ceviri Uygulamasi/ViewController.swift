//
//  ViewController.swift
//  Ceviri Uygulamasi
//
//  Created by Yunus Emre ÖZŞAHİN on 3.07.2023.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    //MARK: - VARİABLES

    var languages : [Language] = []
    let apiKey = "AIzaSyBUDztX1IOEsCWJbP4DqwOcw_BuYTmabTQ"
    var pickerView: UIPickerView?
    
    @IBOutlet weak var yourLanguage: UITextField!
    
    @IBOutlet weak var currentText: UITextView!
    
    @IBOutlet weak var targetLanguage: UITextField!
    @IBOutlet weak var TargetText: UITextView!
    //MARK: - FUNCTİONS
    override func viewDidLoad() {
        super.viewDidLoad()
        languages = LanguageManager.getLanguages()
        for language in languages {
            print("Language: \(language.name), Code: \(language.code), Native Name: \(language.nativeName)")
            
            
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
            self.view.addGestureRecognizer(tapGesture)
        pickerView = UIPickerView()
        print(languages.count)
        pickerView?.delegate = self
        pickerView?.dataSource = self
        currentText.delegate = self
        yourLanguage.inputView = pickerView
        targetLanguage.inputView = pickerView
        let toolbar = UIToolbar()
        toolbar.tintColor = UIColor.red
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelClicked))
        let okButton = UIBarButtonItem(title: "Ok", style: .plain, target: self, action: #selector(self.okClicked))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(self.okClicked))
        
        
        toolbar.setItems([cancelButton,space,okButton], animated: true)
        yourLanguage.inputAccessoryView = toolbar
        targetLanguage.inputAccessoryView = toolbar
        detectLanguage(text: "Merhaba, nasılsınız?", apiKey: "AIzaSyBUDztX1IOEsCWJbP4DqwOcw_BuYTmabTQ") { (language, error) in
            if let error = error {
                print("Hata: \(error)")
            } else if let language = language {
                print("Algılanan Dil: \(language)")
            } else {
                print("Dil algılanamadı.")
            }
        }

    }


    @IBAction func translateButtonTapped(_ sender: Any) {
        guard let currentLanguageCode = languages.first(where: { $0.name == yourLanguage.text })?.code else {
                print("Invalid current language")
                return
            }
            
            guard let targetLanguageCode = languages.first(where: { $0.name == targetLanguage.text })?.code else {
                print("Invalid target language")
                return
            }
            
            if apiKey.isEmpty {
                print("API key is missing")
                return
            }
            
            let sourceText = currentText.text ?? ""
            
            // Çeviri için API isteğini oluştur
            let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let source = "\(currentLanguageCode)"
            let target = "\(targetLanguageCode)"
            let encodedSourceText = sourceText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            let postString = "q=\(encodedSourceText)&target=\(target)&source=\(source)"
            request.httpBody = postString.data(using: .utf8)
            
            // API isteğini gerçekleştir
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // API yanıtını çözümle
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let responseData = json?["data"] as? [String: Any], let translations = responseData["translations"] as? [[String: Any]], let translatedText = translations.first?["translatedText"] as? String {
                        DispatchQueue.main.async {
                            let decodedTranslatedText = translatedText.htmlDecoded()
                            self.TargetText.text = decodedTranslatedText
                        }
                    }
                } catch {
                    print("Error parsing response: \(error.localizedDescription)")
                }
            }
            
            task.resume()
        }
}

   extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate{
        // PickerView'da gösterilecek toplam bileşen sayısını döndürün
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        // PickerView'daki toplam satır sayısını döndürün
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return languages.count
        }
        
        // PickerView'da belirli bir satır için görüntülenecek metni döndürün
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if yourLanguage.isEditing{
                return languages[row].nativeName
            }else{
                return languages[row].name
            }
            
        }
        
        // Kullanıcının seçtiği satırı işleyin
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if yourLanguage.isEditing{
                let selectedCurrentLanguage = languages[row]
                    yourLanguage.text = languages[row].name
            }else{
                let selectedTargetLanguage = languages[row]
                    targetLanguage.text = languages[row].name
                
            }
             
         
        }

       @objc func okClicked(){
           view.endEditing(true)
           
       }
       @objc func cancelClicked(){
           if yourLanguage.isEditing{
               yourLanguage.text = ""
               yourLanguage.placeholder = " Your Language"
           }else{
               targetLanguage.text = ""
               yourLanguage.placeholder = " Target Language"
           }
           
       }
       @objc func handleTap(sender: UIControl) {
           view.endEditing(true)
           if yourLanguage.isEditing{
               yourLanguage.resignFirstResponder()
           }else{
               targetLanguage.resignFirstResponder()
           }
               // yourLanguage alanını düzenleme modundan çıkarır
               pickerView?.resignFirstResponder() // PickerView'i kapatır
           }
    }
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
                        //self.yourLanguage.text = language
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


    

