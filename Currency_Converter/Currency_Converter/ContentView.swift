//
//  ContentView.swift
//  Currency_Converter
//
//  Created by Sid Kumar on 6/13/25.
//

import SwiftUI

struct ContentView: View {
    // Supported currencies and static rates (to USD)
    let currencies = ["USD", "EUR", "JPY"]
    let rates: [String: Double] = [
        "USD": 1.0,
        "EUR": 1.09,
        "JPY": 0.0071 // 1 JPY = 0.0071 USD
    ]
    
    @State private var amount: String = ""
    @State private var fromCurrency = "USD"
    @State private var toCurrency = "EUR"
    @FocusState private var isAmountFieldFocused: Bool

    var convertedAmount: Double? {
        guard let amountValue = Double(amount),
              let fromRate = rates[fromCurrency],
              let toRate = rates[toCurrency] else {
            return nil
        }
        let usdAmount = amountValue * fromRate
        return usdAmount / toRate
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($isAmountFieldFocused)
                }
                Section(header: Text("From")) {
                    Picker("From", selection: $fromCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("To")) {
                    Picker("To", selection: $toCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Converted Amount")) {
                    if let result = convertedAmount {
                        Text(String(format: "%.2f %@", result, toCurrency))
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    } else {
                        Text("-")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Currency Converter")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isAmountFieldFocused = false }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
