//
//  CachedImageView.swift
//  Test Combine
//
//  Created by Koussaïla Ben Mamar on 12/11/2021.
//

import UIKit

// MARK: - ImageView extension for cache management and asynchronous image downloading.
final class CachedImageView: UIImageView {
    private static let imageCache = NSCache<AnyObject, UIImage>()
    
    func loadImage(fromURL imageURL: URL) {
        // Temporary image or maintained if the image URL is not available
        self.image = UIImage(named: "")
        
        if let cachedImage = CachedImageView.imageCache.object(forKey: imageURL as AnyObject) {
            self.image = cachedImage
            self.showLoading()
            return
        }
        
        // Asynchronous image downloading and updating
        DispatchQueue.global().async { [weak self] in
            if let imageData = try? Data(contentsOf: imageURL) {
                if let image = UIImage(data: imageData) {
                    // Image change must be done on the main thread
                    DispatchQueue.main.async {
                        self?.image = image
                        self?.stopLoading()
                    }
                }
            }
        }
    }
}
