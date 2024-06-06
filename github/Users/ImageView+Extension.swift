//
//  UserCell.swift
//  github
//
//  Created by Yong Tze Ling on 30/05/2024.
//

import UIKit

extension UIImageView {
    
    func loadImage(from urlString: String?, inverted: Bool) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.image = nil
            return
        }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    self.image = nil
                    return
                }
                if let image = UIImage(data: data) {
                    if inverted {
                        let temp = CIImage(image: image)
                        if let filter = CIFilter(name: "CIColorInvert") {
                            filter.setValue(temp, forKey: kCIInputImageKey)
                            self.image = UIImage(ciImage: filter.outputImage!)
                        }
                    } else {
                        self.image = image
                    }
                } else {
                    self.image = nil
                }
            }
        }.resume()
    }
}
