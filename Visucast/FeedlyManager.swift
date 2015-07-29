//
//  FeedlyManager.swift
//  TodayTwo
//
//  Created by Andrew Hart on 07/02/2015.
//  Copyright (c) 2015 Project Dent. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

private let _FeedlyManagerSharedManager = FeedlyManager()

public class FeedlyManager {
    
    private class func feedlyAPIURL() -> NSURL { return NSURL(string: "http://cloud.feedly.com")! }
    
    private class func feedlySearchURL() -> NSURL {
        return NSURL(string: "\(FeedlyManager.feedlyAPIURL())/v3/search/feeds")!
    }
    
    func feedlyMixesContentURL(feedID: String) -> NSURL {
        return NSURL(string: "\(FeedlyManager.feedlyAPIURL())/v3/mixes/contents?streamId=\(feedID)")!
    }
    
    public class var sharedManager: FeedlyManager {
        return _FeedlyManagerSharedManager
    }

//    //Searches the feeds for a given query. Returns a NewsSource if successful, and if results found, or an error if not successful.
//    public func searchForNewsSource(var query: String -> Void) {
//        let localeIdentifier = NSLocale.currentLocale().localeIdentifier
//        
////        if localeIdentifier == "en_GB" {
////            //Override results for BBC News, with UK locale.
////            let cleanQuery = query.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
////        
////            if cleanQuery == "bbc news" ||
////                cleanQuery == "bbc" ||
////                cleanQuery == "bbc news uk" ||
////                cleanQuery == "bbc uk" {
////                    query = "http://feeds.bbci.co.uk/news/rss.xml"
////            }
////        }
//        
//        Alamofire.request(.GET,
//            FeedlyManager.feedlySearchURL(),
//            parameters: ["query": query, "locale": localeIdentifier, "count": 1],
//            encoding: .URL).responseJSON(options: NSJSONReadingOptions.allZeros) {
//                (request: NSURLRequest,
//                response: NSHTTPURLResponse?,
//                responseJSON: AnyObject?,
//                error: NSError?) -> Void in
//                if responseJSON == nil || error != nil {
////                    if error != nil {
////                        XCGLogger.defaultInstance().error("Search for news source error: \(error)")
////                    }
//                    
//                    completion(newsSource: nil, error: error)
//                    return
//                }
//                
//                let jsonValue = JSON(responseJSON!)
//                
//                var firstResult: JSON? = jsonValue["results"][0]
//                
//                if firstResult == nil {
//               //     XCGLogger.defaultInstance().error("Feedly: No news source found: \(jsonValue.rawString(encoding: 0, options: NSJSONWritingOptions.PrettyPrinted))")
//                } else {
//                    if let feedID = firstResult!["feedId"].string {
//                        if let feedName = firstResult!["title"].string {
//                            let sourceURL: NSURL? = firstResult!["website"].URL
//                            
//                            let newsSource = FeedlyNewsSource(feedID: feedID, name: feedName)
//                            newsSource.sourceURL = sourceURL
//                            
//                            completion(newsSource: newsSource, error: nil)
//                            return
//                        }
//                    }
//                    
//                //    XCGLogger.defaultInstance().error("Feedly: Result doesn't contain necessary data: \(firstResult!.rawString(encoding: 0, options: NSJSONWritingOptions.PrettyPrinted))")
//                }
//                
//                completion(newsSource: nil, error: nil)
//                return
//        }
//    }
//    
    ///Fetches and completes with relevant, recent articles for the given feed ID.
//    public func articlesForNewsSource(feedID: String, articleCount: Int -> Void) {
//        Alamofire.request(
//            .GET,
//            FeedlyManager.feedlyMixesContentURL(feedID: feedID),
//            parameters: ["count": 20, "hours": 15],
//            encoding: .URL).responseJSON(options: NSJSONReadingOptions.allZeros) {
//                (request: NSURLRequest,
//                response: NSHTTPURLResponse?,
//                responseJSON: AnyObject?,
//                error: NSError?) -> Void in
//                if responseJSON == nil || error != nil {
////                    if error != nil {
////                        XCGLogger.defaultInstance().error("Feedly: GET articles error: \(error)")
////                    }
//                    
//                    completion(articles: nil, error: error)
//                    return
//                }
//                
//                let jsonValue = JSON(responseJSON!)
//                
//                var articles: Array<FeedlyArticle> = []
//                
//                if let results = jsonValue["items"].array {
//                    for result: JSON in results {
//                        let articleID = result["id"].string
//                        var title = result["title"].string
//                        var summary = result["summary"]["content"].string
//                        var imageURL = result["visual"]["url"].URL
//                        var timestamp = result["published"].int
//                        
//                        //Image URL will occasionally return as the string "none", which should be replaced with a nil value.
//                        if imageURL?.absoluteString?.rangeOfString("http") == nil {
//                            imageURL = nil
//                        }
//                        
//                        var articleURL = result["canonical"]["href"].URL
//                        
//                        if articleURL == nil {
//                            articleURL = result["originId"].URL
//                        }
//                        
//                        if articleID == nil || title == nil {
//                     //       XCGLogger.defaultInstance().error("Feedly: Article doesn't contain necessary data: \(result.rawString(encoding: 0, options: NSJSONWritingOptions.PrettyPrinted))")
//                            continue
//                        }
//                        
//                        let engagement = result["engagement"].int
//                        
//                        let engagementRate = result["engagementRate"].double
//                        
//                        var timeInterval: NSTimeInterval?
//                        
//                        if timestamp != nil {
//                            timeInterval = Double(timestamp!) / 1000.0
//                        }
//                        
//                        //Cleans up strings if necessary
//                        title = title?.stringByCleaningHTMLString()
//                        summary = summary?.stringByCleaningHTMLString()
//                        
//                        let article = FeedlyArticle(articleID: articleID!, title: title!)
//                        article.summary = summary
//                        article.imageURL = imageURL
//                        article.articleURL = articleURL
//                        article.engagement = engagement
//                        article.engagementRate = engagementRate
//                        article.publishedTimeInterval = timeInterval
//
//                        articles.append(article)
//                    }
//                }
//                
//                articles.sort({
//                    (firstArticle: FeedlyArticle, secondArticle: FeedlyArticle) -> Bool in
//                    
//                    if firstArticle.engagement == nil || firstArticle.age() == nil
//                        || secondArticle.engagement == nil || secondArticle.age() == nil {
//                        return true
//                    }
//                    
//                    var firstArticleEngagementOverTime = Double(firstArticle.engagement!) / firstArticle.age()!
//                    var secondArticleEngagementOverTime = Double(secondArticle.engagement!) / secondArticle.age()!
//                    
//                    return firstArticleEngagementOverTime > secondArticleEngagementOverTime
//                })
//                
//                while articles.count > articleCount {
//                    articles.removeLast()
//                }
//                
//                completion(articles: articles, error: nil)
//        }
//    }
}













