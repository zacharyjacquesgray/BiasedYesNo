//
//  CustomTabBar.swift
//  YesNo
//
//  Created by Zachary-Jacques Gray of Island Société on 27/1/2023.
//

import SwiftUI

enum Tabs: Int {
    case fiftyFifty = 0
    case yesNoMain = 1
    case user = 2
}

struct CustomTabBar: View {
    
    @Binding var selectedTab: Tabs
    var selectColor: String
    
    var body: some View {
        HStack {
            Spacer()
            NavigationLink(destination: ContentView()) {
                // Switch to 50/50 Yes-No
                TabBarButton(buttonText: "50/50", imageName: "questionmark.circle", isActive: selectedTab == .fiftyFifty, lineColor: selectColor)
            }
            .isDetailLink(false)
            .simultaneousGesture(TapGesture().onEnded{
                selectedTab = .fiftyFifty
            })
            Spacer()
            Spacer()
            NavigationLink(destination: YesNoMain()) {
                // Switch to Yes / No Main
                TabBarButton(buttonText: "Yes / No", imageName: "bubble.left", isActive: selectedTab == .yesNoMain, lineColor: selectColor)
            }
            .isDetailLink(false)
            .simultaneousGesture(TapGesture().onEnded{
                selectedTab = .yesNoMain
            })
            Spacer()
            Spacer()
            NavigationLink(destination: UserPanel()) {
                // Switch to % User Panel
                TabBarButton(buttonText: "%", imageName: "person", isActive: selectedTab == .user, lineColor: selectColor)
            }
            .isDetailLink(false)
            .simultaneousGesture(TapGesture().onEnded{
                selectedTab = .user
            })
            Spacer()
        }
        .frame(height: 82)
    }
}


// MARK: - This is for previews
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.fiftyFifty), selectColor: "YesColor2")
    }
}
