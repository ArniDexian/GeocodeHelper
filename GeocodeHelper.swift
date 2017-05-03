//  The MIT License (MIT)
//
//  Copyright (c) 2015 Arni Dexian
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import CoreLocation
import MapKit

class GeocodePlace: NSObject {
    var name: String?
    var address: String?
    var location: CLLocation?
    var phone: String?
    var url: String?
}

private let MIN_REQUEST_DELAY = 1.0
private let MIN_QUERY_LENGTH = 2

class GeocodeHelper: NSObject {
    static let shared = GeocodeHelper()
    
    var completionHandler: ((_ places: [GeocodePlace]?) -> ())?
    
    var minRequestDelay = MIN_REQUEST_DELAY
    var minQueryLength = MIN_QUERY_LENGTH
    
    fileprivate weak var lastSearch: MKLocalSearch?
    fileprivate var performBlock: PerformAfterClosure?
    fileprivate var cache = NSCache<AnyObject, AnyObject>()
    
    func decode(_ searchTerm: String, completion: @escaping (_ places: [GeocodePlace]?) -> ()) {
        completionHandler = completion
        if searchTerm.characters.count >= minQueryLength {
            cancel()
            if let cached = cachedResult(searchTerm) {
                completeRequest(cached)
            } else {
                performBlock = performAfter(minRequestDelay, closure: {[weak self] () -> Void in
                    self?.startGeocodeSearch(searchTerm)
                })
            }
        } else {
            completeRequest(nil)
        }
    }
    
    func cancel() {
        cancelPerformAfter(performBlock)
        lastSearch?.cancel()
    }
    
    // MARK: Private
    
    fileprivate func completeRequest(_ places: [GeocodePlace]?) {
        completionHandler?(places)
    }
    
    fileprivate func startGeocodeSearch(_ searchTerm: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchTerm
        let search = MKLocalSearch(request: request)
        search.start { [weak self](response, error) -> Void in
            if let err = error {
                self?.didFailDecode(searchTerm, error: err)
            } else {
                let res = response?.mapItems.map{$0.geocoderPlace}
                self?.didDecode(searchTerm, places: res)
            }
        }
        lastSearch = search
    }
    
    fileprivate func didFailDecode(_ searchTerm: String, error: Error!) {
        switch MKError(_nsError: error as NSError).code {
        case .placemarkNotFound:
            fallthrough
        case .directionsNotFound:
            didDecode(searchTerm, places: nil)
        default:
            print("GeocodeHelper error decode \(searchTerm) \(error.localizedDescription)")
        }
    }
    
    fileprivate func didDecode(_ searchTerm: String, places: [GeocodePlace]?) {
        cacheResult(searchTerm, places: places)
        completeRequest(places)
    }
    
    fileprivate func cacheResult(_ searchTerm: String, places: [GeocodePlace]?) {
        let cachePlace = places == nil ? [GeocodePlace]() : places!
        cache.setObject(cachePlace as AnyObject , forKey: searchTerm as AnyObject)
    }
    
    fileprivate func cachedResult(_ searchTerm: String) -> [GeocodePlace]? {
        if let cached = cache.object(forKey: searchTerm as AnyObject) as? [GeocodePlace] {
            return cached.count > 0 ? cached : nil
        }
        return nil
    }
}

extension MKMapItem {
    var geocoderPlace: GeocodePlace {
        let place = placemark.geocoderPlace
        place.phone = phoneNumber
        place.url = url?.absoluteString
        return place
    }
}

extension CLPlacemark {
    var geocoderPlace: GeocodePlace {
        let place = GeocodePlace()
        place.name = name
        if let addrList = addressDictionary?["FormattedAddressLines"] as? [String] {
            place.address =  addrList.joined(separator: ", ")
        }
        place.location = location
        return place
    }
}
