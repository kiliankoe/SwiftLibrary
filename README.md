![header](https://user-images.githubusercontent.com/2625584/63201247-a94b2100-c084-11e9-960e-b3c479dd4afe.png)

SwiftLibrary is intended to be the quickest way to search for packages in the Swift ecosystem. By design, Swift pulls dependencies from any git repo, most of which are hosted on GitHub, but distributed amongst many thousands of users. This is fantastic to work with, but what it gains in ease of use, this method definitely lacks in discoverability.

Fortunately, projects like [swiftpm.co](https://swiftpm.co) (big thanks to [Dave Verwer](https://daveverwer.com)!) exist, which is a relatively new and growing index of Swift packages. Using SwiftLibrary you can search that index directly from your CLI and quickly find the package you're looking for.


## Installation

```
$ brew tap kiliankoe/formulae
$ brew install swiftlibrary
```

SwiftLibrary conveniently installs as `swift-library` which enables you to just call it as if it were a subcommand on swift itself as `swift library ...`. See the usage examples below for more.

You can of course also install SwiftLibrary manually.

```
$ git clone https://github.com/kiliankoe/SwiftLibrary
$ cd SwiftLibrary
$ swift build -c release
$ cp .build/release/swift-library /usr/local/bin/swift-library
```



## Usage

SwiftLibrary exposes a handful of commands. Their use is probably best shown with a few examples.

#### Searching for packages

```
$ swift library search yaml
- behrang/YamlSwift
  https://github.com/behrang/YamlSwift.git
  Load YAML and JSON documents using Swift
- jpsim/Yams
  https://github.com/jpsim/Yams.git
  A Sweet and Swifty YAML parser.
...
```

#### Getting info on a package

```
$ swift info info yams
jpsim/Yams 2.0.0
A Sweet and Swifty YAML parser.

407 stargazers
407 watchers

Licensed under MIT.
Supports Swift 5, 4.2, 4.
Last released: 4 months ago.
Contains 1 library/libraries.
Contains 0 executable(s).
```

You can also run `swift library home yams` to directly open the homepage to a specific package in your browser. You may know this feature from homebrew.

#### Adding a package

```
$ swift library add yams
Your clipboard has been updated, just add it to your package manifest.
```

For the time being SwiftLibrary will not edit your manifest directly, but add everything you need to your clipboard so you can paste it directly into your package manifest.

It's also possible to add a specific version or other requirement. All you have to do is add `@requirement` to the end of the package. This syntax may feel familiar if you've used npm. The following all work.

````shell
$ swift library add yams@2.0.0
$ swift library add yams@tag:2.0.0 # same as above
$ swift library add yams@version:2.0.0 # same as above
$ swift library add yams@branch:master
$ swift library add yams@revision:c947a30
$ swift library add yams@commit:c947a30 # same as above
````



For convenience a shorthand syntax for the available commands is also available. You can use `s` instead of `search`, `i` instead of `info`, `h` instead of `home` and `a` or `+` instead of `add`.



## Questions or Feedback

Did you run into any issues or have questions? Please don't hesitate to [open an issue](https://github.com/kiliankoe/SwiftLibrary/issues/new) or find me [@kiliankoe](https://twitter.com/kiliankoe) on Twitter.
