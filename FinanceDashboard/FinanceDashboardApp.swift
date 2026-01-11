//
//  FinanceDashboardApp.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/1/1.
//

import SwiftUI
import UserNotifications

@main
struct FinanceDashboardApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        CurrencySDK.loadCache(viewContext: persistenceController.container.viewContext)
        return WindowGroup {
            ContentView(overViewModel: OverViewModel(), chartViewModel: ChartViewModel(), analysisViewModel: AnalysisViewModel())
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


