//
//  TabBarButton.swift
//  YesNo
//
//  Created by Zachary-Jacques Gray of Island Société on 27/1/2023.
//

import SwiftUI

struct TabBarButton: View {
    
    var buttonText: String
    var imageName: String
    var isActive: Bool
    var lineColor: String
    //var numView: Int

    var body: some View {
        
        GeometryReader { geo in
            
            if isActive {
                Rectangle()
                    .foregroundColor(Color(lineColor))
                    .frame(width:geo.size.width/1.5, height: 7)
                    .padding(.top,7)
                    .cornerRadius(5)
                    .offset(y: -7)
                    .padding(.horizontal, geo.size.width/6)
            }
        
            //let newView = ContentView()
            //NavigationLink(destination: ContentView()) {
                VStack (alignment: .center, spacing: 4) {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width:25, height: 25)
                    Text(buttonText)
                        .font(.caption2)
                        .bold()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            //}
        }
        .tint(Color("HeadingColor"))
    }
}

struct TabBarButton_Previews: PreviewProvider {
    static var previews: some View {
        TabBarButton(buttonText: "50/50", imageName: "questionmark.circle", isActive: true, lineColor: "YesColor2"/*, numView: 1*/)
    }
}
