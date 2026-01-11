//
//  AgeAnalysisView.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/9/17.
//

import SwiftUI
import SwiftUICharts
import Combine
import UIx
import SwiftyJSON

struct InnerAnalysisView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdDate, ascending: true)],
            animation: .default)
    private var items: FetchedResults<Item>
    @ObservedObject var analysisViewModel: AnalysisViewModel
    @ObservedObject var overViewModel: OverViewModel
    
//    @State var age = ""
    @State var desc = ""
    @State var ratio: Double = 0
    @State var risk = Color.gray
    
    @AppStorage(wrappedValue: "waiting...", "recommend") var recommend
    @AppStorage(wrappedValue: false, "incldueEstate") var incldueEstate: Bool
    @State private var showingIAP = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(analysisViewModel: AnalysisViewModel, overViewModel: OverViewModel) {
        self.analysisViewModel = analysisViewModel
        self.overViewModel = overViewModel
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                HStack {
//                    Text("Age:")
//                    TextField("Age", text: $age)
//                        .keyboardType(.numbersAndPunctuation)
//                        .onAppear{
//                            age = String(overViewModel.model.age)
//                        }
//                        .onChange(of: age){
//                            a in
//                            if let a = Int(a) {
//                                overViewModel.model.age = a
//                            }
//                        }
//                        .frame(width: 44)
                    Text("Equity vs. Conservative:")
                    Text("\(percentFormat(value:ratio))")
                        .foregroundColor(self.risk)
                        .onAppear{
                            Task{
                                self.ratio = await analysisViewModel.actualRatio(overviews: overViewModel.byCategory(items: items, viewContext: viewContext))
                                self.risk = analysisViewModel.risk(ratio: self.ratio)
                            }
                        }.onChange(of: try! JSON(self.items)){
                            _ in
                            Task{
                                self.ratio = await analysisViewModel.actualRatio(overviews: overViewModel.byCategory(items: items, viewContext: viewContext))
                                self.risk = analysisViewModel.risk(ratio: self.ratio)
                            }
                        }
                        .onChange(of: self.incldueEstate){
                            _ in
                            Task{
                                self.ratio = await analysisViewModel.actualRatio(overviews: overViewModel.byCategory(items: items, viewContext: viewContext))
                                self.risk = analysisViewModel.risk(ratio: self.ratio)
                            }
                        }
                    
                }
                .font(.title)
                .fontWeight(.bold)
                
                Divider()
                
                Text("Graham's suggestion")
                    .font(.title2)
                Text("Graham's suggestion: maintain fixed ratios between stocks and bonds. We choose a 50%:50% allocation and rebalance every six months. This is a conservative strategy that aims to preserve capital and reduce risk."
                )
                .lineLimit(20)
                
                PieChartView(data: [1 - ratio, ratio], title: "Equity vs. Conservative", style: colorScheme == .light ? ChartStyle(backgroundColor: Color.white, accentColor: Colors.BorderBlue, secondGradientColor: Colors.BorderBlue, textColor: Color.black, legendTextColor: Color.black, dropShadowColor: .gray) : ChartStyle(backgroundColor: Color.gray, accentColor: Colors.DarkPurple, secondGradientColor: Colors.DarkPurple, textColor: Color.white, legendTextColor: Color.white, dropShadowColor: .gray), form: ChartForm.extraLarge)
                    .padding(.top)
                Text("Summary")
                    .font(.title2)
                    .padding(.top)
                Text(self.desc)
                    .onAppear{
                        Task{
                            self.desc = await analysisViewModel.desc(ratio: analysisViewModel.actualRatio(overviews: overViewModel.byCategory(items: items, viewContext: viewContext)))
                        }
                    }
                    .onChange(of: self.incldueEstate){
                        _ in
                        Task{
                            self.desc = await analysisViewModel.desc(ratio: analysisViewModel.actualRatio(overviews: overViewModel.byCategory(items: items, viewContext: viewContext)))
                        }
                    }
                    .lineLimit(20)
                Spacer()
            }
            .padding()
            HStack{
                Image(systemName: "house")
                Toggle("Include Estate", isOn: $incldueEstate)
                //                    .onReceive(Just(incldueEstate)) {
                //                        value in
                //                        // true -> fasle
                //                        if value {
                //                            //                                print("receive: \(value)")
                //                            if !overViewModel.model.iap {
                //                                incldueEstate.toggle()
                //                                showingIAP = true
                //                            }
                //                        }
                //
                //                    }
            }
            .padding(.horizontal)
        }
        .tabbar("By Age Analysis")
    }
}

//#Preview {
//    AgeAnalysisView()
//}
