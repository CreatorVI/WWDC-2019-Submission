//
//  Extensions.swift
//  Book_Sources
//
//  Created by Yu Wang on 2019/3/18.
//

import SceneKit

public extension SCNVector3{
    static var zero: SCNVector3{
        get{
            return SCNVector3(0, 0, 0)
        }
    }
}

public extension simd_float4x4{
    func combinePositionAndRotation(position:simd_float4,rotation:simd_float4x4)->simd_float4x4{
        return simd_float4x4(columns: (rotation.columns.0,
                                       rotation.columns.1,
                                       rotation.columns.2,
                                       position))
    }
}
