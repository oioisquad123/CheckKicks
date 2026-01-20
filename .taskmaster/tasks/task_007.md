# Task ID: 7

**Title:** Build 4-step photo capture wizard with guidance overlays

**Status:** completed

**Dependencies:** 5

**Priority:** high

**Description:** Create guided SwiftUI wizard for 4 specific sneaker angles with visual overlays (FR-2.1 to FR-2.7)

**Details:**

Use TabView or NavigationStack for steps: 1.OuterSide, 2.InnerSide, 3.SizeTag, 4.BoxLabel. Each step: UIImagePickerController wrapped in UIViewControllerRepresentable, semi-transparent guidance overlay image, progress "Step X of 4". Use @State for capturedImages: [UIImage?].

**Test Strategy:**

Capture photos at each step, verify guidance overlays visible, progress updates correctly.
