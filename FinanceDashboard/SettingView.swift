//
//  SettingView.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/1/14.
//

import SwiftUI
import Combine
import StoreKit
import CoreData

struct SettingView: View {
    let model: Model
    @AppStorage(wrappedValue: false, "face") var faceIdEnable: Bool
    @AppStorage(wrappedValue: false, "schedle_trigger") var schedleTrigger: Bool
    @AppStorage(wrappedValue: "monthly", "schedle_cycle") var schedleCycle: String
    @AppStorage(wrappedValue: "", "schedle_id") var schedleId: String
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.requestReview) var requestReview
    @State var showAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(){
                    Button{
                        #if os(iOS)
                        if let url = URL(string: "https://blog.buhe.dev/support") {
                            UIApplication.shared.open(url)
                        }
                        #endif
                    } label: {
                        
                        Text("Feedback")
                        
                    }.buttonStyle(PlainButtonStyle())
                    Button{
                        requestReview()
                    } label: {
                        
                        Text("Rate")
                        
                    }.buttonStyle(PlainButtonStyle())
                    ExportView()
                        .environment(\.managedObjectContext, viewContext)
                    
                    NavigationLink {
                        CurrencyView(model: model)
                    } label: {
                        Text("Currency")
                    }
//                    NavigationLink {
//                        AgeView(model: model)
//                    } label: {
//                        Text("Age")
//                    }
                    Toggle("Face ID", isOn: $faceIdEnable)
                    Toggle("Schedule Trigger", isOn: $schedleTrigger)
                        .onChange(of: schedleTrigger) {
                            value in
                            if value {
                                // enable
                                InvestSchedule.shared.request()
                                schedleId = InvestSchedule.shared.send(cycle: schedleCycle)
                            } else {
                                InvestSchedule.shared.stop(id: schedleId)
                            }
                        }
                    Picker("Schedule Cycle", selection: $schedleCycle) {
                        Text("Monthly")
                            .tag("monthly")
                        Text("Weekly")
                            .tag("weekly")
                    }.onChange(of: schedleCycle) {
                        cycle in
                        if !schedleId.isEmpty {
                            InvestSchedule.shared.stop(id: schedleId)
                            schedleId = InvestSchedule.shared.send(cycle: cycle)
                        }
                    }
                    Button{
                        cleanCache()
                    } label: {
                        
                        Text("Clean cache")
                        
                    }.buttonStyle(PlainButtonStyle())
                    HStack{
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.releaseVersionNumber!)
                    }
                    HStack{
                        Text("License")
                        Spacer()
                        Text("GPLv3")
                    }
                }
                
                
            }
            .alert("Cache cleaned.", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    func cleanCache() {
        // 创建一个 NSFetchRequest 来获取 "Cache" 实体的所有对象
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Cache")

        // 创建一个 NSBatchDeleteRequest 使用从上面的 fetchRequest 获取的所有结果
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            // 执行删除请求，这将删除所有符合条件的 "Cache" 实体对象。
            // 注意，这个操作是直接在持久化存储层面进行的，所以它会忽略在上下文中对实体对象的任何未保存的更改。
            // 并且不会触发 NSFetchedResultsController 的通知。
            try viewContext.execute(deleteRequest)

            // 如果你需要上下文和持久化存储保持一致，你也许需要重置或者重新获取上下文
            viewContext.reset() // 如果需要的话
            showAlert = true
        } catch let error as NSError {
            // 处理错误
            print("删除失败: \(error), \(error.userInfo)")
        }
    }
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView(model: Model())
//    }
//}
