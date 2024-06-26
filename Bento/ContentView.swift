import SwiftUI

extension EnvironmentValues {
    @Entry var direction: Axis = .vertical
}

struct SplitItem {
    var children: [SplitItem] = []

    var numberOfChildren: Int {
        children.isEmpty ? 1 : children.reduce(0) {
            $0 + $1.numberOfChildren
        }
    }
}

let sample = SplitItem(children: [
    .init(children: [
        .init(),
        .init(children: [
            .init(),
            .init(),
        ])
    ]),
    .init(children: [
        .init(children: [
            .init(),
            .init()
        ]),
        .init(),
    ]),
    .init(),
])

struct Bento<Content: View>: View {
    var split: SplitItem
    @ViewBuilder var content: Content

    var body: some View {
        Group(subviewsOf: content) { collection in
            BentoHelper(split: split, collection: collection[...])
        }

    }
}

struct BentoHelper: View {
    var split: SplitItem
    var axis: Axis = .vertical
    var collection: SubviewsCollection.SubSequence

    func subviewRange(for index: Int) -> Range<Int> {
        if index == 0 {
            return collection.startIndex..<(collection.startIndex + split.children[0].numberOfChildren)
        } else {
            let previous = subviewRange(for: index - 1)
            return previous.upperBound..<(previous.upperBound + split.children[index].numberOfChildren)
        }
    }

    var body: some View {
        let layout = axis == .vertical ? AnyLayout(VStackLayout()) : .init(HStackLayout())
        layout {
            if split.children.count == 0 {
                collection.first
            } else {
                ForEach(0..<split.children.count, id: \.self) { idx in
                    BentoHelper(split: split.children[idx], axis: axis.other, collection: collection[subviewRange(for: idx)])
                }
            }
        }
    }
}

extension Axis {
    var other: Self {
        self == .horizontal ? .vertical : .horizontal
    }
}

struct Split<Content: View>: View {
    @Environment(\.direction) var axis
    @ViewBuilder var content: Content
    var body: some View {
        let layout = axis == .horizontal ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
        layout {
            content
        }
        .environment(\.direction, axis.other)
    }
}

struct ContentView: View {
    var body: some View {
        Bento(split: sample) {
            Color.blue
            Color.green
            Color.yellow
            Color.teal
                .frame(width: 20, height: 20)
            Color.black
            Color.blue
            Color.green
            Color.yellow
            Color.teal
            Color.black
        }
    }
}

#Preview {
    ContentView()
}
