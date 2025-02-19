//
//  APIServices.swift
//  UCLA Radio
//
//  Created by Christopher Laganiere on 5/9/16.
//  Copyright © 2016 UCLA Student Media. All rights reserved.
//

import Foundation
import Alamofire

struct RecentTrack {
    let title: String
    let artist: String
    let url: String
    // image data might not be supplied
    var image: String?
    
    init(title: String, artist: String, url: String) {
        self.title = title
        self.artist = artist
        self.url = url
    }
}

@objc protocol HistoryFetchDelegate {
    func updatedHistory()
}

class HistoryFetcher {
    
    static var recentTracks: [RecentTrack] = []
    static weak var delegate: HistoryFetchDelegate?
    fileprivate static var currentPage = 1;
    
    /**
     Fetch and store fresh recently played song data from the Last.fm API
     Will replace this.recentTracks
     */
    static func fetchRecentTracks() {
        fetchTracks(1, replace: true)
    }
    
    /**
     Load more recently played song data from the Last.fm API,
     continuing at the last page and appending to this.recentTracks
     */
    static func fetchMoreTracks() {
        fetchTracks(currentPage + 1, replace: false)
    }
    
    /**
     Query the Last.fm API and retrieve recently played tracks
     
     - parameter page:    page to fetch (1 to start from top)
     - parameter replace: should replace existing data in this.recentlyPlayed
     */
    static func fetchTracks(_ page: Int, replace: Bool) {
        Alamofire.request("https://ws.audioscrobbler.com/2.0/",
            parameters: ["method": "user.getrecenttracks",
                "user": "uclaradio",
                "api_key": "d3e63e89b35e60885c944fe9b7341b76",
                "page": page,
                "limit": "10",
                "format": "json"])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    self.currentPage = page
                    if let json = json as? NSDictionary,
                        let tracksDict = json["recenttracks"] as? NSDictionary,
                        let tracks = tracksDict["track"] as? NSArray {
                        
                        self.processRecentTracks(tracks, replace: true);
                        delegate?.updatedHistory()
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    /**
     Update this.recentTracks by processing a dictionary returned from the Last.fm API containing track info
     
     - parameter tracks:  track dictionary array from Last.fm
     - parameter replace: should replace info currently in this.recentTracks with updated data
     */
    fileprivate static func processRecentTracks(_ tracks: NSArray, replace: Bool) {
        if (replace) {
            recentTracks = []
        }
        for dataObject: Any in tracks {
            if let track = dataObject as? NSDictionary,
                let artistInfo = track["artist"] as? NSDictionary,
                let imageInfo = track["image"] as? [NSDictionary]
            {
                if let title = track["name"] as? String,
                    let artist = artistInfo["#text"] as? String,
                    let url = track["url"] as? String {
                    var newTrack = RecentTrack(title: title, artist: artist, url: url)
                    // image data not available for all tracks
                    let medium = imageInfo[2]
                    if let image = medium["#text"] as? String, image.characters.count > 0 {
                        newTrack.image = image
                    }
                    //print("\(title) by \(artist)")
                    recentTracks.append(newTrack)
                }
            }
        }
    }
    
}
