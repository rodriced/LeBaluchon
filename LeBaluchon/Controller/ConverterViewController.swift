//
//  ExchangeViewController.swift
//  LeBaluchon
//
//  Created by Rodolphe Desruelles on 21/06/2022.
//

import UIKit

class ConverterViewController: UIViewController {
    let testing = false // true for development, false for production.
    // To simulate API acces because there is a limited number of request in the free fixer.io account

    private static var resultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    // Model //
    // ----- //

    let config = Config.shared

    let ratesLoader = APIRequestLoader(apiRequest: RatesRequest())
    var converter: Converter?

    // View components //
    // --------------- //

    let rateLoadingFailureAlert = ControllerHelper.simpleAlert(message: "Impossible de récupérer le cours.")

    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var rateLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var rateErrorImage: UIImageView!

    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var resultLabel: UILabel!

    @IBOutlet var refreshButton: UIBarButtonItem!

    // Events //
    // ------ //

    @IBAction func amountTextFieldDidChange(_ sender: UITextField) {
        updateResultLabel()
    }

    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        setupConverter()
    }

    private func initGestureForLeavingEditMode() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(leaveEditMode)
        )
        view.addGestureRecognizer(tap)
    }

    // Logic //
    // ----- //

    @objc func leaveEditMode() {
        view.endEditing(true)
    }

    func updateResultLabel() {
        guard let amountText = amountTextField.text, !amountText.isEmpty else {
            resultLabel.text = ""
            return
        }

        guard let amount = Double(amountText) else {
            resultLabel.textColor = UIColor.red
            resultLabel.text = "Caractères invalides !"
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
            // Simulating network delay and set random rate or error
            // For testing purpose only !!
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

        let requestInputData = RatesRequestInputData(baseCurrency: config.originPlace.currencySymbol,
                                                     targetCurrency: config.destinationPlace.currencySymbol)
        ratesLoader.load(requestInputData, completionHandler: completionHandler)
    }

    func updateRateLabel(_ rate: Double) {
        self.rateLabel.text = String(rate)
                              + (self.testing ? " (TESTING)":"")
    }
    
    private func setupConverter() {
        setRateLoadingState(.loadingInProgress)

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
                self.updateRateLabel(converter.rate)
                self.setRateLoadingState(.loaded)
                self.updateResultLabel()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initGestureForLeavingEditMode()

        rateErrorImage.isHidden = true
        amountTextField.text = ""
        resultLabel.text = ""

        setupConverter()
    }

}
