//
//  Constants.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import Foundation

class Constants {
    
    enum Identifiers {
        static let collectionItemId = "placeItem"
        static let toDetailVC = "toDetailVC"
        static let searchTableViewCellNibName = "SearchTableViewCell"
        static let searchTableViewCellId = "placeCell"
        static let searchDetailCollectionViewCellNibName = "CityImageCollectionViewCell"
        static let searchDetailCollectionViewItemID = "cityImageItem"
        static let savedCollectionViewItemNibName = "SavedCollectionViewCell"
        static let savedCollectionViewItemID = "placeItem"
        static let airportsTableVCCellID = "airportCell"
        static let newsTableViewCellID = "newsCell"
        static let newsTableViewCellNibName = "NewsTableViewCell"
        static let restaurantCellId = "restaurantCell"
        static let restaurantCellNibName = "RestaurantCell"
    }
    
    enum ViewControllers {
        static let tabBarVC = "tabBarVC"
        static let signUpVC = "signUpVC"
        static let carbonCalculateVC = "CarbonCalculateVC"
        static let popUpImageVC = "PopupImageVC"
        static let savedVC = "SavedVC"
        static let airportsVC = "airportsTableVC"
        static let newsVC = "newsVC"
        static let cityDetail = "cityDetailVC"
        static let restaurantsListVC = "restaurantsListVC"
    }
    
    enum Storyboards {
        static let main = "Main"
        static let searchDetail = "SearchDetail"
        static let restaurantsList = "RestaurantsList"
    }
    
    enum ErrorMessages {
        static let credentials = "Please check your credentials."
        static let locationSearch = "There's an error with the local search completer. Please try again."
        static let noResults = "There aren't any results for this location."
        static let savingError = "We had a problem to save your selected location."
    }
    
    enum LabelTexts {
        static let carbonLabelInitialText = "Press calculate to see your carbon results."
    }
    
    enum ApiKeys {
        static let flightOffsetDeveloperKey = "9e7f65db-6e3d-4643-b30b-1f4e66f25b3f"
        static let flightOffsetPartnerKey = "90f093ec-0cfe-4b27-9ba2-58bd4de65a95"
        static let foursquareClientId = "GX4NHXFVDOAQSQERRTHS1FM2KD2OS5T51E5UEN1ABEVEIXT0"
        static let foursquareClientScreet = "N4HWDWO1GR2RIO3CDYBM31KS23KUYMIZNJZ1EZRWNIEH4N0M"
        static let googleCloudApiKey = "AIzaSyBCDNB2Fkv7pz8gG0EXXYnbCGdlZLeQtRw"
    }
    
    
    
}

