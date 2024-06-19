//
//  ContentView.swift
//  ExampleAppForVonageSDk
//
//  Created by Mehboob Alam on 07.09.23.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel = ViewDelegate()

    var body: some View {
        VStack {
            Button("Create Session", action: {
                viewModel.createSession()
            })
            Spacer()
            HStack(spacing: 5) {
                Text("File size(seconds): ")
                Text(viewModel.fileSize)
            }
            Spacer()
            Button(action: {
                self.viewModel.call()
            }) {
                Text("Call")
            }
            Spacer()
            Button("Play current Recording", action: {
                self.viewModel.play()
            })
            Spacer()
            Button(action: {
                self.viewModel.hangup()
            }) {
                Text("hangup")
            }
        }
        .padding()
        .alert(isPresented: self._viewModel.projectedValue.showCallAlert) {
            Alert(title: Text("Call Invite!"), primaryButton: .cancel(Text("Answer"), action: {
                self.viewModel.answer()
            }), secondaryButton: .destructive(Text("Reject"), action: {
                self.viewModel.reject()
            }))
        }

    }
}
