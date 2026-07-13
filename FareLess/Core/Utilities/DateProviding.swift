//
//  DateProviding.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

protocol DateProviding {
    var now: Date { get }
}

struct SystemDateProvider: DateProviding {
    var now: Date {
        Date()
    }
}
