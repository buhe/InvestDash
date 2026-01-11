//
//  AnalysisView.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/1/30.
//

import SwiftUI
import SwiftUICharts
import Combine
import UIx

struct AnalysisView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdDate, ascending: true)],
            animation: .default)
    private var items: FetchedResults<Item>
    @ObservedObject var analysisViewModel: AnalysisViewModel
    @ObservedObject var overViewModel: OverViewModel
    @ObservedObject var chartViewModel: ChartViewModel
    
    
   
    
    var body: some View {
//        TabBar {
            InnerAnalysisView(analysisViewModel: analysisViewModel, overViewModel: overViewModel)
//        }
        

//        .sheet(isPresented: $showingIAP){
//            ProView{
//                showingIAP = false
//            }
//        }
//        .backgroundFill(.red)
        
        
    }
}

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView(analysisViewModel: AnalysisViewModel(), overViewModel: OverViewModel(), chartViewModel: ChartViewModel())
    }
}
