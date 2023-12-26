//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation


protocol CurrencyManagerDelegate{
    func didUpdateCurrency(_ weathermanager: CoinManager, coin: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CurrencyManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "8BA0E45B-E715-483A-B5C2-375092BE725B"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String){
        fetchWeather(currency: currency)
        
    }
    func fetchWeather(currency: String){
        //let urlString = "\(baseURL)&q=\(cityName)"
        let urlString = "\(baseURL)/\(currency)/?apikey=\(apiKey)"
        performRequest(urlString: urlString)
        print(urlString)
    }
    
    func performRequest( urlString:String){
        if  let url = URL(string: urlString){
            
            let session = URLSession(configuration: .default)
            
            //let task1 = session.dataTask(with: url, completionHandler:   handle(data:response:error:)   )
            //task1.resume()
            let task = session.dataTask(with: url) { (data, respose, error) in
                if error != nil
                {    print(error!)
                    //self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    let dataString = String(data: safeData,encoding: .utf8)
                    print(dataString!)
                    if  let coin = self.parseJSON(coinData: safeData){
                        self.delegate?.didUpdateCurrency(self,coin: coin)
                    }
                    
                    
                }
            }
            task.resume()
        }}
    
    
    
    func parseJSON(coinData: Data) -> CoinModel? {
        
        let decoder = JSONDecoder()
        do{
            let decoderData = try decoder.decode(CoinData.self, from: coinData)
          
            let  id = decoderData.asset_id_base
            let  rate = String(format: "%.2f", decoderData.rate)
            let  quote = decoderData.asset_id_quote
            
            
            
            let price = CoinModel(asset_id_base: id, asset_id_quote: quote, rate: rate)
            
         
            return price
            
        }catch {
            print(error)
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
