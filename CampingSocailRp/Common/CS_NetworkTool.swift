//
//  CS_NetworkTool.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import Foundation
import SVProgressHUD

let URL_BASE = "https://api.fiveukmedia.xyz"

enum CS_NetworkError: Error {
    case invalidURL
    case encodingFailed
    case noData
    case httpStatus(Int)
    case timeout
    case underlying(Error)
}

/// 通用网络请求（POST JSON）
final class CS_NetworkTool {

    static let shared = CS_NetworkTool()

    private static let afdPath = "/le/afd/"
    private static let requestTimeout: TimeInterval = 30

    private static let defaultAFDParameters: [String: String] = [
        "five": "66781AB9-7605-4AF8-9163-68D689792A93",
        "six": "1779788860268",
        "nine": "4450c8fb84d0cb7d9191921af247eceb942e63c33a65d7ee60a6cd80fc194442"
    ]

    private init() {}

    /// POST `URL_BASE` + `/le/afd/`，使用默认参数 five / six / nine
    func postAFD(completion: @escaping (Result<Data, CS_NetworkError>) -> Void) {
        post(
            path: Self.afdPath,
            parameters: Self.defaultAFDParameters,
            completion: completion
        )
    }

    /// POST JSON 请求
    func post(
        path: String,
        parameters: [String: String],
        completion: @escaping (Result<Data, CS_NetworkError>) -> Void
    ) {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }

        let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
        guard let url = URL(string: URL_BASE + normalizedPath) else {
            CS_NetworkTool.finish(.failure(.invalidURL), completion: completion)
            return
        }

        var request = URLRequest(url: url, timeoutInterval: Self.requestTimeout)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            CS_NetworkTool.finish(.failure(.encodingFailed), completion: completion)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                let nsError = error as NSError
                if nsError.code == NSURLErrorTimedOut {
                    CS_NetworkTool.finish(.failure(.timeout), completion: completion)
                } else {
                    CS_NetworkTool.finish(.failure(.underlying(error)), completion: completion)
                }
                return
            }

            if let http = response as? HTTPURLResponse,
               !(200 ... 299).contains(http.statusCode) {
                CS_NetworkTool.finish(.failure(.httpStatus(http.statusCode)), completion: completion)
                return
            }

            guard let data else {
                CS_NetworkTool.finish(.failure(.noData), completion: completion)
                return
            }

            CS_NetworkTool.finish(.success(data), completion: completion)
        }.resume()
    }

    // MARK: - Private

    private static func finish(
        _ result: Result<Data, CS_NetworkError>,
        completion: @escaping (Result<Data, CS_NetworkError>) -> Void
    ) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            completion(result)
        }
    }
}
