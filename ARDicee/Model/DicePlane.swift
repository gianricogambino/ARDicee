//
//  DicePlane.swift
//  ARDicee
//
//  Created by gianrico on 13/12/17.
//  Copyright © 2017 gianrico. All rights reserved.
//

import Foundation
import ARKit

class DicePlane {
    
    var plane: SCNPlane
    var planeX: CGFloat
    var planeZ: CGFloat
    var planeAnchorX:Float
    var planeAnchorZ:Float
    let planeNode = SCNNode()
    let gridMaterial = SCNMaterial()

    init(planeX:CGFloat, planeZ:CGFloat, planeAnchorX:Float, planeAnchorZ:Float) {
        self.planeX = planeX
        self.planeZ = planeZ
        self.planeAnchorX = planeAnchorX
        self.planeAnchorZ = planeAnchorZ
        //definiamo il piano e stiamo attenti che va definito per x e z NON y
        self.plane = SCNPlane(width: planeX, height: planeZ)
        self.planeNode.position = SCNVector3(x:planeAnchorX, y:0, z:planeAnchorZ)
        //il piano viene considerato cmq in vertticale va trasformato in orizzontale
        //Float.pi/2 sono 90° in radianti, 1,0,0 invece significa che lo facciamo ruotare attorno all'asse x
        self.planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        gridMaterial.diffuse.contents = UIImage(named:"art.scnassets/grid.png")
        self.plane.materials = [gridMaterial]
        self.planeNode.geometry = plane
    }
}
