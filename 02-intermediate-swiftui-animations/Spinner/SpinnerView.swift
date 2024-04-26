/// Copyright (c) 2022-present Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct SpinnerView: View {
  
  struct Leaf: View {
    
    let rotation: Angle
    let isCurrent: Bool
    let isCompleting: Bool
    
    var body: some View {
      
      Capsule()
        .stroke(isCurrent ? .white : .gray, lineWidth: 8)
        .frame(width: 20, height: isCompleting ? 20 : 50)
        .offset(x: isCurrent ? 10 : 0, y: isCurrent ? 40 : 70)
        .rotationEffect(isCompleting ? .zero : rotation)
        .scaleEffect(isCurrent ? 1.5 : 1.0)
        .animation(.easeInOut(duration: 0.5), value: isCurrent)
        .animation(.easeInOut(duration: 0.5), value: isCompleting)
    }
  }

  let leavesCount = 12
  let shootUp = AnyTransition
    .offset(CGSize(width: 0, height: -1000))
    .animation(.easeIn(duration: 1.0))
  
  @State var currentIndex: Int?
  @State var completed = false
  @State var isVisible = true
  @State var currentOffset = CGSize.zero

  var body: some View {
    VStack {
      if isVisible {
        ZStack {
          ForEach(0..<leavesCount) { index in
            Leaf(rotation: Angle(degrees: Double(index) / Double(leavesCount) * 360),
                 isCurrent: index == currentIndex,
                 isCompleting: completed)
          }
        }
        .transition(shootUp)
        .onAppear(perform: animate)
        .gesture(
          DragGesture()
            .onChanged { gesture in
              self.currentOffset = gesture.translation
            }
            .onEnded { _ in
              if self.currentOffset.height > 150 {
                self.complete()
              }
              self.currentOffset = .zero
            }
        )
        .offset(currentOffset)
        .blur(radius: currentOffset == .zero ? 0 : 10)
        .animation(.easeInOut(duration: 1.0), value: currentOffset)
      }
    }
  }

  func animate() {
    
    var iteration = 0
    
    Timer.scheduledTimer(withTimeInterval: 0.11, 
                         repeats: true) { timer in
      iteration += 1
      if iteration == 60 {
        timer.invalidate()
        complete()
      }
      if let currentIndex {
        self.currentIndex = (currentIndex + 1 ) % leavesCount
        
      } else {
        currentIndex = 0
      }
    }
  }
  
  func complete() {
    guard !completed else { return }
    
    completed = true
    currentIndex = nil
    
    delay(seconds: 2) {
      withAnimation {
        isVisible = false
      }
    }
  }
}

#if DEBUG
struct SpinnerView_Previews: PreviewProvider {
  static var previews: some View {
    SpinnerView()
  }
}
#endif
