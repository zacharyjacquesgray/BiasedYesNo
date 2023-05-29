//
//  YesNoMain.swift
//  YesNo
//
//  Created by Zachary-Jacques Gray of Island Société on 27/1/2023.
//

import SwiftUI
import SQLite3
import Combine
import AppTrackingTransparency
import GoogleMobileAds


struct YesNoMain: View {
    
    // MARK: VARIABLES
    // NAVIGATION
    @State private var tabSelect = 1 // Landing Tab -- Home = 1
    @State private var confirmationShow = false // Shows confirmation box
    @State private var bannerAdOn:Bool = true // Ads on by default
    
    // YES-NO FUNCTIONALITY DEFAULT STRINGS
    @State private var yesNo:String = ""
    @State private var yesNoBias:String = ""
    @State private var yesNoBias1:String = ""
    @State private var yesNoBias2:String = ""
    @State private var yesNoColor1:String = "BackgroundColor"
    @State private var yesNoColor2:String = "BackgroundColor"
    @State private var outputColor:String = "HeadingColor"
    @State private var weightColor:String = "BackgroundColor"
    
    // YES-NO FUNCTIONALITY
    @State var isTapped:Bool = false
    @State var questionDisplay:Bool = false
    @State var newWeight: Double = 0.5
    @State var isBlacklist:Bool = false
    @State var bias:Double = 0.50 // Biased 50% Yes by default
    
    // TEXTFIELD AND KEYBOARD
    @FocusState private var isFocused: Bool // if true, TextField will activate
    @State private var isKeyboardVisible = false
    @State private var verticalPadding:CGFloat = 21.0
    
    // TERMS OF USE
    @State private var showTerms = false
    @State private var openTerms = false
    @State private var acceptTerms = UserDefaults.standard.bool(forKey: "acceptTerms") // initialise terms of service as not being accepted. Will switch to true once accepted.
    @State var tipString: String? // For tip alert
    
    // SQLITE3 LOCAL STORAGE
    @State private var dataVersion:Int = UserDefaults.standard.integer(forKey: "dataVersion")
    let versionNum:Int = 1 // Update for new versions of data input
    @State private var weighting_i = [String]()
    @State private var weighting_j = [String]()
    @State private var blacklist = [String]()
    @State private var db: OpaquePointer? // Yes-No Main
    @State private var db_feed: OpaquePointer? // Feed
    
    // ASSIGN VALUES
    let bias50:Double = 0.5
    let systemFont = "Helvetica Neue Condensed Bold"
    
    // MARK: UI VIEWS:
    var body: some View {
        TabView(selection: $tabSelect) {
            
            // MARK: 50 / 50
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
                            text3d(yesNo, 70)
                        }
                    }
                }
                // MARK: Ad Here
                VStack {
                    Spacer()
                    if bannerAdOn {
                        SwiftUIBannerAd(bannerID: "ca-app-pub-3940256099942544/6300978111", width: UIScreen.main.bounds.width)
                    }
                }
            }
            .onAppear {
                // yesNoColor1 = "BackgroundColor"
                // yesNoColor2 = "BackgroundColor"
                yesNo = "YES  /  NO"
                outputColor = "HeadingColor"
                
                yesNoColor1 = "UserPanelGrad1"
                yesNoColor2 = "UserPanelGrad2"
                
                isBlacklist = false
            }
            .tabItem {
                Image(systemName: "circle.righthalf.filled")
                Text("50 / 50")
            }
            .tag(0)
            
            // MARK: YES OR NO MAIN
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
                            TextField("Yes or No ?", text: questionDisplay ? $yesNoBias1 : $yesNoBias2) { status in
                                // Triggered when text field is clicked
                                withAnimation(.easeIn) {
                                    isTapped = status
                                }
                            } onCommit: {
                                if acceptTerms {
                                    // Triggered when return key is pressed
                                    withAnimation(.easeOut) {
                                        isTapped = false
                                    }
                                    loadResult(question: questionDisplay ? yesNoBias1 : yesNoBias2)
                                } else {
                                    showTerms = true
                                }
                            }
                            
                            .onChange(of: questionDisplay ? yesNoBias1 : yesNoBias2) { value in
                                // Triggered when the value of the text field changes
                                let charLimit = 75
                                if value.count > charLimit {
                                    if questionDisplay {
                                        yesNoBias1 = String(value.prefix(charLimit))
                                    } else {
                                        yesNoBias2 = String(value.prefix(charLimit))
                                    }
                                }
                            }
                            .font(.custom(systemFont, size: 35))
                            .font(.headline)
                            .accentColor(Color(outputColor))
                            .fontWeight(.bold)
                            .tracking(0.5)
                            .padding(.horizontal, 25)
                            .focused($isFocused) // Ensure that keyboard always shows in the view
                            
                            Spacer()
                            // Enter button to generate Yes/No. Alternate method to hitting the return key.
                            
                            Button(action: {
                                if acceptTerms {
                                    let input = questionDisplay ? yesNoBias1 : yesNoBias2
                                    if !input.isEmpty {
                                        loadResult(question: input)
                                    } else {
                                        let tempBias = yesNoBias1
                                        yesNoBias1 = yesNoBias2
                                        yesNoBias2 = tempBias
                                        loadResult(question: questionDisplay ? yesNoBias1 : yesNoBias2)
                                    }
                                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium) // .medium, .light, .heavy, .rigid, or .soft
                                    impactFeedbackgenerator.impactOccurred()
                                } else {
                                    showTerms = true
                                }
                            }) {
                                Image(systemName: "arrow.up.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:35, height: 35)
                            }
                            .padding(.horizontal, 15)
                        }
                        .foregroundColor(Color(outputColor))
                        .padding(.top, isKeyboardVisible ? 257 : (UIDevice.current.userInterfaceIdiom == .phone ? 257 : verticalPadding))
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                            self.isKeyboardVisible = true
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
                            self.isKeyboardVisible = false
                        }
                        .onAppear {
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { notification in
                                    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                                        return
                                    }
                                    self.verticalPadding = keyboardFrame.height > 0 ? 21 : 257
                                }
                            }
                        }
                        
                        Spacer()
                        Spacer()
                        
                        
                        // Text at bottom of screen showing percentage.
                        HStack {
                            HStack {
                                if isBlacklist {
                                    Text("The question includes potentially sensitive content")
                                    Image(systemName: "exclamationmark.triangle.fill")
                                } else {
                                    Text("\(Int(round(newWeight * 100)))%")
                                    Image(systemName: "hand.thumbsup.fill")
                                }
                            }
                            .font(.custom(systemFont, size: 25))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(weightColor))
                            .padding(.leading, 7)
                            
                            Spacer()
                            
                            // MARK: Terms of Use
                            Button(action: {
                                openTerms = true
                                tipCarousel { tip, error in // For random alert text
                                    if let tip = tip {
                                        tipString = tip
                                    } else if error != nil {}
                                }
                            }) {
                                Image(systemName: "info.circle")
                                    .opacity(0.5)
                                    .foregroundColor(Color(outputColor))
                                    .font(.custom(systemFont, size: 18))
                            }
                            .alert(tipString ?? "", isPresented: $openTerms) {
                                Button("View terms of use", action: {
                                    showTerms = true
                                })
                                Button("Send feedback", action: {
                                    if let emailURL = URL(string: "mailto:biasedyesno@islandtechnologies.space") {
                                                UIApplication.shared.open(emailURL)
                                            }
                                })
                                Button("Dismiss", role: .cancel, action: {})
                            }
                            .sheet(isPresented: $showTerms) {
                                TermsOfService()
                                    .padding(.bottom,10)
                                HStack {
                                    Spacer()
                                    Button(action:{
                                        showTerms = false
                                    }) {
                                        Text("Dismiss")
                                            .foregroundColor(.red)
                                    }
                                    Spacer()
                                    Spacer()
                                    Button(action:{
                                        UserDefaults.standard.set(true, forKey: "acceptTerms") // store user response for future uses of app
                                        acceptTerms = true // flag that terms of service have been accepted.
                                        showTerms = false
                                    }) {
                                        Text("Accept")
                                            .bold()
                                            .foregroundColor(.blue)
                                    }
                                    Spacer()
                                }
                                .padding(.bottom, 20)
                            }
                            .padding(.trailing, 14)
                        }
                        
                        
                        // MARK: Ad Here
                        HStack {
                            Spacer()
                            if bannerAdOn {
                                SwiftUIBannerAd(bannerID: "ca-app-pub-3940256099942544/6300978111", width: UIScreen.main.bounds.width)
                            }
                            Spacer()
                        }
                    }
                }
                
                VStack (alignment: .leading) {
                    HStack {
                        Spacer()
                        text3d("BIASED YES NO .ai", 30)
                        Spacer()
                    }
                    // if-else toggles displaying the input of the user once entered.
                    Text(questionDisplay ? yesNoBias2 : yesNoBias1)
                        .padding(.leading, 25.0)
                        .padding(.trailing, 35)
                        .font(.custom(systemFont, size: 31))
                        .font(.headline)
                        .fontWeight(.bold)
                        .tracking(0.4)
                        .foregroundColor(Color(outputColor))
                    
                    // HStack is the output Yes-No based on input question above
                    HStack {
                        Spacer()
                        Text(yesNoBias)
                            .padding([.leading, .trailing], 25.0)
                            .padding(.top, 4.7)
                            .font(.custom(systemFont, size: 31))
                            .font(.headline)
                            .fontWeight(.bold)
                            .tracking(0.4)
                            .foregroundColor(Color(outputColor))
                    }
                    
                    Spacer()
                    
                }
                .font(.headline)
                .tracking(0.4)
            }
            .onTapGesture {
                // Activate TextField and show keyboard
                isFocused.toggle()
            }
            .onAppear {
                // load SQLite Table
                if let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("myDatabase.sqlite") {
                    if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                        print("error opening database")
                    }
                    let clock = ContinuousClock()
                    
                    let result = clock.measure(createTable) // run createTable function but measure time elapsed
                    print("time elapsed: \(result)")
                    //createTable()
                } else {
                    print("error creating file URL")
                }
                
                // initialise variables
                yesNoColor1 = "BackgroundColor"
                yesNoColor2 = "BackgroundColor"
                outputColor = "HeadingColor"
                weightColor = "BackgroundColor"
                yesNoBias = ""
                yesNoBias1 = ""
                yesNoBias2 = ""
                isTapped = false
                questionDisplay = false
                newWeight = 0.5
                weighting_i = [String]()
                weighting_j = [String]()
                bias = bias50
            }
            .onDisappear {
                sqlite3_close(db)
            }
            .tabItem {
                Image(systemName: "questionmark.bubble")
                Text("ASK")
            }
            .tag(1)
        }
        .onAppear() {
            //UITabBar.appearance().barTintColor = .white
            UITabBar.appearance().backgroundColor = UIColor(Color("BackgroundColor"))}
        .accentColor(Color("HeadingColor"))
        
    }
    
    // MARK: FUNCTIONS:
    // -------------------- FUNCTIONS -------------------- //
    
    func text3d(_ text: String, _ fontsize: Double) -> some View {
        // MARK: text3d()
        let TextRatio = 0.03
        return ZStack{
            ForEach(0...Int(fontsize), id: \.self) { index in
                Text(text)
                    .foregroundColor(.black)
                    .padding([.leading,.top], Double(index) * 0.2)
            }
            Text(text)
                .foregroundColor(.black)
                .padding([.trailing,.bottom], TextRatio * CGFloat(fontsize))
            Text(text)
                .foregroundColor(.black)
                .padding([.trailing], TextRatio * CGFloat(fontsize))
            Text(text)
                .foregroundColor(.black)
                .padding([.bottom], TextRatio * CGFloat(fontsize))
            Text(text)
                .foregroundColor(.black)
                .padding([.leading], TextRatio * CGFloat(fontsize))
            Text(text)
                .foregroundColor(.black)
                .padding([.top], TextRatio * CGFloat(fontsize))
            Text(text)
                .foregroundColor(.white)
        }
        .font(.custom(systemFont, fixedSize: fontsize))
        
    }
    
    func textOutline(_ text: String, _ fontsize: Double) -> some View {
        // MARK: textOutline()
        let TextRatio = 0.03
        return ZStack{
            ForEach(0...Int(0.47*fontsize), id: \.self) { index in
                Text(text)
                    .foregroundColor(.black)
                    .padding([.leading,.top], Double(index) * 0.2)
            }
            Text(text)
                .foregroundColor(.black)
                .padding([.trailing,.bottom], TextRatio * CGFloat(fontsize))
            Text(text)
                .foregroundColor(.black)
                .padding([.trailing], TextRatio * CGFloat(fontsize))
            Text(text)
                .foregroundColor(.black)
                .padding([.bottom], TextRatio * CGFloat(fontsize))
            Text(text)
                .foregroundColor(.black)
                .padding([.leading], TextRatio * CGFloat(fontsize))
            Text(text)
                .foregroundColor(.black)
                .padding([.top], TextRatio * CGFloat(fontsize))
            Text(text)
                .foregroundColor(.white)
        }
        .font(.custom(systemFont, fixedSize: fontsize))
        
    }
    
    func biasOutput(question: String) -> Double{
        // MARK: biasOutput()
        // Calls to database and obtains bias for question
        // Create calculation for bias from database
        loadWeightings(question: question,
                       completion: { result, error in
            if let error = error {
                print("Error loading weightings: \(error.localizedDescription)")
            } else if let result = result {
                newWeight = Double(result)
            }
        }, completion_sensitive: { result, error in
            if let error = error {
                print("Error loading sensitive: \(error.localizedDescription)")
            } else if let result = result {
                // Assigning if value is sensitive
                isBlacklist = Double(result) >= 1
            }
        })
        // run
        if newWeight < 0 {
            return 0
        } else if newWeight > 1 {
            return newWeight
        } else {
            return newWeight
        }
    }
    
    
    func YesNo(x:Double) {
        // MARK: YesNo()
        // Returns if random bias returns TRUE or FALSE, and then provides this to yesNoDisplay to change display for YES or NO respectively
        // YesNo()
        let isYesNo = yesNoBool(Bias: x)
        yesNoDisplay(isYesNo)
    }
    
    // Returns TRUE or FALSE from decimal percent bias input
    // e.g. yesNoBool(Bias: 0.7) will generate random Yes/No with 70% bias to yes
    func yesNoBool(Bias:Double) -> Bool{
        // MARK: yesNoBool()
        let randomNum = Double.random(in: 0...1)
        var isYes: Bool
        isYes = randomNum < Bias
        return isYes
    }
    
    // Changes to display based on YES/TRUE or NO/FALSE
    func yesNoDisplay(_ Yes:Bool) {
        // MARK: yesNoDisplay()
        if isBlacklist {
            yesNoBias = ""
            yesNoColor1 = "UserPanelGrad1"
            yesNoColor2 = "UserPanelGrad2"
        } else {
            // Yes-No Display
            yesNoBias = Yes ? "Yes" : "No"
            yesNoColor1 = Yes ? "YesColor1" : "NoColor1"
            yesNoColor2 = Yes ? "YesColor2" : "NoColor2"
        }
        yesNo = Yes ? "YES" : "NO"
        outputColor = "White"
        weightColor = "White"
        questionDisplay.toggle()
        
        // Clear input for new question
        if questionDisplay {
            yesNoBias1 = ""
        }
        else {
            yesNoBias2 = ""
        }
    }
    
    func loadResult(question: String) {
        // MARK: loadResult()
        bias = biasOutput(question: question)
        YesNo(x: bias)
    }
    
    func loadWeightings(question: String, completion: @escaping (Double?, Error?) -> Void, completion_sensitive: @escaping (Double?, Error?) -> Void) {
        // MARK: loadWeightings()
        //var isNot = false // will flag if the word "not" is input to flip weights
        
        let inputString = question
        let simplifiedString = (inputString as NSString).decomposedStringWithCanonicalMapping
        let regex = try! NSRegularExpression(pattern: "[a-zA-Z0-9]+")
        var result: [String] = []
        
        let components = simplifiedString.lowercased().components(separatedBy: .whitespacesAndNewlines)
        for component in components {
            let matches = regex.matches(in: component, range: NSRange(component.startIndex..., in: component))
            for match in matches {
                let substring = (component as NSString).substring(with: match.range)
                result.append(substring)
                //if substring == "not" {
                  //  isNot = true
                //} else
                if substring == "252525" {
                    bannerAdOn = false
                }
            }
        }
        print("input terms \(result)")
        
        result.append("yes_no_key") // This is overall bias toward yes that is relevant for naive Bayes below
        
        // input filtered values and load the corresponding weight from SQLite table
        loadData(forIDs: result)
        
        // Predict weightings - multinomial naive Bayes method (NPL machine learning)
        var weightAverage = bias50
        let weightCount = Int(weighting_i.count)
        print(weightCount)
        if weightCount > 1 {
            var weightiTotal = 1.0 // % initialise yes in dataset
            var weightjTotal = 1.0 // % initialise no in dataset
            for (weighti, weightj) in zip(weighting_i, weighting_j) {
                weightiTotal *= (Double(weighti) ?? 2) / ((Double(weightj) ?? 1) + (Double(weighti) ?? 1))
                weightjTotal *= (Double(weightj) ?? 2) / ((Double(weightj) ?? 1) + (Double(weighti) ?? 1))
                print(weighti)
                print(weightiTotal)
            }
            weightAverage = weightiTotal / (weightiTotal + weightjTotal)
            print("Yes from naive Bayes: \(weightAverage)")

            // To check if word "not" is used to flip meaning.
            /*if isNot {
                weightAverage = 1 - weightAverage
            }*/
        }
        
        // Determine if sensitive
        var ifSensitive: Double = 0
        for sensitive in blacklist {
            ifSensitive += Double(sensitive) ?? 0
        }
        completion(weightAverage, nil)
        completion_sensitive(ifSensitive, nil)
    }
    
    func createTable() {
        // MARK: createTable()
        print("dataVersion: \(dataVersion)")
        
        // Check if the most recent data table is already loaded.
        if dataVersion != versionNum {
            UserDefaults.standard.set(versionNum, forKey: "dataVersion")
            dataVersion = versionNum
            
            // Reset data table, i.e. clear table
            runSQL("DROP TABLE input")
            
            // Create Table
            var createTableStatement: OpaquePointer?
            let createTableString = """
            CREATE TABLE IF NOT EXISTS input(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            weighting_i DOUBLE(3,2),
            weighting_j DOUBLE(3,2),
            sensitive DOUBLE(2,1)
            );
            """
            if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createTableStatement) == SQLITE_DONE {
                    print("TABLE: \"input\" created.")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("Error creating \"input\": \(errmsg)")
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error preparing create table statement: \(errmsg)")
            }
            sqlite3_finalize(createTableStatement)
            if let path = Bundle.main.path(forResource: "YesNo_input", ofType: "csv") {
                do {
                    let data = try String(contentsOfFile: path, encoding: .utf8)
                    var rows = data.components(separatedBy: "\r\n")
                    //print(rows)
                    
                    // Remove headers
                    rows.removeFirst()
                    
                    for row in rows {
                        let trimmedRow = row.trimmingCharacters(in: .whitespacesAndNewlines)
                        let values = trimmedRow.components(separatedBy: ",")
                        if values.count == 1 && values[0].isEmpty {
                            continue
                        }
                        let name = values[1]
                        let weightingi = Double(values[2]) ?? 0.0 // Convert the weighting column to Double, default to 0.0 if conversion fails
                        let weightingj = Double(values[3]) ?? 0.0 // Convert the weighting column to Double, default to 0.0 if conversion fails
                        let sensitive = Double(values[4]) ?? 0.0
                        let insertStatementString = "INSERT INTO  input (name, weighting_i, weighting_j, sensitive) VALUES (?, ?, ?, ?);"
                        var insertStatement: OpaquePointer?
                        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                            sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)
                            sqlite3_bind_double(insertStatement, 2, weightingi)
                            sqlite3_bind_double(insertStatement, 3, weightingj)
                            sqlite3_bind_double(insertStatement, 4, sensitive)
                            if sqlite3_step(insertStatement) == SQLITE_DONE {
                                print("Row added: \(name), \(weightingi), \(weightingj), \(sensitive)")
                            } else {
                                print("Row could not be added.")
                            }
                        } else {
                            print("Insert statement could not be prepared.")
                        }
                        sqlite3_finalize(insertStatement)
                    }
                } catch {
                    print("Failed to read YesNo_input.csv file")
                }
                
            } else {
                print("YesNo_input.csv file not found")
            }
        }
    }
    
    func loadData(forIDs ids: [String]) { // obtains weighting and sensitive flags from SQL Table
        // MARK: loadData()
        let idList = ids.map { "'\($0)'" }.joined(separator: ",")
        let queryStatementString = "SELECT weighting_i, weighting_j, sensitive FROM input WHERE name IN (\(idList));"
        var queryStatement: OpaquePointer?
        print(queryStatementString)
        
        weighting_i.removeAll()
        weighting_j.removeAll()
        blacklist.removeAll()
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let weighti = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                weighting_i.append(weighti)
                let weightj = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                weighting_j.append(weightj)
                let sensitive = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                blacklist.append(sensitive)
            }
        } else {
            print("Error loading data: \(String(describing: sqlite3_errmsg(queryStatement)))")
        }
        sqlite3_finalize(queryStatement)
    }
    
    func runSQL(_ query: String) {  //  runs SQL query for Yes No Main
        // MARK: runSQL("Enter query")
        if let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("myDatabase.sqlite") {
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("error opening database")
            }
            print("runSQL(): \(query)")
            var errMsg: UnsafeMutablePointer<Int8>?
            if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
                let message = errMsg != nil ? String(cString: errMsg!) : "unknown error"
                print("Error deleting input table: \(message)")
            }
        } else {
            print("error creating file URL")
        }
    }
    
    
    func tipCarousel(completion: @escaping (String?, Error?) -> Void) {
        // MARK: tipCarousel()
        var tip = ""
        
        let randomInt = Int.random(in: 1...2) // randomly show tip
        
        if randomInt == 1 {
            tip = "TIP: Click the microphone on the keyboard to ask questions with your voice."
        } else if randomInt == 2 {
            tip = "NOTE: We use AI and machine learning on responses. Answers should not be taken seriously."
        }
        
        completion(tip, nil)
    }
    
}


// MARK: This is for previews
struct YesNoMain_Previews: PreviewProvider {
    static var previews: some View {
        YesNoMain()
    }
}
