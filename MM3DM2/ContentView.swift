//
//  ContentView.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 20/06/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var options = Options()
    var body: some View {
        VStack {
            MetalView(options: options)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
      }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
