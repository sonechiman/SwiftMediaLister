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
    
    public init(){
    }
    
    // TODO:cordova対応
    public func test(){
        library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos,
            usingBlock: {
                (group: ALAssetsGroup!, stop: UnsafeMutablePointer) in
                if group != nil{
                    println(group)
                    // TODO: optionで切り替える
                    let filter = ALAssetsFilter.allPhotos()
                    group.enumerateAssetsUsingBlock{
                        (asset:ALAsset!, id:Int , stopp: UnsafeMutablePointer) in
                        if asset != nil{
                            self.result.append(self.setDictionary(asset, id: id))
                        }
                    }
                 println(self.result)
                }
            }, failureBlock:{
                (myerror: NSError!) -> Void in
                println("error occurred: \(myerror.localizedDescription)")
            }
        )
    }
    
    // TODO: Location等を追加可能
    func setDictionary(asset: ALAsset, id: Int) -> [String: AnyObject]{
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
        data["thumbnailPath"] = saveThumbnail(asset, id: id)
        return data
    }
    
    func saveThumbnail(asset: ALAsset, id: Int) -> NSString{
        let thumbnail = asset.thumbnail().takeUnretainedValue()
        let image = UIImage(CGImage: thumbnail)
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        
        let cacheDirPath: NSString = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! NSString
        let filePath = cacheDirPath.stringByAppendingPathComponent("\(id).jpeg")
        
        if imageData.writeToFile(filePath, atomically: true){
            println(filePath)
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
}