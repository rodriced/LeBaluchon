//
//  Config.swift
//  LeBaluchon
//
//  Created by Rodolphe Desruelles on 15/07/2022.
//

// Global parameters for the application

struct Language {
    let name: String
    let symbol: String
}

struct Place {
    let name: String
    let latitude: Double
    let longitude: Double
    let currencySymbol: String
    let language: Language
}

class Config {
    let originPlace: Place
    let destinationPlace: Place

    private init(originPlace: Place, destinationPlace: Place) {
        self.originPlace = originPlace
        self.destinationPlace = destinationPlace
    }

    static let shared = Config(
        originPlace: Place(
            name: "Paris",
            latitude: 48.8588897,
            longitude: 2.3200410217200766,
            currencySymbol: "EUR",
            language: Language(
                name: "Français",
                symbol: "fr"
            )
        ),
        destinationPlace: Place(
            name: "New-York",
            latitude: 40.7127281,
            longitude: -74.0060152,
            currencySymbol: "USD",
            language: Language(
                name: "Anglais",
                symbol: "en"
            )
        )
    )
}
