//
//  ViewController.swift
//  ARDicee
//
//  Created by gianrico on 12/12/17.
//  Copyright © 2017 gianrico. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // metodo lanciato in automatico quando diciamo che la configuration deve avere il plane detection
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("identificato piano orizzontale")
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            //definiamo il piano e stimo a tttenti che va definito per x e z NON y
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x:planeAnchor.center.x, y:0, z:planeAnchor.center.z)
            //il piano viene considerato cmq in vertticale va trasformato in orizzontale
            //Float.pi/2 sono 90° in radianti, 1,0,0 invece significa che lo facciamo ruotare attorno all'asse x
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named:"art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
     //dopo aver individuato un piano rileviamo un touch da parte dell'utente
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //se rileva un tocco lo asegna alla sceneView
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            //per convertire il tocco in un punto 3d dobbiamo usare ARkit
            //qui controlla se il tap è eseguito sul piano che ha individuato
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                print(hitResult)
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
                // Set the scene to the view
        //        sceneView.scene = scene
        
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    // qui andiamo a prendere quella posizione che viene data dalla proprietà worldTransform
                    // sull'asse y i dadi verrebbero piantati a metà del piano quindi gli sommiamo la loro metà a y per alzarli
                    // per fare questo usiamo la proprietà boundingSphere.radius
                    diceNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius, z: hitResult.worldTransform.columns.3.z)
                    
                    //aggiungo il dado all'array di dadi
                    diceArray.append(diceNode)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)
                }
            }
        }
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice:dice)
            }
        }
    }
    
    func roll(dice:SCNNode) {
        
        //per ruotare i dadi devo ottenere due numeri casuali sull'asse x e z
        //4 +1 perché devo avere 4 facce vedibili * pi greco mezzi cioè 90°
        let randX = Float (arc4random_uniform(4) + 1) * (Float.pi/2)
        let randZ = Float (arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randX * 3), y: 0, z: CGFloat(randZ * 3), duration: 0.5))
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
}
