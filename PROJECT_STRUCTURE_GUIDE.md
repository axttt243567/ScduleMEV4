# Project Structure Guide

This specific guide is designed to help new developers understand how to organize the `ScduleMEv4` codebase. Currently, the project uses a flat structure where most code resides in `lib/pages` and `lib/widgets`. As the app grows, this makes it hard to maintain.

Below are 3 recommended methods to structure your code, ranging from simple to scalable.

---

## Method 1: Layer-Based (Type-Based)
**Best for:** Small to Medium apps.
**Concept:** Group files by **what they are** (Models, Views, Services).

This is the most natural evolution from your current structure. You simply create folders for each "type" of generic file.

### Proposed Structure
```text
lib/
├── main.dart
├── models/             # Data classes (e.g., User, ChatMessage)
├── services/           # API calls, Database logic, Storage
├── providers/          # State management (Riverpod/Provider/Bloc)
├── screens/            # Full page views (renamed from 'pages')
│   ├── home/
│   ├── chat/
│   └── settings/
├── widgets/            # Reusable UI components (Buttons, Cards)
└── utils/              # Helper functions, constants, theme
```

**Pros:**
*   Easy to understand for beginners.
*   You always know where "Services" are.

**Cons:**
*   To work on a "Chat" feature, you have to jump between `screens/`, `models/`, and `services/` folders.

---

## Method 2: Feature-Based (Vertical Slicing)
**Best for:** Medium to Large apps (Highly Recommended).
**Concept:** Group files by **what feature they belong to**.

Everything related to a specific feature (like "Chat" or "Authentication") stays together.

### Proposed Structure
```text
lib/
├── main.dart
├── core/               # Shared across features (constants, generic widgets)
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/           # Login, Signup
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── chat/           # AI Chat
│   │   ├── screens/
│   │   ├── logic/      # State management specific to chat
│   │   └── models/     # 'ChatMessage' model
│   └── home/
│       └── ...
└── services/           # Global services (e.g. SupabaseClient, Http)
```

**Pros:**
*   **Scalable:** Adding a new feature doesn't clutter global folders.
*   **Focused:** When working on "Chat", you only need to look at the `features/chat` folder.

**Cons:**
*   Requires discipline to decide what is "Core" vs "Feature".

---

## Method 3: Simplified Clean Architecture
**Best for:** Large teams or apps focused on testability.
**Concept:** Separate code into **Presentation**, **Domain**, and **Data** layers.

This ensures your business logic (Domain) is independent of UI (Presentation) and External APIs (Data).

### Proposed Structure
```text
lib/
├── main.dart
├── core/
├── features/
│   ├── chat/
│   │   ├── data/           # Repositories & API sources
│   │   ├── domain/         # Entities & Logic (No Flutter code here)
│   │   └── presentation/   # Widgets, Pages, State Providers
│   ├── tasks/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
```

**Pros:**
*   Extremely testable.
*   Easy to switch backends (e.g., Firebase to SQL) without breaking UI.

**Cons:**
*   **Overkill** for simple apps.
*   More boilerplate code (more files to create).

---

## 🔍 Antigravity’s Recommendation

**Go with Method 2: Feature-Based.**

**Why?**
Your project has distinct, large modules like `ai_chat`, `memory`, `calendar`, and `notes`.
1.  **Cleanup**: You have huge files like `ai_chat_page.dart` (300KB+). Grouping by feature allows you to adhere to the principle: "One file, one purpose". You can break that huge file into `features/chat/widgets/message_bubble.dart`, `features/chat/logic/chat_controller.dart`, etc.
2.  **Scalability**: It allows developers to work on "Notes" without worrying about breaking "Chat".
3.  **Simplicity**: It is simpler than Method 3 but more organized than Method 1.

### Recommended Next Steps
1.  Create the `features` folder.
2.  Move `pages/ai_chat_page.dart` related code into `lib/features/chat/`.
3.  Extract logical parts (API calls) out of the UI files into `services`.
4.  Extract UI parts (Widgets) into `widgets`.
