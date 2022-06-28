//
//  ExchangeViewController.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 21/06/2022.
//

import UIKit

class ConverterViewController: UIViewController {
    private static var resultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    let converterService = ConverterService.shared
    var converter: Converter?

    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var rateLoadingIndicator: UIActivityIndicatorView!

    @IBOutlet var amountTextField: UITextField!

    @IBOutlet var resultLabel: UILabel!

    @IBAction func amountTextFieldDidChange(_ sender: UITextField) {
        updateResultLabel()
    }

    func updateResultLabel() {
        guard let amountText = amountTextField.text, !amountText.isEmpty else {
            resultLabel.text = ""
            return
        }

        guard let amount = Double(amountText) else {
            resultLabel.text = "Error: Bad number format"
            return
        }

        if let converter = converter {
            let result = converter.convert(amount)

            resultLabel.text = Self.resultFormatter.string(from: NSNumber(value: result))!
        }
    }
    
    func reset() {
        rateLabel.text = ""
//        rateLabel.isHidden = true
        amountTextField.isEnabled = false
        amountTextField.text = ""
        resultLabel.text = ""
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    func initHideKeyboardEvent() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        view.addGestureRecognizer(tap)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initHideKeyboardEvent()

        amountTextField.text = ""
        resultLabel.text = ""

        rateLabel.isHidden = true
        rateLoadingIndicator.isHidden = false
        amountTextField.isEnabled = false

        converterService.getConverter(baseCurrency: "EUR", targetCurrency: "USD") { converter in
            guard let converter = converter else {
                print("Error: can't get converter")
                return
            }

            self.converter = converter

            DispatchQueue.main.async {
                self.rateLabel.text = String(converter.rate)
                self.rateLabel.isHidden = false
                self.rateLoadingIndicator.isHidden = true
                self.amountTextField.isEnabled = true
            }
        }

        // Do any additional setup after loading the view.
    }

//    init() {
//
//    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
