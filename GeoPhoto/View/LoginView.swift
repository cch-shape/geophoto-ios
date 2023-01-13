//
//  LoginView.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 13/1/2023.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var user: UserModel
    @State var phoneNumber: String = ""
    @FocusState var phoneNumberFocus: Bool
    @State var code: String = ""
    @FocusState var codeFocus: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text(user.verificationCode.isEmpty ? "Login" : user.verificationCode)
                .font(.system(size: 45))
                .padding()
            
            if user.verificationCode.isEmpty {
                TextField("Enter your phone number", text: $phoneNumber)
                    .keyboardType(.decimalPad)
                    .padding()
                    .multilineTextAlignment(.center)
                    .background(Color(UIColor.secondarySystemBackground))
                    .focused($phoneNumberFocus)
                
                if !phoneNumber.isEmpty {
                    Button("Get Verification Code", action: {
                        phoneNumberFocus = false
                        user.askVerificationCode(phoneNumber: phoneNumber)
                    })
                    .padding()
                }
            } else {
                TextField("Enter verification code", text: $code)
                    .keyboardType(.decimalPad)
                    .padding()
                    .multilineTextAlignment(.center)
                    .background(Color(UIColor.secondarySystemBackground))
                    .focused($codeFocus)
                
                if !code.isEmpty {
                    Button("Login", action: {
                        codeFocus = false
                        user.login(phoneNumber: phoneNumber, verificationCode: code)
                    })
                    .padding()
                }
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onReceive(user.$authorizationStatus, perform: { v in
            if v == .loggedIn {
                phoneNumber = ""
                code = ""
            }
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserModel())
    }
}
