//
//  AnnualReturnChart.swift
//  FinanceDashboard
//
//  Created by AI Assistant on 2026/01/12.
//

import SwiftUI
import SwiftUICharts

struct AnnualReturnChart: View {
    let data: [Double]
    let title: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if !data.isEmpty {
            LineChartView(
                data: data,
                title: title,
                form: ChartForm.extraLarge,
                rateValue: nil
            )
        } else {
            Text("Nothing to display here.")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(height: 200)
        }
    }
}

struct AnnualReturnChart_Previews: PreviewProvider {
    static var previews: some View {
        AnnualReturnChart(data: [5.2, -2.1, 8.7, 12.3], title: "年化收益率趋势")
    }
}
