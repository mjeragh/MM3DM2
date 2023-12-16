//
//  MetalView.swift
//  MM3DUI
//
//  Created by Mohammad Jeragh on 06/06/2022.
//

import SwiftUI
import MetalKit
///Refrences
///https://metalbyexample.com/picking-hit-testing/
///https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-box-intersection
struct MetalView: View {
  let options: Options
  @State private var metalView = MTKView()
  @State private var gameController: GameController?
  @State private var previousTranslation = CGSize.zero
  @State private var previousScroll: CGFloat = 1

  var body: some View {
    VStack {
      MetalViewRepresentable(
        gameController: gameController,
        metalView: $metalView,
        options: options)
        .onAppear {
          gameController = GameController(
            metalView: metalView,
            options: options)
        }.gesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
              InputController.shared.touchLocation = value.location
                //get the point by unproject on the plane where n =[0,1,0] and the point given p0 [0,0,0]
                //compare with the interactive properties where the point lies with its boundbox
                //that will be the selected node
                gameController?.scene.handleInteraction(at: value.location)
              InputController.shared.touchDelta = CGSize(
                width: value.translation.width - previousTranslation.width,
                height: value.translation.height - previousTranslation.height)
              previousTranslation = value.translation
              // if the user drags, cancel the tap touch
              if abs(value.translation.width) > 1 ||
                abs(value.translation.height) > 1 {
                InputController.shared.touchLocation = nil
              }
            }
            .onEnded {_ in
              previousTranslation = .zero
                Task{
                    await gameController?.scene.asyncInverse()
                }
            }
        ).gesture(MagnificationGesture()
                .onChanged { value in
                  let scroll = value - previousScroll
                  InputController.shared.mouseScroll.x = Float(scroll)
                    * Settings.touchZoomSensitivity
                  previousScroll = value
                }
                .onEnded {_ in
                  previousScroll = 1
                })
        
    }
  }
}


typealias ViewRepresentable = UIViewRepresentable

struct MetalViewRepresentable: ViewRepresentable {
  let gameController: GameController?
  @Binding var metalView: MTKView
  let options: Options

  
  func makeUIView(context: Context) -> MTKView {
    metalView
  }

  func updateUIView(_ uiView: MTKView, context: Context) {
    updateMetalView()
  }
  

  func updateMetalView() {
    gameController?.options = options
  }
}

struct MetalView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      MetalView(options: Options())
      Text("Metal View")
    }
  }
}
