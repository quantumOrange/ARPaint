//
//  Points.swift
//  ARMetalTest
//
//  Created by David Crooks on 12/02/2019.
//  Copyright © 2019 David Crooks. All rights reserved.
//

import Foundation


import ARKit
import MetalKit

struct PointVertex {
    let position:SIMD3<Float>
    let color:SIMD4<Float>
    let size:Float
    let hardness:Float
}

class Points: ARMetalDrawable  {
    let maxPoints = 3000
    
    var vertices:[PointVertex] = []
    
    var depthState: MTLDepthStencilState!
   
    func add(_ newVertices:[PointVertex]) {
        newVertices.forEach { vertices.append($0) }
        
        let excessPoints = vertices.count - maxPoints
        if excessPoints > 0 {
            vertices = Array(vertices.dropFirst(excessPoints))
        }
        buildBuffers(device:self.device)
    }
    

    func updateBuffer(frame:ARFrame){
        let v = simd_mul(frame.camera.transform,SIMD4<Float>(0,0,0,1))
        
        func dist(_ p:SIMD3<Float>) -> Float {
            return simd_distance(p,SIMD3<Float>(v.x,v.y,v.z))
        }
        
        func furthestFromCamera(_ p:PointVertex,_ q:PointVertex) -> Bool {
            return dist(p.position) > dist(q.position)
        }
        
        let sortedVertices = vertices.sorted(by: furthestFromCamera)
        
        vertexBuffer?.contents().copyMemory(from: sortedVertices, byteCount: vertices.byteLength)
    }
    
    var pipelineState: MTLRenderPipelineState?
   
    var vertexBuffer: MTLBuffer?
    
    private func buildBuffers(device: MTLDevice) {
        
        if vertices.count > 0 {
            vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.byteLength,
                                         options: [])
        }
    }
    
    var renderDestination:RenderDestinationProvider
    
    var vertexDescriptor:MTLVertexDescriptor!
    var device:MTLDevice!
   
    init( device:MTLDevice, destination:RenderDestinationProvider ) {
        self.renderDestination = destination
        self.device = device
        loadMetal(device:device)
    }
    
    func loadMetal(device:MTLDevice) {
       
        buildBuffers(device: device)
        
        let defaultLibrary = device.makeDefaultLibrary()!
        let vertexFunction = defaultLibrary.makeFunction(name: "pointVertex")!
        let fragmentFunction = defaultLibrary.makeFunction(name: "pointFragment")!
        
        vertexDescriptor = MTLVertexDescriptor()
        
        //position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        //color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        //size
        vertexDescriptor.attributes[2].format = .float
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        //hardness
        vertexDescriptor.attributes[3].format = .float
        vertexDescriptor.attributes[3].offset =  MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride +  MemoryLayout<Float>.stride
        vertexDescriptor.attributes[3].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<PointVertex>.stride
 
        // Create a reusable pipeline state for rendering anchor geometry
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.label = "MyPointsPipeline"
        pipelineDescriptor.sampleCount = renderDestination.sampleCount
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = renderDestination.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = renderDestination.depthStencilPixelFormat
        pipelineDescriptor.stencilAttachmentPixelFormat = renderDestination.depthStencilPixelFormat
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        if let attachmentDescriptor = pipelineDescriptor.colorAttachments[0] {
            attachmentDescriptor.isBlendingEnabled = true
            
            attachmentDescriptor.rgbBlendOperation = MTLBlendOperation.add
            attachmentDescriptor.sourceRGBBlendFactor = MTLBlendFactor.sourceAlpha
            attachmentDescriptor.destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
            
            attachmentDescriptor.alphaBlendOperation = MTLBlendOperation.add
            attachmentDescriptor.sourceAlphaBlendFactor = MTLBlendFactor.sourceAlpha
            attachmentDescriptor.destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        }
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        depthState = device.makeDepthStencilState(descriptor:depthStencilDescriptor)
        
        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print("Failed to created anchor geometry pipeline state, error \(error)")
        }
        
    }
    
    
    func update(frame: ARFrame){
        updateBuffer(frame: frame)
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder,sharedUniformBuffer: MTLBuffer,sharedUniformBufferOffset:Int ) {
        
        guard   let pipelineState = pipelineState,
                let vertexBuffer = vertexBuffer
                                            else { return }
        
        // Push a debug group allowing us to identify render commands in the GPU Frame Capture tool
        renderEncoder.pushDebugGroup("DrawPionts")
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setVertexBuffer(vertexBuffer,
                                      offset: 0, index: Int(kBufferIndexMeshPositions.rawValue))
        
        renderEncoder.setVertexBuffer(sharedUniformBuffer, offset: sharedUniformBufferOffset, index: Int(kBufferIndexSharedUniforms.rawValue))
        
        renderEncoder.setFragmentBuffer(sharedUniformBuffer, offset: sharedUniformBufferOffset, index: Int(kBufferIndexSharedUniforms.rawValue))
       
        
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertices.count)
        renderEncoder.popDebugGroup()
    }
}
