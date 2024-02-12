//
//  APIManager.swift
//  RGBApp
//
//  Created by Виталик Молоков on 12.02.2024.
//

import UIKit

class APIManager {
    
    static func fetchColorNameFromAPI(color: UIColor, completion: @escaping (String) -> Void) {
        guard let components = color.cgColor.components, components.count >= 3 else {
            completion("Unknown Color")
            return
        }
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        let urlString = "https://www.thecolorapi.com/id?rgb=\(Int(red * 255)),\(Int(green * 255)),\(Int(blue * 255))"
        guard let url = URL(string: urlString) else {
            completion("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion("Error fetching color")
                }
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let name = jsonResult["name"] as? [String: Any],
                   let value = name["value"] as? String {
                    DispatchQueue.main.async {
                        completion(value)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion("Color Not Found")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion("Error parsing color")
                }
            }
        }
        task.resume()
    }
    
    static func translateTextWithYandexTranslateAPI(text: String, sourceLanguageCode: String, targetLanguageCode: String, completion: @escaping (String?, Error?) -> Void) {
        let urlString = "https://translate.api.cloud.yandex.net/translate/v2/translate"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "InvalidURL", code: -1, userInfo: nil))
            return
        }

        let requestBody: [String: Any] = [
            "sourceLanguageCode": sourceLanguageCode,
            "targetLanguageCode": targetLanguageCode,
            "format": "PLAIN_TEXT",
            "texts": [text],
            "folderId": "b1gp6l699dkir4aujacd"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Api-Key AQVNzP4UtnwpUTSfmyEbg12s2_U0_mlL_Avgx5us", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(nil, error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let translations = jsonResponse["translations"] as? [[String: Any]],
                   let firstTranslation = translations.first,
                   let translatedText = firstTranslation["text"] as? String {
                    DispatchQueue.main.async {
                        completion(translatedText, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "ParsingError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Expected fields not found in the response"]))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}
