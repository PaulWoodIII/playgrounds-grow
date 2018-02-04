//: Playground - noun: a place where people can play

import Foundation

/*:
 #Lets Grow some code into plants
 
 Today we are going to learn about Plants and Code and show you how easy it is to think like a programer and like a gardener. You will see how coding can make anyones life easier
 
 To get us started we need to talk about how plants grow and make a mental model for them
 
 Most gardeners will grow plants because they are beautiful or produce fruits and vegetables. All plants are special but grass is super simple and most people have seen it so lets start with what it takes to code grass
 
 Plants take time to grow from their seed
 
*/

class Plant {
  let name = "Grass"
  var waterLevel = 0.0
  var growthLevel = 0.0
}

class Lawn {
  
  var plant: Plant
  
  init(_ p: Plant){
    plant = p
  }
  
  func sow(_ incPlant: Plant){
    plant = incPlant
  }
  
  func water() {
    plant.waterLevel = 1.0
  }
  
  func waitOneDay() {
    print("Day Break!")
  }
}

print("Day Break")
var lawn = Lawn(Plant())
lawn.water()
print("\(lawn.plant.name)'s water level \(lawn.plant.waterLevel)")

