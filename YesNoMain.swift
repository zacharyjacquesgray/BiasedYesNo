//
//  YesNoMain.swift
//  YesNo
//
//  Created by Zachary-Jacques Gray of Island Société on 27/1/2023.
//

import SwiftUI


// start addition
struct Weight {
    let weighting: Double

    init(dictionary: [String: Any]) {
        if let weightingValue = dictionary["weighting"] as? Double {
            self.weighting = weightingValue
        } else if let weightingString = dictionary["weighting"] as? String, let weightingValue = Double(weightingString) {
            self.weighting = weightingValue
        } else {
            self.weighting = 0.0
        }
    }
}


extension String {
    func toJSONWeight() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

// end weight addition




struct YesNoMain: View {
    
    // STATE VARIABLES
    @State var selectedTab: Tabs = .yesNoMain
    @State private var yesNoBias:String = ""
    @State private var yesNoBias1:String = ""
    @State private var yesNoBias2:String = ""
    @State private var yesNoColor1:String = "BackgroundColor"
    @State var yesNoColor2:String = "BackgroundColor"
    @State private var outputColor:String = "HeadingColor"
    
    @State var isTapped:Bool = false
    @State var questionDisplay:Bool = false
    @State var outputText = ""
    
    // For MYSQL-PHP
    @State private var jsonData = "Loading JSON data..."
    let baseURL = "http://islandtechnologies.co/SQLoutputMultiple.php"
    
    @State private var postData = "function=mySQLFunction&param1=yes"
    
    
    
    
    
    // VARIABLES
    @State var bias:Double = 0.50 // Biased 50% Yes by default
    let bias50:Double = 0.5
    
    // Remove Navigation Animation when switching views.
    init(){
        UINavigationBar.setAnimationsEnabled(false)
    }
    
    var body: some View {
        
        NavigationView {
            // Look into TabView??
            
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
                                    bias = biasOutput(question: yesNoBias1)
                                    YesNo(x: bias)
                                    //loadData(parameters: ["param1": yesNoBias1]) // testing
                                    loadWeightings(question: yesNoBias1) { result in
                                                    if let result = result {
                                                        outputText = result
                                                    }
                                                }
                                }
                                .font(.custom("Arial Bold", size: 35))
                                .foregroundColor(Color(outputColor))
                                .bold()
                                .padding(.horizontal, 25)
                            }
                            else
                            {
                                TextField("Yes or No ?",text: $yesNoBias2) {
                                    
                                    (status) in
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
                                    bias = biasOutput(question: yesNoBias2)
                                    YesNo(x: bias)
                                    //loadData(parameters: ["param1": yesNoBias2]) // testing
                                    loadWeightings(question: yesNoBias2) { result in
                                                    if let result = result {
                                                        outputText = result
                                                    }
                                                }
                                    
                                }
                                .font(.custom("Arial Bold", size: 35))
                                .foregroundColor(Color(outputColor))
                                .bold()
                                .padding(.horizontal, 25)
                            }
                            Spacer()
                            // Enter button to generate Yes/No. Alternate method to hitting the return key.
                            Button(action: {
                                if questionDisplay {
                                    bias = biasOutput(question: yesNoBias1)
                                    //loadData(parameters: ["param1": yesNoBias1]) // testing
                                    loadWeightings(question: yesNoBias1) { result in
                                                    if let result = result {
                                                        outputText = result
                                                    }
                                                }
                                }
                                else {
                                    bias = biasOutput(question: yesNoBias2)
                                    //loadData(parameters: ["param1": yesNoBias2]) // testing
                                    loadWeightings(question: yesNoBias1) { result in
                                                    if let result = result {
                                                        outputText = result
                                                    }
                                                }
                                }
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
                        
                        Text("JSON: \(outputText)")
                            .padding()
                            .font(.custom("Arial", size: 20))
                            .foregroundColor(.white)
                        
                        
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
                            .padding(.leading, 25.0)
                            .padding([.top,.trailing], 35)
                            .font(.custom("Arial Bold", size: 30))
                            .foregroundColor(Color(outputColor))
                            .bold()
                    } else {
                        Text(yesNoBias1)
                            .padding(.leading, 25.0)
                            .padding([.top,.trailing], 35)
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
                        
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    // Calls to database and obtains bias for question
    func biasOutput(question: String) -> Double{
        // Temporary data while connecting to database is not working yet.
        if (question == "Yes or no? ") {
            return 0.5
        }
        else if (question == "Should I eat ?") {
            return 0.7
        }
        // if blank, return the same probability as the last entered question.
        else if (question == "") {
            return bias
        }
        // if unknown query, return 50/50
        else {
            return 0.5
        }
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
            yesNoBias = "Yes:  \(outputText)"
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
            yesNoBias = "No:  \(outputText)"
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
    
    func loadData(parameters: [String: String], completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)") else {
            print("Invalid URL")
            completion(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        var postData = "function=mySQLFunction"
        for (key, value) in parameters {
            postData += "&\(key)=\(value)"
        }

        request.httpBody = postData.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil, error)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil, nil)
                return
            }

            completion(data, nil)
        }.resume()
    }

    func loadWeightings(question: String, completion: @escaping (String?) -> Void) {
        let keywords = question.split(separator: " ")
        var parameters = [String: String]()
        for (index, keyword) in keywords.enumerated() {
            parameters["param\(index + 1)"] = String(keyword)
        }

        loadData(parameters: parameters) { data, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                let decodedData = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonArray = decodedData as? [[String: Any]] {
                    DispatchQueue.main.async {
                        let weightings = jsonArray.compactMap { dictionary -> Double? in
                            if let weighting = dictionary["weighting"] as? String {
                                return Double(weighting)
                            }
                            return nil
                        }
                        let weightingsString = weightings.map { String($0) }.joined(separator: ", ")
                        
                        let weights = jsonArray.map { Weight(dictionary: $0) }
                        
                        let total = weights.reduce(0) { $0 + $1.weighting }
                        
                        let jsonString = "\(total) || \(weightingsString) || \(jsonArray)"
                        completion(jsonString)
                    }
                }

            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }
    }

    



}



// MARK: - This is for previews
struct YesNoMain_Previews: PreviewProvider {
    static var previews: some View {
        YesNoMain()
    }
}

/*
 -------- NOTES -----------------------------
 - Use negation codes so that the inverse is also registered.
 - Includes 'no', 'not', '__n't', and opposites (e.g. smart and dumb). Also synonyms
 - E.g. if 'Am I smart?' is 70% biased:
 > Am I dumb? = 30%
 > Am I intelligent? = 70%
 > Am I not smart? = 30%
 
 - If no input entered, but button is pressed, use 50%/50% Yes-No.
 
 - Gamify user panel, show red or green of what majority chose for either no/yes. Test to incentivise what keeps people doing more.
 - Find appropriate percentage and variability of yes/no to show. If needed can show opposite wording to keep people going.
 - In theory this should keep people going since they want to be right (in the majority). However also want to ensure that people will stay on because if they keep seeing no it might mean they don't trust the bias.
 
 - Use econometric analysis to add weightings to each word.
 - E.g. see if using the word "Should" increases likelihood of yes or no. If not significant, then can be a null word that gets ignored on analysis. If significant, then combines with other words.
 - Need to filter random typing into input field.
 - Cache entire dictionary of entries to phone with each value. Should be about 1-5Mb.
 
 */
