//
//  ContentView.swift
//  HelloAR1
//
//  Created by Adam Korytowski on 21/09/2022.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let arView = ARSCNView(frame: .zero)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        
        arView.delegate = context.coordinator
        arView.autoenablesDefaultLighting = true
        
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func makeCoordinator() -> ARCoordinator {
        ARCoordinator()
    }
    
}

class ARCoordinator: NSObject, ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("dupa")
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        DispatchQueue.global(qos: .userInteractive).async {
            let cube = SCNBox(
                width: referenceImage.physicalSize.width,
                height: 0.05,
                length: referenceImage.physicalSize.height,
                chamferRadius: 0
            )
            cube.firstMaterial?.diffuse.contents = UIColor.blue
            let cubeNode = SCNNode(geometry: cube)
            cubeNode.localTranslate(by: SCNVector3(x: 0, y: 0.025, z: 0))
            node.addChildNode(cubeNode)
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 1.50),
            .fadeOpacity(to: 0.15, duration: 1.50),
            .fadeOpacity(to: 0.85, duration: 1.50),
            .fadeOut(duration: 0.75),
            .removeFromParentNode()
        ])
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
