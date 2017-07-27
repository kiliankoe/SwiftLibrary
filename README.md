![header](https://user-images.githubusercontent.com/2625584/28693159-c1ae88fa-7323-11e7-8ce3-1980fdf2a925.png)



Apodidae is intended to be the quickest way to search for packages in the Swift ecosystem. By design, Swift pulls dependencies from any git repo, most of which are hosted on GitHub, but distributed amongst many thousands of users. This is fantastic to work with, but what it gains in ease of use, this method definitely lacks in discoverability.

IBM has committed to building a fantastic catalog of packages aptly named [Package Catalog](https://packagecatalog.com). Whilst being a wonderful idea, a website is slow to use. Swift deserves a tool to find packages *swiftly*. Apodidae aims to be that tool.

**tl;dr:** Apodidae is a command-line utility that serves as a client for packagecatalog.com.



## Installation

Apodidae is still at a very, *very* early point in its life. At this point you're still going to have to build it yourself, sorry. This will hopefully change soon enough.



## Usage

Apodidae exposes a handful of commands. Their use is probably best shown with a few examples.

#### Searching for packages

```shell
$ apo search RxSwift
- ReactiveX/RxSwift 3.6.1
  https://github.com/ReactiveX/RxSwift
  Reactive Programming in Swift
- RxSwiftCommunity/Action 3.1.1
  https://github.com/RxSwiftCommunity/Action
  Abstracts actions to be performed in RxSwift
...
```

#### Getting info on a package

```shell
$ apo info ReactiveX/RxSwift
ReactiveX/RxSwift 3.6.1
https://github.com/ReactiveX/RxSwift
Reactive Programming in Swift

10155 stargazers
MIT License
Supports Swift 3.0

Last published: 14 hours ago
Last Versions: 3.6.1, 3.6.0, 3.5.0, 3.4.1, 3.4.0@swift-3, 3.4.0, 3.3.1, 3.3.1@swift-3, 3.3.0, 3.3.0@swift-3, ...

Dependencies:
   None
```

You can also run `apo home ReactiveX/RxSwift` to directly open the homepage to a specific package in your browser. You may know this feature from homebrew.

#### Adding a package

```shell
$ apo add ReactiveX/RxSwift
The following has been copied to your clipboard. Go ahead and paste it into your Package.swift's dependencies.

.package(url: "https://github.com/ReactiveX/RxSwift", from: "3.6.1")

Please bear in mind that apodidae can not know if it is actually possible to include this package in your project.
This is just some available package from packagecatalog.com including its last publicized version.
```

Apodidae will try to figure out if the project in the current directory uses Swift 3 or 4 and output accordingly. You can also override manually using the `--swiftversion x` flag.

#### Submitting a package to IBM's Package Catalog

```shell
$ apo submit https://github.com/ReactiveX/RxSwift
Package successfully submitted to packagecatalog.com
```

If you want to submit the package in your current working directory you can just leave off the URL. Apodidae will try and read it from your git remote instead.



## Known Issues

At this point? Several 🙈

Found something as well? Please don't hesitate to [open an issue](https://github.com/kiliankoe/apodidae/issues/new).



## Why "apodidae"?

The *Apodidae* or *swifts* are a family of highly aerial birds. This tool aims to help you find something within that "family". And it nicely abbreviates as a CLI to `apo`.

