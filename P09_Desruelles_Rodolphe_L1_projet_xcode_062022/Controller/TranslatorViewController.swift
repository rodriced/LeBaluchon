//
//  TranslatorViewController.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rod on 04/07/2022.
//

import UIKit

class TranslatorViewController: UIViewController, UITextViewDelegate {
    // Model interface

    let translationLoader = APIRequestLoader(apiRequest: TranslationRequest())

    // Components

    @IBOutlet var sourceTextView: UITextView!
    @IBOutlet var targetTextView: UITextView!
    @IBOutlet var translateButton: UIButton!

    let translationLoadingFailureAlert: UIAlertController = {
        let alertVC = UIAlertController(title: "Erreur", message: "Impossible de récupérer la traduction.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alertVC
    }()

    // Events

    @IBAction func translateButtonTapped() {
        guard !sourceTextView.text.isEmpty, !sourceTextViewPlaceholderDisplayed else { return }

        updateTargetTextViewTranslation()
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard textView == sourceTextView else { return true }

        if sourceTextViewPlaceholderDisplayed {
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

        updateTranslateButtonState()
    }

    func updateTargetTextViewTranslation() {
        let translationParameters = TranslationRequestData(
            targetLanguage: "en",
            sourceLanguage: "fr",
            text: sourceTextView.text ?? ""
        )
//        do {
//            let request = try translationLoader.apiRequest.makeRequest(from: translationParameters)
//            print(request)
//        } catch {
//            print(error)
//        }
//        return
        translationLoader.load(requestData: translationParameters) {
            result in
            guard let result = result else {
                DispatchQueue.main.async {
                    self.present(self.translationLoadingFailureAlert, animated: true, completion: nil)
                }
                return
            }

            DispatchQueue.main.async {
                self.targetTextView.text = result[0].translations[0].text
            }
        }
    }

    // Working

    var sourceTextViewPlaceholderDisplayed: Bool!

    func hideSourceTextViewPlaceholder() {
        sourceTextView.textColor = UIColor.darkText
        sourceTextView.text = ""
        sourceTextViewPlaceholderDisplayed = false
    }

    func displaySourceTextViewPlaceholder() {
        sourceTextViewPlaceholderDisplayed = true
        sourceTextView.textColor = UIColor.lightGray
        sourceTextView.text = "Tapez un texte"
    }

    func updateTranslateButtonState() {
        translateButton.isEnabled = !sourceTextView.text.isEmpty && !sourceTextViewPlaceholderDisplayed
    }

    func setupDesign() {
        sourceTextView.layer.borderWidth = 1.0
        sourceTextView.layer.borderColor = UIColor.black.cgColor

        targetTextView.layer.borderWidth = 2.0
        targetTextView.layer.borderColor = UIColor(named: "Travel")!.cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sourceTextView.delegate = self
        
        setupDesign()
        translateButton.isEnabled = false
        displaySourceTextViewPlaceholder()

        translateButton.isEnabled = !sourceTextView.text.isEmpty && !sourceTextViewPlaceholderDisplayed
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
