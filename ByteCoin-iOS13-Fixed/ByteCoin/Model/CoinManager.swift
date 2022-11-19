//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Cameron Mundorff 05/14/22.
//
import Foundation

protocol CoinManagerDelegate {
    //Create the method stubs wihtout implementation in the protocol.
    //It's usually a good idea to also pass along a reference to the current class.
    //e.g. func didUpdatePrice(_ coinManager: CoinManager, price: String, currency: String)
    //Check the Clima module for more info on this.
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    var delegate: CoinManagerDelegate?
    
    // https://rest.coinapi.io/v1/exchangerate/BTC/USD?apikey=9261CB14-9611-47CD-836E-4822724857A0
    let baseURL = "https://rest.coinapi.io/v1/exchangerate"
    let apiKey = "9261CB14-9611-47CD-836E-4822724857A0"
    
    let currencyArray = ["AUD","BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR","BTC"]

    func getCoinPrice(for currency: String) {
                let urlString = "\(baseURL)/\(currency)/USD?apikey=\(apiKey)"
                if let url = URL(string: urlString) {
                    let session = URLSession(configuration: .default)
                                let task = session.dataTask(with: url) { (data, response, error) in
                                    if error != nil {
                                        self.delegate?.didFailWithError(error: error!)
                                        return
                                    }
                                    
                                    if let safeData = data {
                                        
                                        if let bitcoinPrice = self.parseJSON(safeData) {
                                            //Optional: round the price down to 2 decimal places.
                                            let priceString = String(format: "%.5f", bitcoinPrice)
                                            
                                            //Call the delegate method in the delegate (ViewController) and
                                            //pass along the necessary data.
                                            self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                                        }
                                    }
                                }
                                task.resume()
                            }
                        }
    
    func parseJSON(_ data: Data) -> Double?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            
            return lastPrice
        } catch {
                print(error)
                return nil
        }
    }
}
