# DogAPI

An iOS demo project in Swift for fetching all dog breeds collection work in offline.


#### Requirements : 
Swift 4.1, Xcode 10.1

#### Overview : 
In this project I have create breed list and breed photo gallery using MVVM architecture and along with UI Testing and some unit test cases(not working currently).

#### Classes uses: 
* **BreedListViewController** : Display all breed list in listview. 
* **BreedListViewModel** : Fetching breed list from server and save into coredata.
* **BreedPhotoGalleryViewController** : Display photos of breed and subbreed.
* **BreedGalleryViewModel** : Fetching breed images from server and save into coredata.

#### Network: 
* **NetworkService** : Api call methods.

#### CoreData: 
* **StorageManager** : Core Data manager class.

#### Testing :
 ##### Unit test :
   **BreedListViewModelTest** : Testing breed list network call and core data.
  ##### UI test :
   **BreedListUITest** : Testing breed list and search breed and navigation.
   
 #### Screen Shot 
  <img src="https://github.com/ShitalTJadhav/DogAPI/blob/master/ScreenShot/Simulator%20Screen%20Shot%20-%20iPhone%20X%20-%202019-03-24%20at%2017.55.35.png" width="200" height="400" />  <img src="https://github.com/ShitalTJadhav/DogAPI/blob/master/ScreenShot/Simulator%20Screen%20Shot%20-%20iPhone%20X%20-%202019-03-24%20at%2017.57.15.png" width="200" height="400" />

