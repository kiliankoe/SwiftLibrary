![header](https://user-images.githubusercontent.com/2625584/28693159-c1ae88fa-7323-11e7-8ce3-1980fdf2a925.png)


[![Travis](https://img.shields.io/travis/kiliankoe/apodidae.svg?style=flat-square)](https://travis-ci.org/kiliankoe/apodidae/)
[![GitHub (pre-)release](https://img.shields.io/github/release/kiliankoe/apodidae/all.svg?style=flat-square)]()

Apodidae is intended to be the quickest way to search for packages in the Swift ecosystem. By design, Swift pulls dependencies from any git repo, most of which are hosted on GitHub, but distributed amongst many thousands of users. This is fantastic to work with, but what it gains in ease of use, this method definitely lacks in discoverability.

Luckily, GitHub offers a great API which can be utilizied to search for possible dependency candidates for your projects. Apodidae searches for repositories written in Swift that also include a package manifest and match your query thus making the search for packages a very *swift* matter.

**tl;dr:** Apodidae is a command-line utility that searches for swift packages on GitHub and helps you add these to your `Package.swift`.



## Installation

```
$ brew tap kiliankoe/formulae
$ brew install apodidae
```

Apodidae conveniently installs as `swift-catalog` which enables you to just call it as if it were a subcommand on swift itself as `swift catalog ...`. See the usage examples below for more.



## Usage

Apodidae exposes a handful of commands. Their use is probably best shown with a few examples. [Here's a link](https://asciinema.org/a/130908) to asciinema for a short usage demo recording if you prefer that.

#### Searching for packages

```
$ swift catalog search rxswift
- ReactiveX/RxSwift 3.6.1
  https://github.com/ReactiveX/RxSwift
  Reactive Programming in Swift
- Moya/Moya 9.0.0-alpha.1
  https://github.com/Moya/Moya
  Network abstraction layer written in Swift.
- devxoul/RxViewController 0.2.0
  https://github.com/devxoul/RxViewController
  RxSwift wrapper for UIViewController and NSViewController
...
```

#### Getting info on a package

```
$ swift catalog info rxswift
ReactiveX/RxSwift 3.6.1
https://github.com/ReactiveX/RxSwift
Reactive Programming in Swift

10181 stargazers
MIT License

Last activity: 2017-07-29 14:30:05
Last versions: 3.6.1, 3.6.0, 3.5.0, 3.4.1, 3.4.0
```

You can also run `apo home rxswift` to directly open the homepage to a specific package in your browser. You may know this feature from homebrew.

#### Adding a package

```
$ swift catalog add rxswift
The following has been copied to your clipboard for convenience, just paste it into your package manifests's dependencies.

.package(url: "https://github.com/ReactiveX/RxSwift", from: "3.6.1")

Please bear in mind that apodidae can not be sure if it is actually possible to include this package in your project.
It can only be safely assumed that this is a package written in Swift that contains a file named 'Package.swift'. It
might also be an executable project instead of a library.
```

Apodidae will try to figure out if the project in the current directory uses Swift 3 or 4 and output accordingly. You can also override manually using the `--swiftversion n` flag.



## Questions or Feedback

Did you run into any issues or have questions? Please don't hesitate to [open an issue](https://github.com/kiliankoe/apodidae/issues/new) or find me [@kiliankoe](https://twitter.com/kiliankoe) on Twitter.



## Why "apodidae"?

The *Apodidae* or *swifts* are a family of highly aerial birds. This tool aims to help you find something within that "family".

Why the project? I was missing something akin to npm's search functionality for Swift. So here it is 🙃

