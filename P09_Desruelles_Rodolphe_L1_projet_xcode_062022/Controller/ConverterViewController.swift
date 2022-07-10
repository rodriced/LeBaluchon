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

    enum Testing { case normal, withError }
//    let testing = nil
//    let testing: Testing? = .normal
    let testing: Testing? = .withError

    let ratesLoader = APIRequestLoader(apiRequest: RatesRequest())
    var converter: Converter?

    let rateLoadingFailureAlert = Helper.simpleAlert(message: "Impossible de récupérer le cours.")

    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var rateLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var rateErrorImage: UIImageView!

    @IBOutlet var amountTextField: UITextField!

    @IBOutlet var resultLabel: UILabel!

    @IBAction func amountTextFieldDidChange(_ sender: UITextField) {
        updateResultLabel()
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

    func updateResultLabel() {
        guard let amountText = amountTextField.text, !amountText.isEmpty else {
            resultLabel.text = ""
            return
        }

        guard let amount = Double(amountText) else {
            resultLabel.textColor = UIColor.red
            resultLabel.text = "Erreur: caractères invalides"
            return
        }

        if let converter = converter {
            let result = converter.convert(amount)

            resultLabel.textColor = UIColor.black
            resultLabel.text = Self.resultFormatter.string(from: NSNumber(value: result))!
        }
    }

    private func setRateLoadingState(_ loadingInProgress: Bool) {
        rateLabel.isHidden = loadingInProgress
        rateLoadingIndicator.isHidden = !loadingInProgress
        amountTextField.isEnabled = !loadingInProgress
    }

    private func loadRatesData(completionHandler: @escaping (RatesData?) -> Void) {
        if let testing = testing {
            // Simulating network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                switch testing {
                case .normal: completionHandler(RatesData.getSample())
                case .withError: completionHandler(nil)
                }
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

            DispatchQueue.main.async {
                guard let ratesData = ratesData,
                      let converter = Converter(ratesData: ratesData)
                else {
                    return self.present(self.rateLoadingFailureAlert, animated: true, completion: nil)
                }

                self.converter = converter
                self.rateLabel.text = String(converter.rate)
                self.setRateLoadingState(false)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initHideKeyboardEvent()

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
