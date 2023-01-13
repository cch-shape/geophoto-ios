//
//  HomeView.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 8/1/2023.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var user: UserModel
    
    var body: some View {
        Text(UserModel.User.currentUser?.phone_number ?? "")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
