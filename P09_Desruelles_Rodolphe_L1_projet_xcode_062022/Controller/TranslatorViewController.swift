//
//  TranslatorViewController.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 04/07/2022.
//

import UIKit

struct Language {
    let name: String
    let symbol: String
}

class TranslatorViewController: UIViewController, UITextViewDelegate {
    var sourceTextViewPlaceholderDisplayed: Bool!
    let placeHolderText = "Tapez un texte"

    var sourceLanguage = Language(name: "Français", symbol: "fr")
    var targetLanguage = Language(name: "Anglais", symbol: "en")

    // Model interface //

    let translationLoader = APIRequestLoader(apiRequest: TranslationRequest())

    // View Components //

    @IBOutlet var sourceLanguageLabel: UILabel!
    @IBOutlet var targetLanguageLabel: UILabel!
    
    @IBOutlet var sourceTextView: UITextView!
    @IBOutlet var targetTextView: UITextView!
    
    @IBOutlet var translateButton: UIButton!

    let translationLoadingFailureAlert = ControllerHelper.simpleAlert(message: "Impossible de récupérer la traduction.")

    // Events //

    @IBAction func translateButtonTapped() {
        print("translateButtonTapped")
        guard !sourceTextView.text.isEmpty, !sourceTextViewPlaceholderDisplayed else { return }

        updateTargetTextViewTranslation()
    }

    @IBAction func languageSwitchButton(_ sender: UIButton) {
        switchLanguages()
    }

    // UITextViewDelegate (for TextView placeholder and translate button states)

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard textView == sourceTextView else { return true }

        if sourceTextViewPlaceholderDisplayed {
            hideSourceTextViewPlaceholder()
        }

        updateTranslateButtonState()

        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == sourceTextView else { return }

        if sourceTextView.text.isEmpty {
            displaySourceTextViewPlaceholder()
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        guard textView == sourceTextView else { return }

        if sourceTextViewPlaceholderDisplayed {
            hideSourceTextViewPlaceholder()
        }
        
        updateTranslateButtonState()
    }

    // Keyboard management

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    private func initHideKeyboardEvent() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        view.addGestureRecognizer(tap)
    }

    // Logic //

    func switchLanguages() {
        (sourceLanguage, targetLanguage) = (targetLanguage, sourceLanguage)
        initInterface()
    }

    func updateTargetTextViewTranslation() {
        translateButton.isEnabled = false
        
        let requestInputData = TranslationRequestInputData(
            targetLanguage: targetLanguage.symbol,
            sourceLanguage: sourceLanguage.symbol,
            text: sourceTextView.text ?? ""
        )

//        print("Load - \(requestInputData)")

        translationLoader.load(requestInputData: requestInputData) {
            result in
            DispatchQueue.main.async {
                self.translateButton.isEnabled = true

                guard let result = result else {
                    return self.present(self.translationLoadingFailureAlert, animated: true, completion: nil)
                }

//                print("Load Result- \(result)")

                self.targetTextView.text = result[0].translations[0].text
            }
        }
    }

    func hideSourceTextViewPlaceholder() {
        sourceTextView.textColor = UIColor.darkText
        sourceTextView.text.removeFirst(placeHolderText.count)
        sourceTextViewPlaceholderDisplayed = false
    }

    func displaySourceTextViewPlaceholder() {
        sourceTextViewPlaceholderDisplayed = true
        sourceTextView.textColor = UIColor.lightGray
        sourceTextView.text = placeHolderText
    }

    func updateTranslateButtonState() {
        translateButton.isEnabled = !sourceTextView.text.isEmpty && !sourceTextViewPlaceholderDisplayed
        
//        print("Translate button enabled = \(translateButton.isEnabled)")
    }

    func setupDesign() {
        sourceTextView.layer.borderWidth = 0.5
        sourceTextView.layer.borderColor = UIColor.lightGray.cgColor

        translateButton.layer.cornerRadius = 10.0
        translateButton.clipsToBounds = true
    }

    func initInterface() {
        translateButton.isEnabled = false

        displaySourceTextViewPlaceholder()
        targetTextView.text = ""

        sourceLanguageLabel.text = sourceLanguage.name
        targetLanguageLabel.text = targetLanguage.name
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sourceTextView.delegate = self

        initHideKeyboardEvent()

        setupDesign()

        initInterface()
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
