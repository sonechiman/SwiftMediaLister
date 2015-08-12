//
//  SwiftMediaLister.swift
//  SwiftMediaLister
//
//  Created by yuya on 2015/08/11.
//  Copyright (c) 2015年 soneoka. All rights reserved.
//

import Foundation
import AssetsLibrary
import MobileCoreServices

public class SwiftMediaLister{
    
    let library = ALAssetsLibrary()
    var result:[[String: AnyObject]] = []
    var option: [String: AnyObject] = [:]
    
    public init(){}
    
    public func readLibrary(thumbnail: Bool = true, limit: Int = 20, mediaTypes: [String] = ["image"], offset:Int = 0){
        option = ["thumbnail": thumbnail, "limit":limit , "mediaTypes": mediaTypes, "offset": offset]
        loadMedia(option)
    }

    
    
    // TODO:cordova対応
    public func loadMedia(option: [String: AnyObject]){
        library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos,usingBlock: {
            (group: ALAssetsGroup!, stop: UnsafeMutablePointer) in
            if group == nil{
                return
            }
            
            if let filter = self.getFilter(option["mediaTypes"] as! [String]){
                group.setAssetsFilter(filter)
            } else {
                return
            }
            
            let num = group.numberOfAssets()
            let indexSet = self.getIndexSet(num, limit: option["limit"] as! Int, offset: option["offset"] as! Int)
            if indexSet == nil{
                return
            }
            
            group.enumerateAssetsAtIndexes(indexSet!, options: NSEnumerationOptions.Reverse){
                (asset:ALAsset!, id:Int , stop: UnsafeMutablePointer) in
                if asset != nil{
                    self.result.append(self.setDictionary(asset, id: id, option:option))
                }
            }
            
            println(self.result)
            }, failureBlock:{
                (myerror: NSError!) -> Void in
                println("error occurred: \(myerror.localizedDescription)")
            }
        )
    }
    
    // TODO: Location等を追加可能
    func setDictionary(asset: ALAsset, id: Int, option: [String: AnyObject]) -> [String: AnyObject]{
        var data: [String: AnyObject] = [:]
        data["id"] = id
        data["mediaType"] = setType(asset)
        var date: NSDate = asset.valueForProperty(ALAssetPropertyDate) as! NSDate
        data["dateAdded"] = date.timeIntervalSince1970
        data["path"] = asset.valueForProperty(ALAssetPropertyAssetURL)
        var rep = asset.defaultRepresentation()
        data["size"] = Int(rep.size())
        data["orientation"] = rep.metadata()["Orientation"]
        data["title"] = rep.filename()
        data["height"] = rep.dimensions().height
        data["wigth"] = rep.dimensions().width
        data["mimeType"] = UTTypeCopyPreferredTagWithClass(rep.UTI(), kUTTagClassMIMEType).takeUnretainedValue()
        if (option["thumbnail"] as! Bool) {
            data["thumbnailPath"] = saveThumbnail(asset, id: id)
        }
        return data
    }
    
    func saveThumbnail(asset: ALAsset, id: Int) -> NSString{
        let thumbnail = asset.thumbnail().takeUnretainedValue()
        let image = UIImage(CGImage: thumbnail)
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        
        let cacheDirPath: NSString = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! NSString
        let filePath = cacheDirPath.stringByAppendingPathComponent("\(id).jpeg")
        
        if imageData.writeToFile(filePath, atomically: true){
            return filePath
        } else {
            println("error occured: Cannot save thumbnail image")
            return ""
        }
    }
    
    func setType(asset:ALAsset) -> String{
        let type = asset.valueForProperty(ALAssetPropertyType) as! String
        if type == ALAssetTypePhoto{
            return "image"
        } else if type == ALAssetTypeVideo {
            return "video"
        }
        return  ""
    }
    
    // TODO: Add music and playlist and audio
    func getFilter(mediaTypes: [String]) -> ALAssetsFilter?{
        if contains(mediaTypes, "image"){
            if contains(mediaTypes, "video"){
                return ALAssetsFilter.allAssets()
            } else {
                return ALAssetsFilter.allPhotos()
            }
        } else if contains(mediaTypes, "video"){
            return ALAssetsFilter.allVideos()
        }
        return nil
    }
    
    private func getIndexSet(max: Int, limit:Int, offset: Int) -> NSIndexSet?{
        if offset >= max{
            return nil
        } else if offset + limit > max{
            return NSIndexSet(indexesInRange: NSMakeRange(0, max - offset))
        } else {
            return NSIndexSet(indexesInRange: NSMakeRange(max - offset - limit, limit))
        }
    }
}