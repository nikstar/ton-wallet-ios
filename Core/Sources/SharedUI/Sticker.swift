
import SwiftUI
import Lottie
import Gzip

public struct Sticker: View {
    
    let name: String
    let loopMode: LottieLoopMode
    
    public init(_ name: String, play loopMode: LottieLoopMode = .loop) {
        self.name = name
        self.loopMode = loopMode
    }
    
    public var body: some View {
        _Lottie(name: name, loopMode: loopMode)
            .frame(width: 124, height: 124)
    }
}


fileprivate struct _Lottie: UIViewRepresentable {
    
    var name: String
    var loopMode: LottieLoopMode
    
    func makeUIView(context: Context) -> some UIView {
        
        let asset = NSDataAsset(name: name)! // static assets, so force unwraps are fine
        let data = try! asset.data.gunzipped()
        let animation = try! LottieAnimation.from(data: data)
        let animationView = LottieAnimationView(animation: animation)
        animationView.loopMode = loopMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        
        let container = UIView(frame: .zero)
        container.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.widthAnchor.constraint(equalTo: container.widthAnchor).isActive = true
        animationView.heightAnchor.constraint(equalTo: container.heightAnchor).isActive = true
        return container
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ view: UIViewType, context: Context) {
    }
    
    final class Coordinator {
    }
}


fileprivate struct _LottieAsync: UIViewRepresentable {
    
    var name: String
    var loopMode: LottieLoopMode
    
    func makeUIView(context: Context) -> some UIView {
        
        let container = UIView(frame: .zero)
        
        context.coordinator.loadTask?.cancel()
        context.coordinator.loadTask = Task.detached(priority: .high, operation: {
            let asset = NSDataAsset(name: name)! // static assets, so force unwraps are fine
            let data = try! asset.data.gunzipped()
            let animation = try! LottieAnimation.from(data: data)
            guard !Task.isCancelled else { return }
            Task { @MainActor in
                let animationView = LottieAnimationView(animation: animation)
                animationView.loopMode = loopMode
                animationView.backgroundBehavior = .pauseAndRestore
                animationView.contentMode = .scaleAspectFit
                animationView.play()
                guard !Task.isCancelled else { return }
                container.addSubview(animationView)
                animationView.translatesAutoresizingMaskIntoConstraints = false
                animationView.widthAnchor.constraint(equalTo: container.widthAnchor).isActive = true
                animationView.heightAnchor.constraint(equalTo: container.heightAnchor).isActive = true
                container.setNeedsDisplay()
            }
        })
        
        return container
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ view: UIViewType, context: Context) {
    }
    
    final class Coordinator {
        var loadTask: Task<Void, Never>?
    }
}

