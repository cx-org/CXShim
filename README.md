# CXShim

[![Github CI Status](https://github.com/cx-org/CXShim/workflows/CI/badge.svg)](https://github.com/cx-org/CXShim/actions)
![Install](https://img.shields.io/badge/install-Swift_Package_Manager-ff69b4)
![Supported Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey)

CXShim is a virtual Combine interface that allows you to switch berween system Combine and open source Combine.

> With CXShim, you shoudn't write different code for different Combine. If you find you are in need of it, please file an issue.

## Installation

Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/cx-org/CXShim", .upToNextMinor(from: "0.4.0"),
```

#### Requirements

- Swift 5.0+

## Q&A

#### Why do I need it?

Because Combine has system limitation, and open source Combine doesn't compatible with SwiftUI. With CXShim, You can easily write one package that compatible with SwiftUI, support Linux, and can backward deploy to iOS 9.0.

#### Is there any downside?

No, CXShim introduce no extra dependency, no runtime cost, no binary size incrementation. It's not infectious. Migrating from Combine to CXShim is a non-breaking change.

#### Looks great! How can I adopt it?

If your package use Combine, just replace every `import Combine` with `import CXShim`, everything will still works fine. And with [a little adjustment](https://github.com/cx-org/CombineX/wiki/Combine-Migration-Guide), your package can support Linux and lower system as well.

#### Why this library requires iOS 13+ / macOS 10.15+?

Because system Combine is used by default on Apple platforms. Don't worry, you can choose open source Combine manually and get rid of system requirement.

#### How do I choose which Combine to use?

You can choose Combine implementation by setting environment variable `CX_COMBINE_IMPLEMENTATION`.

Library | Value of `CX_COMBINE_IMPLEMENTATION`
--- | ---
[Combine](https://developer.apple.com/documentation/combine) (default on Apple platforms) | `Combine`
[CombineX](https://github.com/cx-org/CombineX) (default on Linux) | `CombineX`
Others | [See below](#can-i-use-other-open-source-combine)

```shell
$ export CX_COMBINE_IMPLEMENTATION=CombineX

# for CLI tools, execute with env variable
$ swift build ...
$ xcodebuild ...

# for Xcode GUI, reopen Xcode with env variable
$ killall Xcode
$ open Package.swift
```

#### How it actually works?

`CXShim` conditionally re-export appropriate Combine implementation. It also fill the gap between different Combine. For example, you would have needed to write different code for `Combine` and `CombineX`:

```swift
#if BACKWARD_DEPLOYMENT // we are target on lower system and use CombineX
// This method is under cx namespace because `URLSession.dataTaskPublisher` 
// can't be overloaded and always use system Combine.
let pub = URLSession.shared.cx.dataTaskPublisher(for: url)
#else // use system Combine
let pub = URLSession.shared.dataTaskPublisher(for: url)
#endif
```

With `CXShim`, you don't need compilation flags anymore:

```swift
import CXShim
// `cx` namespace is available even if you're using system Combine
let pub = URLSession.shared.cx.dataTaskPublisher(for: url)
```

#### Can I use other open source Combine?

Yes you can! `CXShim` support every known Combine implementations and will support any future one. Just set environment variable `CX_COMBINE_IMPLEMENTATION` to their respective value. If your library is not listed below, feel free to open an issue.

Library | Value of `CX_COMBINE_IMPLEMENTATION`
--- | ---
[OpenCombine](https://github.com/broadwaylamb/OpenCombine) | `OpenCombine`

> Disclaimer: These project are not part of CombineX. They may have different consistent level with Apple's Combine than [we promised](https://github.com/cx-org/CombineX/wiki/Combine-Consistency), and not necessarily pass our test suit. We do not make any warranty of any kind for them.
