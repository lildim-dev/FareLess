//
//  CurrencyFormatter.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

enum CurrencyFormatter {
    static func formattedMinorUnits(_ minorUnits: Int, currencyCode: String) -> String {
        let amount = Decimal(minorUnits) / Decimal(100)
        return amount.formatted(.currency(code: currencyCode).precision(.fractionLength(0)))
    }

    static func accessibilityFormattedMinorUnits(_ minorUnits: Int, currencyCode: String) -> String {
        formattedMinorUnits(minorUnits, currencyCode: currencyCode)
    }
}
