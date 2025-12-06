import SwiftUI

/// A slide-to-confirm button that requires the user to drag to complete an action.
/// Used to add friction to sensitive actions like changing blocking schedules.
struct SlideToAction: View {
    let label: String
    let onComplete: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isComplete = false
    @GestureState private var isDragging = false
    
    private let thumbSize: CGFloat = ZenoSemanticTokens.Size.buttonHeight
    private let trackHeight: CGFloat = ZenoSemanticTokens.Size.buttonHeight
    
    var body: some View {
        GeometryReader { geometry in
            makeContent(geometry: geometry)
        }
        .frame(height: trackHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityHint("Swipe right to confirm")
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Content Builder
    
    @ViewBuilder
    private func makeContent(geometry: GeometryProxy) -> some View {
        let trackWidth = geometry.size.width
        let trackPadding = ZenoSemanticTokens.Space.xs
        let maxOffset = trackWidth - thumbSize - (trackPadding * 2)
        let progress = maxOffset > 0 ? min(dragOffset / maxOffset, 1.0) : 0
        
        ZStack(alignment: .leading) {
            // Track background
            RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.none)
                .fill(ZenoSemanticTokens.Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.none)
                        .stroke(ZenoSemanticTokens.Theme.border, lineWidth: ZenoSemanticTokens.Stroke.thin)
                )
            
            // Label + supporting icon
            HStack {
                labelView(progress: progress)
                
                Spacer()
                
                chevronView(progress: progress)
            }
            .padding(.leading, thumbSize + trackPadding + ZenoSemanticTokens.Space.md)
            .padding(.trailing, ZenoSemanticTokens.Space.md)
            .font(ZenoTokens.Typography.labelMedium)
            
            // Draggable thumb
            RoundedRectangle(cornerRadius: ZenoSemanticTokens.Radius.none)
                .fill(ZenoSemanticTokens.Theme.foreground)
                .frame(width: thumbSize, height: thumbSize)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.system(size: ZenoSemanticTokens.Size.iconMedium, weight: .bold))
                        .foregroundColor(ZenoSemanticTokens.Theme.background)
                )
                .shadow(
                    color: ZenoTokens.ColorBase.Black._25,
                    radius: isDragging ? ZenoTokens.SpacingScale._2 : ZenoTokens.SpacingScale._1,
                    x: 0,
                    y: isDragging ? ZenoTokens.SpacingScale._1 : ZenoTokens.SpacingScale._0_5
                )
                .scaleEffect(isDragging ? 1.05 : 1.0)
                .offset(x: trackPadding + dragOffset)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { _, state, _ in
                            state = true
                        }
                        .onChanged { value in
                            dragOffset = max(0, min(value.translation.width, maxOffset))
                        }
                        .onEnded { _ in
                            handleDragEnd(maxOffset: maxOffset)
                        }
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isDragging)
        }
    }
    
    // MARK: - Label Builders
    
    @ViewBuilder
    private func labelView(progress: CGFloat) -> some View {
        AnyView(
            Text(label)
                .tracking(ZenoSemanticTokens.LetterSpacing.extraWide)
        )
        .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
        .opacity(labelOpacity(for: progress))
    }
    
    private func chevronView(progress: CGFloat) -> some View {
        Image(systemName: "chevron.right")
            .font(.system(size: ZenoSemanticTokens.Size.iconSmall, weight: .bold))
            .foregroundColor(ZenoSemanticTokens.Theme.mutedForeground)
            .opacity(chevronOpacity(for: progress))
    }
    
    private func labelOpacity(for progress: CGFloat) -> Double {
        let normalized = clampedProgress(progress)
        let fade = min(1, normalized * 1.5)
        return max(0, 1 - fade)
    }
    
    private func chevronOpacity(for progress: CGFloat) -> Double {
        let normalized = clampedProgress(progress)
        let fade = min(1, normalized * 2)
        return max(0, 1 - fade)
    }
    
    private func clampedProgress(_ progress: CGFloat) -> Double {
        Double(min(max(progress, 0), 1))
    }
    
    // MARK: - Private Methods
    
    private func handleDragEnd(maxOffset: CGFloat) {
        if maxOffset > 0 && dragOffset / maxOffset > 0.9 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                dragOffset = maxOffset
                isComplete = true
            }
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onComplete()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    dragOffset = 0
                    isComplete = false
                }
            }
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                dragOffset = 0
            }
        }
    }
}

#Preview {
    ZStack {
        ZenoSemanticTokens.Theme.background.ignoresSafeArea()
        
        VStack(spacing: ZenoSemanticTokens.Space.xl) {
            SlideToAction(label: "SLIDE TO EDIT") {
                print("Action completed!")
            }
        }
        .padding()
    }
}
