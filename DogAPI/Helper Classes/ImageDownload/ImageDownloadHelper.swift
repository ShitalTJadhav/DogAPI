//
//  ImageDownloadHelper.swift
//
//  Created by shital on 20/06/2018.
//

import Foundation
import UIKit
import ObjectiveC

protocol ImageDownloadHelperProtocol {
    func download(url: URL, completion: @escaping (UIImage?, URLResponse?, Error?) -> ())
}

class ImageDownloadHelper: ImageDownloadHelperProtocol {
    let urlSession: URLSession = URLSession.shared

    static var shared: ImageDownloadHelper = {
        return ImageDownloadHelper()
    }()

    func download(url: URL, completion: @escaping (UIImage?, URLResponse?, Error?) -> ()) {
        urlSession.dataTask(with: url) { data, response, error in
            if let data = data {
                completion(UIImage(data: data), response, error)
            } else {
                completion(nil, response, error)
            }
        }.resume()
    }
}
