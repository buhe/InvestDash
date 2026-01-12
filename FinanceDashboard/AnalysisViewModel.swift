//
//  AnalysisViewModel.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/1/30.
//

import SwiftUI
import CoreData

class AnalysisViewModel: ObservableObject {
    @Published var model: Model = Model.shared
    func actualRatio(overviews: [Overviews]) -> Double {
        var base: Double = 0
        var high: Double = 0
        for o in overviews {
            switch o.categroy {
            case .Stock:
                base = base + o.total
                high = high + o.total
            case .Cash:
                base = base + o.total
            case .Savings:
                base = base + o.total
            case .Bond:
                base = base + o.total
            case .Debt: break
            case .Estate:
                if model.incldueEstate {
                    base = base + o.total
                }
                break
            case .Fund:
                base = base + o.total
                high = high + o.total
            case .Futures:
                base = base + o.total
                high = high + o.total
            case .Option:
                base = base + o.total
                high = high + o.total
            case .UnKnow: break
            }
        }
        return high / base
    }
    // 100 - age
    func desc(ratio: Double) -> String {
        let risk = riskAl(ratio: ratio)
        if risk == .high {
            return "Your high-risk investments are too high((\(Int(ratio * 100))%)), consider adding some low-risk investments."
        } else {
            if risk == .warning {
                return "Your high-risk investment ratio is a bit high, However, the deviation ranges from 50% to 90%(\(Int(ratio * 100))%)."
            } else {
                return "Your high and low risk investments are proportionate((\(Int(ratio * 100))%))."
            }
        }
        
    }
    
    func risk(ratio: Double) -> Color {
        let risk = riskAl(ratio: ratio)
        if risk == .high {
            return .red
        } else {
            if risk == .warning {
                return .yellow
            } else {
                return .green
            }
        }
    }
    
    func riskAl(ratio: Double) -> Risk {
        let red = ratio > 0.9
        let yellow = 0.5 < ratio && ratio <= 0.9
        return red ? Risk.high : yellow ? Risk.warning : Risk.low
    }
    
    // 计算年化收益率
    func calculateAnnualizedReturns(items: FetchedResults<Item>, viewContext: NSManagedObjectContext) async -> [(year: Int, returnRate: Double)] {
        let calendar = Calendar.current
        var yearlyData: [Int: (startTotal: Double, endTotal: Double)] = [:]
        let currentYear = calendar.component(.year, from: Date())
        
        // 获取所有数据的年份范围
        let allDates = items.compactMap { $0.updatedDate }
        guard let minDate = allDates.min(), let maxDate = allDates.max() else {
            return []
        }
        
        let startYear = calendar.component(.year, from: minDate)
        let endYear = min(calendar.component(.year, from: maxDate), currentYear - 1) // 只计算到上一年
        
        // 获取每年的年初和年末总资产价值
        for year in startYear...endYear {
            // 获取年初数据（1月1日或最早的数据）
            let yearStartDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let nextYearStartDate = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
            
            // 获取该年份的年初数据（1月1日或之后最早的数据）
            let startItems = items.filter { item in
                guard let updatedDate = item.updatedDate else { return false }
                return updatedDate >= yearStartDate && updatedDate < nextYearStartDate
            }
            
            // 获取该年份的年末数据（12月31日或之前最晚的数据）
            let endItems = items.filter { item in
                guard let updatedDate = item.updatedDate else { return false }
                return updatedDate >= yearStartDate && updatedDate < nextYearStartDate
            }
            
            if !startItems.isEmpty && !endItems.isEmpty {
                // 计算年初总资产（使用最早的数据）
                let startTotal = await calculateYearTotal(items: Array(startItems), viewContext: viewContext, useEarliest: true)
                // 计算年末总资产（使用最晚的数据）
                let endTotal = await calculateYearTotal(items: Array(endItems), viewContext: viewContext, useEarliest: false)
                
                yearlyData[year] = (startTotal: startTotal, endTotal: endTotal)
            }
        }
        
        // 计算年化收益率
        var annualizedReturns: [(year: Int, returnRate: Double)] = []
        let sortedYears = yearlyData.keys.sorted()
        
        for year in sortedYears {
            if let data = yearlyData[year], data.startTotal > 0 {
                // 计算年化收益率 = (年末总资产 - 年初总资产) / 年初总资产 * 100%
                let returnRate = ((data.endTotal - data.startTotal) / data.startTotal) * 100
                annualizedReturns.append((year: year, returnRate: returnRate))
            }
        }
        
        return annualizedReturns
    }
    
    // 计算指定年份的总资产
    private func calculateYearTotal(items: [Item], viewContext: NSManagedObjectContext, useEarliest: Bool = false) async -> Double {
        var total: Double = 0
        var selectedItems: [String: Item] = [:]
        
        // 获取每个项目的选定记录（最早或最晚）
        for item in items {
            let name = item.name!
            if selectedItems[name] == nil {
                selectedItems[name] = item
            } else {
                if useEarliest {
                    // 选择最早的数据
                    if item.updatedDate! < selectedItems[name]!.updatedDate! {
                        selectedItems[name] = item
                    }
                } else {
                    // 选择最晚的数据
                    if item.updatedDate! > selectedItems[name]!.updatedDate! {
                        selectedItems[name] = item
                    }
                }
            }
        }
        
        // 计算总资产，考虑货币转换
        for item in selectedItems.values {
            if let unit = Unit(rawValue: item.unit ?? ""), unit == Model.shared.unit {
                total += item.value
            } else {
                // 货币转换
                let new = await CurrencySDK.transfer(origion: (item.value, Unit(rawValue: item.unit ?? "") ?? .UnKnow), to: Model.shared.unit, viewContext: viewContext)
                total += new.0
            }
        }
        
        return total
    }
    
    // 获取年份标签
    func getYearLabels(annualizedReturns: [(year: Int, returnRate: Double)]) -> [String] {
        return annualizedReturns.map { "\($0.year)" }
    }
    
    // 获取收益率数值
    func getReturnValues(annualizedReturns: [(year: Int, returnRate: Double)]) -> [Double] {
        return annualizedReturns.map { $0.returnRate }
    }
    
    // 计算平均年化收益率
    func getAverageReturn(annualizedReturns: [(year: Int, returnRate: Double)]) -> Double {
        guard !annualizedReturns.isEmpty else { return 0 }
        let total = annualizedReturns.reduce(0) { $0 + $1.returnRate }
        return total / Double(annualizedReturns.count)
    }
    
    // 获取最佳年份
    func getBestYear(annualizedReturns: [(year: Int, returnRate: Double)]) -> (year: Int, returnRate: Double)? {
        return annualizedReturns.max { $0.returnRate < $1.returnRate }
    }
    
    // 获取最差年份
    func getWorstYear(annualizedReturns: [(year: Int, returnRate: Double)]) -> (year: Int, returnRate: Double)? {
        return annualizedReturns.min { $0.returnRate < $1.returnRate }
    }
}

enum Risk {
    case high
    case warning
    case low
}
