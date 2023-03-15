//
//  ContentView.swift
//  YesNo
//
//  Created by Zachary-Jacques Gray of Island Société on 26/1/2023.
//
/*
 
 Biased Yes or No
 
 */

import SwiftUI

struct ContentView: View {
    
    @State var selectedTab: Tabs = .fiftyFifty
    
    @State private var yesNo:String = "Yes  /  No"
    @State private var yesNoColor1:String = "BackgroundColor"
    @State var yesNoColor2:String = "BackgroundColor"
    @State private var outputColor:String = "HeadingColor"
    let bias50:Double = 0.5
    
    // Remove Navigation Animation when switching views.
    init(){
        UINavigationBar.setAnimationsEnabled(false)
    }
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                // Yes-No button
                Button(action: {
                    YesNo(x: bias50)
                }) {
                    ZStack{
                        // Background
                        LinearGradient(colors: [Color(yesNoColor1), Color(yesNoColor2)],
                                       startPoint: .top,
                                       endPoint: .leading)
                        .ignoresSafeArea()
                        VStack {
                            Spacer()
                            Text(yesNo)
                                .font(.custom("Arial Bold", size: 35))
                                .foregroundColor(Color(outputColor))
                                .bold()
                            Spacer()
                            Rectangle()
                                .frame(height: 82)
                                .foregroundColor(.white)
                                .opacity(0)
                        }
                        
                    }
                }
                // Logo
                VStack {
                    Spacer()
                    ZStack {
                        Color("BackgroundColor")
                            .frame(height: 82)
                            .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
                                Color.clear
                                    .frame(height: 0)
                                    .background(Color("BackgroundColor"))
                            }
                            .ignoresSafeArea()
                        CustomTabBar(selectedTab: $selectedTab, selectColor: yesNoColor2)
                        /*Image("IslandTech")
                         .resizable()
                         .frame(width: 93.75, height: 40.5)
                         */
                        
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    // Returns if random bias returns TRUE or FALSE, and then provides this to yesNoDisplay to change display for YES or NO respectively
    func YesNo(x:Double) {
        // YesNo()
        let isYesNo = yesNoBool(Bias: x)
        yesNoDisplay(isYesNo)
    }
    
    // Returns TRUE or FALSE from percent bias
    func yesNoBool(Bias:Double) -> Bool{
        let randomNum = Double.random(in: 0...1)
        var isYes: Bool
        if (randomNum < Bias) {
            isYes = true
        }
        else {
            isYes = false
        }
        return isYes
    }
    
    // Changes to display based on YES/TRUE or NO/FALSE
    func yesNoDisplay(_ Yes:Bool) {
        // Yes Display
        if Yes {
            yesNo = "YES"
            yesNoColor1 = "YesColor1"
            yesNoColor2 = "YesColor2"
            outputColor = "White"
        }
        // No Display
        else {
            yesNo = "NO"
            yesNoColor1 = "NoColor1"
            yesNoColor2 = "NoColor2"
            outputColor = "White"
        }
        
    }
    
}



// MARK: - This is for previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
