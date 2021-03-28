# Mercadolibre Clone

A simple app, searching and displaying a product list, and detail screen.

This app consumes the search and items API from: https://api.mercadolibre.com

# About this project

**Arquitecture**

This app uses MVVM approach

The folder structure is simple generally I like to think of
these main layers in any app. One benefit to this is that the app could be split
into logical (modules/Frameworks) and be a Clean arquitecture

- Data: All data manipulating classes, from remote to local data,
  will usually also contain (DTO/Model) definitions

- Application: Where business logic goes. In this case where ViewModels will be located

- UI: A place for `UIViewController` and `UIView` subclasses

- Utils: A module for shared code, will usually put reusable extensions, constants,
  and other business independent code in here.

**UI**

Uses a mix of Interface Builder and some programmatic UI with Autolayout.

**Testing**

This app has some unit tests mainly to tests ViewModels which is the most importat part to test in
an app using MVVM

**Code style guidelines**

This project uses swiftlint to ensure consistent code style.

## Dependencies

All dependencies are installed with SPM which comes bundled in Xcode. So no need to install
any other tool, should work out of the box.

**Networking**

This app uses a custom networking layer developed by me [APIClient](https://github.com/DanielCardonaRojas/APIClient)
which is a convenient light weight wrapper around URLSession.

**Layout**

Some layout in this app is done with Autolayout via code, for this I like to use some conveniences
that I have developed in the past. Some simple conveniences that provide more declarative style
to layout [KeypathAutoLayout](https://github.com/DanielCardonaRojas/KeypathAutolayout)

**Image gallery and network images**

A couple extra dependencies have been used to fetch images from the network
and to create a image gallery which would be a very time consuming task otherwise.

- Images from network [SDWebImage]()
- Image gallery [Auk]()
