//
//  NetworkManager.swift
//  WhatFlower
//
//  Created by Olena Rostovtseva on 19.08.2020.
//  Copyright © 2020 orost. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

struct NetworkManager {
    static let wikipediaURl = "https://en.wikipedia.org/w/api.php"

    static var parameters: [String: String] = [
        "format": "json",
        "action": "query",
        "prop": "extracts|pageimages",
        "exintro": "",
        "explaintext": "",
        "titles": "",
        "indexpageids": "",
        "redirects": "1",
        "pithumbsize": "500"
    ]

    static func getFlowerDescriptionWiki(flowerTitle: String, listener: @escaping (_ wikiResult: WikiResultData) -> Void) {
        parameters["titles"] = flowerTitle
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters)
            .responseJSON { response in
                if response.result.isSuccess {
                    print(response)
                    let jsonData: JSON = JSON(response.result.value!)
                    let pageId: String = jsonData["query"]["pageids"][0].stringValue
                    let flowerDescription = jsonData["query"]["pages"][pageId]["extract"].stringValue
                    let imageString = jsonData["query"]["pages"][pageId]["thumbnail"]["source"].stringValue
                    listener(WikiResultData(imageUrl: imageString, descriptionText: flowerDescription))
                }
            }
    }
}
