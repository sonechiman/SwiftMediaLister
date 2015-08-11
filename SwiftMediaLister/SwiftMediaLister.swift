//
//  SwiftMediaLister.swift
//  SwiftMediaLister
//
//  Created by yuya on 2015/08/11.
//  Copyright (c) 2015年 soneoka. All rights reserved.
//

import Foundation
import AssetsLibrary

public class SwiftMediaLister{
    let library = ALAssetsLibrary()
    
    public init(){
    }
    
    public func test(){
        library.enumerateGroupsWithTypes(ALAssetsGroupAll,
            usingBlock: {
                (group: ALAssetsGroup!, stop: UnsafeMutablePointer) in
                if group != nil{
                    println(group)
                    group.enumerateAssetsUsingBlock{
                        (asset:ALAsset!, id:Int , stopp: UnsafeMutablePointer) in
                        if asset != nil{
                            println(asset)
                            println(id)
                            println(asset.valueForProperty(ALAssetPropertyType))
                            println(asset.valueForProperty(ALAssetPropertyDate))
                            println(asset.valueForProperty(ALAssetPropertyURLs))
                            println(asset.valueForProperty(ALAssetPropertyDuration))
                            println(asset.valueForProperty(ALAssetPropertyOrientation))
                            println(asset.valueForProperty(ALAssetPropertyLocation))
                            println(asset.valueForProperty(ALAssetPropertyRepresentations))
                            println(asset.valueForProperty(ALAssetPropertyAssetURL))
                                asset.thumbnail()
                        }
                    }
                }
            }, failureBlock: nil)
    }
}