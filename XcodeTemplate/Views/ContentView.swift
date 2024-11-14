//
//  ContentView.swift
//  XcodeTemplate
//
//  Created by ny on 11/14/24.
//

import SwiftUI

import Defaultable
import DefaultableFoundation

extension Bundle {
    var devTeam: String { object<String>(for: "DEVTEAM") }
}

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Display Name:")
            Text(Bundle.main.displayName)
            Text("Marketing Version:")
            Text(Bundle.main.shortVersion)
            Text("Version:")
            Text(Bundle.main.version)
            Text("Bundle Identifier:")
            Text(Bundle.main.identifier)
            Text("Development Team: (custom key)")
            Text(Bundle.main.devTeam)
            Text("App Category:")
            Text(Bundle.main.appCategoryType)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
