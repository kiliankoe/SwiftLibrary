![header](https://user-images.githubusercontent.com/2625584/28789219-b9ffed5c-7624-11e7-8959-792171e75deb.png)


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

Apodidae exposes a handful of commands. Their use is probably best shown with a few examples. [Here's a link](https://asciinema.org/a/131508) to asciinema for a short usage demo recording if you prefer that.

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

You can also run `swift catalog home rxswift` to directly open the homepage to a specific package in your browser. You may know this feature from homebrew.

#### Adding a package

```
$ swift catalog add rxswift
The following has been copied to your clipboard for convenience, just paste it into your package manifests's dependencies.
.package(url: "https://github.com/ReactiveX/RxSwift", from: "3.6.1"),
```

Apodidae will try to figure out if the project in the current directory uses Swift 3 or 4 and output accordingly. You can also override manually using the `--swiftversion n` flag.

It's also possible to add a specific version or other requirement. All you have to do is add `@requirement` to the end of the package. This syntax may feel familiar if you've used npm. The following all work.

````shell
$ swift catalog add rxswift@3.6.1
$ swift catalog add rxswift@tag:3.6.1 # same as above
$ swift catalog add rxswift@version:3.6.1 # same as above
$ swift catalog add rxswift@branch:master
$ swift catalog add rxswift@revision:80de962
$ swift catalog add rxswift@commit:80de962 # same as above
````



For convenience a shorthand syntax for the available commands is also available. You can use `s` instead of `search`, `i` instead of `info`, `h` instead of `home` and `a` or `+` instead of `add`.



## Questions or Feedback

Did you run into any issues or have questions? Please don't hesitate to [open an issue](https://github.com/kiliankoe/apodidae/issues/new) or find me [@kiliankoe](https://twitter.com/kiliankoe) on Twitter.



## FAQ

###  Why don't you use PackageCatalog.com, SwiftModules.com, Libraries.io, ...?

These pages are a great idea and are well implemented, but they all use GitHub as a datasource and have to continually refresh their own databases by pulling new data from GitHub periodically. By design, they can't always be 100% up to date and more importantly, they can't automatically know about new packages when they're published. They rely on users manually adding packages or continually searching for new repos themselves.

By having apodidae search on GitHub directly we can circumvent those issues and are still able to find all packages including their metadata.


### Why "apodidae"?

The *Apodidae* or *swifts* are a family of highly aerial birds. This tool aims to help you find something within that "family".

Why the project? I was missing something akin to npm's search functionality for Swift. So here it is 🙃

