//
//  Date+Extension.swift
//  nviro
//
//  Created by Ali Dinç on 10/09/2021.
//

import Foundation

extension Date {
    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
}

extension Date {
    func dateStringForForsquare() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMDD"
        return dateFormatter.string(from: self)
    }
}
