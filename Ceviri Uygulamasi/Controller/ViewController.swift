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
    }

    
    
    @IBAction func translateButtonTapped(_ sender: Any) {
        guard let currentLanguageCode = languages.first(where: { $0.name == yourLanguage.text })?.code else {
            print("Invalid current language")
            showAlert(message: "Invalid current language")
            return
        }
        
        guard let targetLanguageCode = languages.first(where: { $0.name == targetLanguage.text })?.code else {
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
}

   extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate{
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
       
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return languages.count
        }
        
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if yourLanguage.isEditing{
                return languages[row].nativeName
            }else{
                return languages[row].name
            }
            
        }
        
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
               
               pickerView?.resignFirstResponder()
           }
       func showAlert(message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
    }
