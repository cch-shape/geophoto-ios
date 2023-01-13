//
//  GuardView.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 9/1/2023.
//

import SwiftUI

struct GuardView: View {
    @EnvironmentObject var authentication: BiometricModel
    
    var body: some View {
        VStack {
            Text("GeoPhoto")
                .font(.system(size: 45))
                .padding()
            Button("Unlock to continue", action: {
                authentication.Prompt()
            })
        }
    }
}
