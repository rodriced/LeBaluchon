//
//  TranslatorViewController.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rod on 04/07/2022.
//

import UIKit

class TranslatorViewController: UIViewController, UITextViewDelegate {
    var sourceTextViewPlaceholderDisplayed: Bool!

    // Model interface

    let translationLoader = APIRequestLoader(apiRequest: TranslationRequest())

    // Components

    @IBOutlet var sourceTextView: UITextView!
    @IBOutlet var targetTextView: UITextView!
    @IBOutlet var translateButton: UIButton!

    let translationLoadingFailureAlert = Helper.simpleAlert(message: "Impossible de récupérer la traduction.")

    // Events

    @IBAction func translateButtonTapped() {
        guard !sourceTextView.text.isEmpty, !sourceTextViewPlaceholderDisplayed else { return }

        updateTargetTextViewTranslation()
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

    // Logic

    func updateTargetTextViewTranslation() {
        let requestInputData = TranslationRequestInputData(
            targetLanguage: "en",
            sourceLanguage: "fr",
            text: sourceTextView.text ?? ""
        )

        translationLoader.load(requestInputData: requestInputData) {
            result in
            DispatchQueue.main.async {
                guard let result = result else {
                    return self.present(self.translationLoadingFailureAlert, animated: true, completion: nil)
                }

                self.targetTextView.text = result[0].translations[0].text
            }
        }
    }

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

    func setupInterface() {
        sourceTextView.layer.borderWidth = 0.5
        sourceTextView.layer.borderColor = UIColor.lightGray.cgColor

        translateButton.layer.cornerRadius = 10.0
        translateButton.clipsToBounds = true

        translateButton.isEnabled = false

        displaySourceTextViewPlaceholder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sourceTextView.delegate = self

        initHideKeyboardEvent()

        setupInterface()
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
