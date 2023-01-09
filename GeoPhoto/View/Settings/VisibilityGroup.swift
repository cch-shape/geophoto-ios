//
//  VisibilityGroup.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 9/1/2023.
//

import SwiftUI

struct VisibilityGroup: View {
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        Form {
            if editMode?.wrappedValue.isEditing != true {
                ForEach(0...4, id: \.self) { _ in
                    Section (
                        header: HStack {
                            Text("Family")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.primary)
                        }
                    ) {
                        ForEach(0...3, id: \.self) { _ in
                            HStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 35.0, height: 35.0)
                                    .clipShape(Circle())
                                    .padding(.trailing, 10)
                                VStack(alignment: .leading) {
                                    Text("+852 98765432")
                                        .foregroundColor(.secondary)
                                        .font(.callout)
                                    Text("Chan")
                                }
                                .multilineTextAlignment(.leading)
                            }
                        }
                        .onDelete(perform: { _ in
                            print("delete")
                        })
                        .onMove(perform: { _, _ in
                            print("move")
                        })
                        Button {
                            print("add")
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                Spacer()
                            }
                        }
                    }
                    .textCase(nil)
                }
            } else {
                Section ("Groups") {
                    ForEach(0...4, id: \.self) { _ in
                        HStack {
                            Text("Family")
                                .bold()
                            Spacer()
                            Button {
                                print("edit name")
                            } label: {
                                Image(systemName: "pencil")
                            }
                        }
                    }
                    .onDelete(perform: { _ in
                        print("delete group")
                    })
                    .onMove(perform: { _, _ in
                        print("move group")
                    })
                    Button {
                        print("add")
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                            Spacer()
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Visibility Groups")
                    .bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
}

struct VisibilityGroup_Previews: PreviewProvider {
    static var previews: some View {
        VisibilityGroup()
    }
}
