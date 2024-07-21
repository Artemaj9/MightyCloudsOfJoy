//import Metal
//import MetalKit
//
//class WeatherMetalView: MTKView {
//    var commandQueue: MTLCommandQueue!
//    var pipelineState: MTLRenderPipelineState!
//    
//    var effect: String!
//    var time: Float = 0
//    
//    init(effect: String, frame: CGRect) {
//        self.effect = effect
//        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
//        
//        self.commandQueue = device!.makeCommandQueue()
//        self.setupPipeline()
//        
//        // Start a display link to update the view
//        let displayLink = CADisplayLink(target: self, selector: #selector(update))
//        displayLink.add(to: .current, forMode: .default)
//    }
//    
//    required init(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func setupPipeline() {
//        let library = device!.makeDefaultLibrary()
//        let vertexFunction = library?.makeFunction(name: "vertexShader")
//        let fragmentFunction = library?.makeFunction(name: effect)
//        
//        let pipelineDescriptor = MTLRenderPipelineDescriptor()
//        pipelineDescriptor.vertexFunction = vertexFunction
//        pipelineDescriptor.fragmentFunction = fragmentFunction
//        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        
//        do {
//            pipelineState = try device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
//        } catch let error {
//            print("Failed to create pipeline state: \(error)")
//        }
//    }
//    
//    @objc func update() {
//        self.time += 1.0 / Float(self.preferredFramesPerSecond)
//        self.setNeedsDisplay()
//    }
//    
//    override func draw(_ rect: CGRect) {
//        guard let drawable = currentDrawable else { return }
//        let renderPassDescriptor = currentRenderPassDescriptor!
//        let commandBuffer = commandQueue.makeCommandBuffer()!
//        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
//        
//        renderEncoder.setRenderPipelineState(pipelineState)
//        
//        // Set the time uniform
//        renderEncoder.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 0)
//        
//        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
//        
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}


//import Metal
//import MetalKit
//
//class WeatherMetalView: MTKView {
//    var commandQueue: MTLCommandQueue!
//    var pipelineState: MTLRenderPipelineState!
//    
//    var effect: String!
//    var time: Float = 0
//    
//    init(effect: String, frame: CGRect) {
//        self.effect = effect
//        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
//        
//        self.commandQueue = device!.makeCommandQueue()
//        self.setupPipeline()
//        
//        // Start a display link to update the view
//        let displayLink = CADisplayLink(target: self, selector: #selector(update))
//        displayLink.add(to: .current, forMode: .default)
//    }
//    
//    required init(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func setupPipeline() {
//        let library = device!.makeDefaultLibrary()
//        let vertexFunction = library?.makeFunction(name: "vertexShader")
//        let fragmentFunction = library?.makeFunction(name: effect)
//        
//        let pipelineDescriptor = MTLRenderPipelineDescriptor()
//        pipelineDescriptor.vertexFunction = vertexFunction
//        pipelineDescriptor.fragmentFunction = fragmentFunction
//        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        
//        do {
//            pipelineState = try device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
//        } catch let error {
//            print("Failed to create pipeline state: \(error)")
//        }
//    }
//    
//    @objc func update() {
//        self.time += 1.0 / Float(self.preferredFramesPerSecond)
//        self.setNeedsDisplay()
//    }
//    
//    override func draw(_ rect: CGRect) {
//        guard let drawable = currentDrawable else { return }
//        let renderPassDescriptor = currentRenderPassDescriptor!
//        let commandBuffer = commandQueue.makeCommandBuffer()!
//        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
//        
//        renderEncoder.setRenderPipelineState(pipelineState)
//        
//        // Set the time uniform
//        renderEncoder.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 0)
//        
//        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
//        
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}

import Metal
import MetalKit

class WeatherMetalView: MTKView {
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    
    var effect: String!
    var time: Float = 0
    
    let vertices: [float2] = [
        float2(0, 0),
        float2(1, 0),
        float2(0, 1),
        float2(1, 1)
    ]
    
    init(effect: String, frame: CGRect) {
        self.effect = effect
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        
        self.commandQueue = device!.makeCommandQueue()
        self.setupPipeline()
        
        // Start a display link to update the view
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .default)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPipeline() {
        let library = device!.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: effect)
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print("Failed to create pipeline state: \(error)")
        }
    }
    
    @objc func update() {
        self.time += 1.0 / Float(self.preferredFramesPerSecond)
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let drawable = currentDrawable else { return }
        let renderPassDescriptor = currentRenderPassDescriptor!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // Set the vertex buffer
        renderEncoder.setVertexBytes(vertices, length: vertices.count * MemoryLayout<float2>.size, index: 0)
        
        // Set the fragment buffer
        renderEncoder.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 0)
        var resolution = float2(Float(drawable.texture.width), Float(drawable.texture.height))
        renderEncoder.setFragmentBytes(&resolution, length: MemoryLayout<float2>.size, index: 1)
        var mouse = float4(0.0, 0.0, 0.0, 0.0) // Update with actual mouse data if needed
        renderEncoder.setFragmentBytes(&mouse, length: MemoryLayout<float4>.size, index: 2)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

