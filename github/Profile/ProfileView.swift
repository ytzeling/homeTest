//
//  ProfileView.swift
//  github
//
//  Created by Yong Tze Ling on 30/05/2024.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject private var viewModel: ProfileViewModel
    @State private var showAlert = false
    
    init(username: String) {
        self.viewModel = ProfileViewModel(username: username)
    }
    
    var body: some View {
        VStack {
            RemoteImageView(url: viewModel.imageUrl)
            
            HStack {
                Text(viewModel.followers)
                Text(viewModel.followings)
            }
            
            VStack {
                Text(viewModel.name)
                
                Text(viewModel.company)
            }
            
            
            TextField("Note", text: $viewModel.noteText).padding().textFieldStyle(.roundedBorder)
            
            Button("Save") {
                viewModel.saveNote()
                showAlert = true
            }.alert(isPresented: $showAlert, content: {
                Alert(title: Text("Success Saved!"), dismissButton: .cancel())
            })
            
        }.navigationTitle(viewModel.username)
        .padding()
        .onAppear(perform: {
            viewModel.fetchData()
            viewModel.seenProfile()
        })
    }
}

struct RemoteImageView: View {
    @StateObject private var imageLoader = ImageLoader()
    
    var url: String
    
    var body: some View {
        ZStack {
            if let image = imageLoader.uiimage {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                ProgressView().onAppear(perform: {
                    imageLoader.loadImage(from: url)
                })
            }
            
        }.onChange(of: url, perform: { value in
            imageLoader.loadImage(from: value)
        })
    }
}

class ImageLoader: ObservableObject {
    @Published var uiimage: UIImage?
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.uiimage = UIImage(data: data)
            }
        }.resume()
    }
}
