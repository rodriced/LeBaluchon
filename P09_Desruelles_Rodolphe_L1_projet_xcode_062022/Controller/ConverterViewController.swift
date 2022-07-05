//
//  ExchangeViewController.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 21/06/2022.
//

import UIKit

class ConverterViewController: UIViewController {
    let baseCurrency = "EUR"
    let targetCurrency = "USD"

    private static var resultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()

//    let converterService = ConverterService.shared
    let testing = true

    let ratesLoader = APIRequestLoader(apiRequest: RatesRequest())
    var converter: Converter?

    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var rateLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var rateErrorImage: UIImageView!

    @IBOutlet var amountTextField: UITextField!

    @IBOutlet var resultLabel: UILabel!

    @IBAction func amountTextFieldDidChange(_ sender: UITextField) {
        updateResultLabel()
    }

    let rateLoadingFailureAlert: UIAlertController = {
        let alertVC = UIAlertController(title: "Erreur", message: "Impossible de récupérer le cours.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alertVC
    }()

//    func presentRateLoadingFailureAlert() {
//        let alertVC = UIAlertController(title: "Erreur", message: "Impossible de récupérer le cours.", preferredStyle: .alert)
//        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//        present(alertVC, animated: true, completion: nil)
//    }

    func updateResultLabel() {
        guard let amountText = amountTextField.text, !amountText.isEmpty else {
            resultLabel.text = ""
            return
        }

        guard let amount = Double(amountText) else {
            resultLabel.textColor = UIColor.red
            resultLabel.text = "Erreur: montant mal formatté"
            return
        }

        if let converter = converter {
            let result = converter.convert(amount)

            resultLabel.textColor = UIColor.black
            resultLabel.text = Self.resultFormatter.string(from: NSNumber(value: result))!
        }
    }

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

    private func setRateLoadingState(_ enabled: Bool) {
        rateLabel.isHidden = enabled
        rateLoadingIndicator.isHidden = !enabled
        amountTextField.isEnabled = !enabled
    }

    private func loadRatesData(completionHandler: @escaping (RatesData?) -> Void) {
        guard !testing else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                completionHandler(RatesData.getSample())
//                completionHandler(nil)
            }

            return
        }

        let requestData = RatesRequestData(baseCurrency: baseCurrency, targetCurrency: targetCurrency)
        ratesLoader.load(requestData: requestData, completionHandler: completionHandler)
    }

    private func setupConverter() {
        setRateLoadingState(true)

//        let requestData = RatesRequestData(baseCurrency: baseCurrency, targetCurrency: targetCurrency)
//        ratesLoader.load(requestData: requestData) { ratesData in
        loadRatesData() { ratesData in

            guard let ratesData = ratesData,
                  let converter = Converter(ratesData: ratesData)
            else {
                DispatchQueue.main.async {
//                self.presentRateLoadingFailureAlert()
                    self.present(self.rateLoadingFailureAlert, animated: true, completion: nil)
                }
                return
            }

            self.converter = converter

            DispatchQueue.main.async {
                self.rateLabel.text = String(converter.rate)
                self.setRateLoadingState(false)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initHideKeyboardEvent()

        resultLabel.layer.borderWidth = 1.0
        resultLabel.layer.borderColor = UIColor(named: "Travel")!.cgColor

        amountTextField.text = ""
        resultLabel.text = ""

        setupConverter()
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
