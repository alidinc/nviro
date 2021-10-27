# nviro
An eco-friendly travel guide app.

![Screenshot 2021-10-27 at 4 21 53 pm](https://user-images.githubusercontent.com/78941775/139097124-5627e51b-2b0e-4a39-a20e-6d2b7eb91609.png)


# Implementation

There are six view controllers. The first one is the SearchViewController that users can make a search for a city/country from a text field to show air pollution measurements in the second view controller SearchDetailViewController. Users can then save any favourite cities in their list by tapping on a heart icon inside the SearchDetailViewController to navigate them to VenueMapViewController. In this venue view, users can explore vegan & vegetarian venues around the saved location. In the fifth view controller that is CarbonCalculateViewController, users can calculate their carbon offset simply by making a search for an airport from text fields. Then they'll see an animated CarbonResultsViewController. In the last main view controller, users can read the latest news about climate change.

Describe the main view controllers of the app and what they do more in detail

# How to build

Users can run nviro on any iPhones. Just simply start using any tabs to explore the app. Only SavedPlacesViewController is dependant on the SearchDetailViewController to like/save a location.

# Requirements

Xcode 8
Swift 5
.....
