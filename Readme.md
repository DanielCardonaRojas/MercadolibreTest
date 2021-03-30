# Mercadolibre Clone

[![Unit tests](https://github.com/DanielCardonaRojas/MercadolibreTest/actions/workflows/CI.yaml/badge.svg)](https://github.com/DanielCardonaRojas/MercadolibreTest/actions/workflows/CI.yaml)

A Mercado libre client, searching and displaying a product list and detail screen.

This app consumes the search, products and suggestions API from: https://api.mercadolibre.com

![preview](https://github.com/DanielCardonaRojas/MercadolibreTest/blob/main/mercado_libre_clone.gif)

# Features

- Shows paginated search results, landscape (2 items per row) and portrait
- Shows suggestion while typing in search bar
- Shows product detail information
- Empty state for no results

# About this project

**Architecture**

This app uses MVVM pattern

The folder structure is simple and consists of 4 top level folder. 
Each of which could be eventually become a logical (modules/Frameworks) in a Clean architecture style.

- Data: All data manipulating classes, from remote to local data,
  will usually also contain (DTO/Model) definitions.

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

All layout in this app is done with Autolayout via code or IB, for this I like to use some conveniences
that I have developed in the past which provide more declarative style [KeypathAutoLayout](https://github.com/DanielCardonaRojas/KeypathAutolayout)

**Image gallery and network images**

A couple extra dependencies have been used to fetch images from the network
and to create a image gallery which would be a very time consuming task otherwise.

- Images from network [SDWebImage](https://github.com/SDWebImage/SDWebImage)
- Image gallery [Auk](https://github.com/evgenyneu/Auk)
- Spinner animation [Lottie](https://github.com/airbnb/lottie-ios)
