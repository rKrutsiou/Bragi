//
//  Int+Extension.swift
//  BragiTestAssigment
//
//  Created by Raman Krutsiou on 28/05/2025.
//

import Foundation

extension Int {
    func formatNumber() -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 1
            
            let million = 1_000_000
            let billion = 1_000_000_000
            
            if self >= billion {
                let value = Double(self) / Double(billion)
                return "\(formatter.string(from: NSNumber(value: value)) ?? "")B"
            } else if self >= million {
                let value = Double(self) / Double(million)
                return "\(formatter.string(from: NSNumber(value: value)) ?? "")M"
            }
            return formatter.string(from: NSNumber(value: self)) ?? ""
        }
}
