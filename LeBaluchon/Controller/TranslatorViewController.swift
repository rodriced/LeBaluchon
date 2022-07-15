//
//  TranslatorViewController.swift
//  LeBaluchon
//
//  Created by Rodolphe Desruelles on 04/07/2022.
//

import UIKit

struct Language {
    let name: String
    let symbol: String
}

class TranslatorViewController: UIViewController, UITextViewDelegate {
    var sourceLanguage = Language(name: "Français", symbol: "fr")
    var targetLanguage = Language(name: "Anglais", symbol: "en")

    // Model //
    // -------//

    let translationLoader = APIRequestLoader(apiRequest: TranslationRequest())

    // View Components //
    // -----------------//

    @IBOutlet var sourceLanguageLabel: UILabel!
    @IBOutlet var targetLanguageLabel: UILabel!

    @IBOutlet var sourceTextView: UITextView!
    @IBOutlet var targetTextView: UITextView!

    @IBOutlet var translateButton: UIButton!

    let translationLoadingFailureAlert = ControllerHelper.simpleAlert(message: "Impossible de récupérer la traduction.")

    // Events //
    // --------//

    @IBAction func translateButtonTapped() {
//        print("translateButtonTapped")
        updateTargetTextView()
    }

    @IBAction func languageSwitchButton(_ sender: UIButton) {
        switchLanguages()
    }

    // Keyboard management

    private func initGestureForLeavingEditMode() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(leaveEditMode)
        )
        view.addGestureRecognizer(tap)
    }

    @objc func leaveEditMode() {
        view.endEditing(true)
    }

    // UITextViewDelegate protocol implementation
    // for sourceTextView placeholder and translate button states management

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard textView == sourceTextView else { return true }

        if sourceTextViewPlaceholderIsDisplayed {
            hideSourceTextViewPlaceholder()
        }
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

        if sourceTextViewPlaceholderIsDisplayed {
            hideSourceTextViewPlaceholder()
        }

//        updateTranslateButtonState()
        translateButton.isEnabled = sourceTextViewContainsTypedText
    }

    // sourceTextView Placeholder Management Logic

    let placeHolderText = "Tapez un texte"

    var sourceTextViewPlaceholderIsDisplayed: Bool!
    var sourceTextViewContainsTypedText: Bool {
        !sourceTextView.text.isEmpty && !sourceTextViewPlaceholderIsDisplayed
    }

    func hideSourceTextViewPlaceholder() {
        sourceTextView.textColor = UIColor.darkText
        sourceTextView.text.removeFirst(placeHolderText.count)
        sourceTextViewPlaceholderIsDisplayed = false
    }

    func displaySourceTextViewPlaceholder() {
        sourceTextViewPlaceholderIsDisplayed = true
        sourceTextView.textColor = UIColor.lightGray
        sourceTextView.text = placeHolderText
    }

    // Logic //
    // -------//

    func switchLanguages() {
        (sourceLanguage, targetLanguage) = (targetLanguage, sourceLanguage)
        initInterface()
        leaveEditMode()
//        sourceTextView.endEditing(true)
    }

//    func translate() {
//        guard sourceTextViewContainsTypedText else { return }
//
//        leaveEditMode()
//        updateTargetTextView()
//    }
//

//    func loadTranslation(completionHandler: @escaping (String?) -> Void) {
//        let requestInputData = TranslationRequestInputData(
//            targetLanguage: targetLanguage.symbol,
//            sourceLanguage: sourceLanguage.symbol,
//            text: sourceTextView.text ?? ""
//        )
//
//        translationLoader.load(requestInputData: requestInputData) {
//            result in
//            result.map { completionHandler($0[0].translations[0].text) }
////            completionHandler(result[0].translations[0].text)
//        }
//    }

    func updateTargetTextView() {
        leaveEditMode()
        translateButton.isEnabled = false

        let requestInputData = TranslationRequestInputData(
            targetLanguage: targetLanguage.symbol,
            sourceLanguage: sourceLanguage.symbol,
            text: sourceTextView.text ?? ""
        )

//        print("Load - \(requestInputData)")

        translationLoader.load(requestInputData) {
            translatedText in
            DispatchQueue.main.async {
                self.translateButton.isEnabled = true

                guard let translatedText = translatedText else {
                    return self.present(self.translationLoadingFailureAlert, animated: true, completion: nil)
                }

//                print("Load Result- \(result)")

                self.targetTextView.text = translatedText
            }
        }
    }

//    func updateTranslateButtonState() {
//        translateButton.isEnabled = sourceTextViewContainsTypedText
//
    ////        print("Translate button enabled = \(translateButton.isEnabled)")
//    }

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
        initGestureForLeavingEditMode()

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
