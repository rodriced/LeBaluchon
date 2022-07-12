//
//  ExchangeViewController.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 21/06/2022.
//

import UIKit

class ConverterViewController: UIViewController {
    let testing = true

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

    // Model //
    // ------//

    let ratesLoader = APIRequestLoader(apiRequest: RatesRequest())
    var converter: Converter?

    // View components //
    // -----------------//

    let rateLoadingFailureAlert = ControllerHelper.simpleAlert(message: "Impossible de récupérer le cours.")

    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var rateLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var rateErrorImage: UIImageView!

    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var resultLabel: UILabel!

    @IBOutlet var refreshButton: UIBarButtonItem!

    // Events //
    //--------//
    
    @IBAction func amountTextFieldDidChange(_ sender: UITextField) {
        updateResultLabel()
    }

    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        setupConverter()
    }

    private func initHideKeyboardEvent() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        view.addGestureRecognizer(tap)
    }

    // Logic //
    //-------//
    
    @objc func hideKeyboard() {
        view.endEditing(true)
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

    enum RateFieldState {
        case loaded, loadingInProgress, error
    }

    private func setRateLoadingState(_ state: RateFieldState) {
        rateLabel.isHidden = state != .loaded
        rateLoadingIndicator.isHidden = state != .loadingInProgress
        amountTextField.isEnabled = state == .loaded
        rateErrorImage.isHidden = state != .error
        refreshButton.isEnabled = state != .loadingInProgress
    }

    private func loadRatesData(completionHandler: @escaping (RatesData?) -> Void) {
        if testing {
            // For testing purpose //
            // Simulating network delay and set random rate or error
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if Int.random(in: 1 ... 10) <= 7 {
                    let sampleRatesData = RatesData(
                        success: true,
                        timestamp: 1656512403,
                        base: "EUR",
                        date: "2022-06-29",
                        rates: ["USD": Double.random(in: 1.013 ..< 1.4)]
                    )
                    completionHandler(sampleRatesData)
                } else {
                    completionHandler(nil)
                }
            }
            return
        }

        let requestInputData = RatesRequestInputData(baseCurrency: baseCurrency, targetCurrency: targetCurrency)
        ratesLoader.load(requestInputData: requestInputData, completionHandler: completionHandler)
    }

    private func setupConverter() {
        setRateLoadingState(.loadingInProgress)

//        let requestData = RatesRequestData(baseCurrency: baseCurrency, targetCurrency: targetCurrency)
//        ratesLoader.load(requestData: requestData) { ratesData in
        loadRatesData() { ratesData in

            DispatchQueue.main.async {
                guard let ratesData = ratesData,
                      let converter = Converter(ratesData: ratesData)
                else {
                    self.setRateLoadingState(.error)
                    self.present(self.rateLoadingFailureAlert, animated: true, completion: nil)
                    return
                }

                self.converter = converter
                self.rateLabel.text = String(converter.rate)
                self.setRateLoadingState(.loaded)
                self.updateResultLabel()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initHideKeyboardEvent()

        rateErrorImage.isHidden = true
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
