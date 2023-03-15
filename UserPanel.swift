//
//  UserPanel.swift
//  YesNo
//
//  Created by Zachary-Jacques Gray of Island Société on 28/1/2023.
//

import SwiftUI

struct UserPanel: View {
    
    // STATE VARIABLES
    @State var selectedTab: Tabs = .user
    
    @State private var yesNoBias:String = ""
    @State private var yesNoBias1:String = ""
    @State private var yesNoBias2:String = ""
    @State private var yesNoColor1:String = "UserPanelGrad1"
    @State var yesNoColor2:String = "UserPanelGrad2"
    @State private var outputColor:String = "HeadingColor"
    
    @State var isTapped:Bool = false
    @State var questionDisplay:Bool = false
    
    // VARIABLES
    private var bias:Double = 0.7 // Biased 70% Yes
    let bias50:Double = 0.5
    
    // Remove Navigation Animation when switching views.
    init(){
        UINavigationBar.setAnimationsEnabled(false)
    }
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                // Yes-No area
                ZStack{
                    // Background
                    LinearGradient(colors: [Color(yesNoColor1), Color(yesNoColor2)],
                                   startPoint: .top,
                                   endPoint: .bottomLeading)
                    .ignoresSafeArea()
                    // QUESTION TEXT FIELD INPUT
                    VStack (alignment: .leading) {
                        
                        
                        
                        Text("Use this space to temporarily display SQL database")
                        
                        
                        
                        
                        Spacer()
                        // HStack -- Text input and button
                        HStack {
                            // if-else toggles to show previous response whilst allowing a new input to be entered.
                            if questionDisplay {
                                TextField("Yes or No ?",text: $yesNoBias1) { (status) in
                                    // it will fire when text field is clicked ...
                                    if status{
                                        withAnimation(.easeIn){
                                            isTapped = true
                                        }
                                    }
                                } onCommit:{
                                    // it will fire when return button is pressed ...
                                    withAnimation(.easeOut){
                                        isTapped = false
                                    }
                                    YesNo(x: bias)
                                }
                                .font(.custom("Arial Bold", size: 35))
                                .foregroundColor(Color(outputColor))
                                .bold()
                                .padding(.horizontal, 25)
                            } else
                            {
                                TextField("Yes or No ?",text: $yesNoBias2) { (status) in
                                    // it will fire when text field is clicked ...
                                    if status{
                                        withAnimation(.easeIn){
                                            isTapped = true
                                        }
                                    }
                                } onCommit:{
                                    // it will fire when return button is pressed ...
                                    withAnimation(.easeOut){
                                        isTapped = false
                                    }
                                    YesNo(x: bias)
                                }
                                .font(.custom("Arial Bold", size: 35))
                                .foregroundColor(Color(outputColor))
                                .bold()
                                .padding(.horizontal, 25)
                            }
                            Spacer()
                            // Enter button to generate Yes/No. Alternate method to hitting the return key.
                            Button(action: {
                                YesNo(x: bias)
                            }) {
                                Image(systemName: "arrow.up.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:35, height: 35)
                                    .foregroundColor(Color(outputColor))
                            }
                            .padding(.horizontal, 15)
                        }
                        Spacer()
                        // Bottom area spacing to centre above text and button in observable screen
                        Rectangle()
                            .frame(height: 82)
                            .foregroundColor(.white)
                            .opacity(0)
                    }
                    
                }
                
                VStack (alignment: .leading) {
                    // if-else toggles displaying the input of the user once entered.
                    if questionDisplay {
                        Text(yesNoBias2)
                            .padding(.horizontal, 25.0)
                            .padding(.top, 35)
                            .font(.custom("Arial Bold", size: 30))
                            .foregroundColor(Color(outputColor))
                            .bold()
                    } else {
                        Text(yesNoBias1)
                            .padding(.horizontal, 25.0)
                            .padding(.top, 35)
                            .font(.custom("Arial Bold", size: 30))
                            .foregroundColor(Color(outputColor))
                            .bold()
                    }
                    
                    // HStack is the output Yes-No based on input question above
                    HStack {
                        Spacer()
                        Text(yesNoBias)
                            .padding([.top, .leading, .trailing], 25.0)
                            .font(.custom("Arial Bold", size: 30))
                            .foregroundColor(Color(outputColor))
                            .bold()
                    }
                    
                    Spacer()
                    
                    // Tab Bar button, background and fill details
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
    
    // Returns TRUE or FALSE from decimal percent bias input
    // e.g. yesNoBool(Bias: 0.7) will generate random Yes/No with 70% bias to yes
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
            yesNoBias = "Yes"
            yesNoColor1 = "YesColor1"
            yesNoColor2 = "YesColor2"
            outputColor = "White"
            questionDisplay.toggle()
            if questionDisplay {
                yesNoBias1 = ""
            }
            else {
                yesNoBias2 = ""
            }
        }
        // No Display
        else {
            yesNoBias = "No"
            yesNoColor1 = "NoColor1"
            yesNoColor2 = "NoColor2"
            outputColor = "White"
            // Clear input for new question.
            questionDisplay.toggle()
            if questionDisplay {
                yesNoBias1 = ""
            }
            else {
                yesNoBias2 = ""
            }
        }
    }
}


// MARK: - This is for previews
struct UserPanel_Previews: PreviewProvider {
    static var previews: some View {
        UserPanel()
    }
}
