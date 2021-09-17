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
    }
    
    enum ViewControllers {
        static let tabBarVC = "tabBarVC"
        static let signUpVC = "signUpVC"
        static let carbonCalculateVC = "CarbonCalculateVC"
        static let popUpImageVC = "PopupImageVC"
        static let savedVC = "SavedVC"
    }
    
    enum Storyboards {
        static let main = "Main"
        static let searchDetail = "SearchDetail"
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
    
    
    
    
}

