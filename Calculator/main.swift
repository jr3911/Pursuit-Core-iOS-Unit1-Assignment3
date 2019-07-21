//
//  main.swift
//  calculator
//
//  Created by Jason Ruan on 7/18/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import Foundation


let operations: ([String: (Double, Double) -> Double]) = ["+": { $0 + $1 },
                                                          "-": { $0 - $1 },
                                                          "*": { $0 * $1 },
                                                          "/": { $0 / $1 }]

func getOperation() {
    print("\nEnter your operation, e.g. 4 + 20")
    let permissibleCharacters  = "1234567890"
    var finished = false
    let input = readLine()
    if let response = input {
        //makes sure the operands begin and end with a number
        if response.first?.isNumber == false || response.last?.isNumber == false {
            print("Operands must comprise of only digits 0-9")
            return getOperation()
        }
        //makes sure the array has three elements, hopefully two operands and one operator
        var arr = response.components(separatedBy: " ")
        if arr.count != 3 {
            print("Please enter an operation in the format of this example: 2 + 2")
            return getOperation()
        }
        //checks to see if the operator is '?' and then reassigns it a random operator in the dictionary
        if arr[1] == "?" {
            arr[1] = operations.keys.randomElement()!
        }
        //checks to see if the operator is actually an operator now
        if operations.keys.contains(arr[1]) == false {
            print("Unknown operator: \(arr[1])")
            return getOperation()
        }
        //checks to see if the operands are actually numbers, and ONLY numbers
        for i in 0...2 {
            if i == 1 {
                continue
            }
            for char in arr[i] where permissibleCharacters.contains(char) == false || operations.keys.contains(String(char)) == true {
                print("Operands must comprise of only digits 0-9")
                return getOperation()
            }
        }
        //prints out the result of the operation and does a little mini-game if the user input '?' as operator before
        while finished == false {
            if let equation = operations[arr[1]] {
                if response.contains("?") == true {
                    print("\(response) = \(equation(Double(arr[0])!, Double(arr[2])!))")
                    print("Guess the missing operator!")
                    let guess = readLine()
                    if guess == arr[1] {
                        finished = true
                        print("\nCorrect!\n")
                    } else {
                        print("\nNope!\n")
                    }
                } else {
                    finished = true
                    print("\(response) = \(equation(Double(arr[0])!, Double(arr[2])!))")
                }
            }
        }
    }
}

//filters out numbers '<' or '>' than the number provided
func myFilter(_ inputArray: [Int],_ filter: (Int) -> Bool) {
    var sortedArr = [Int]()
    for num in inputArray.sorted() where filter(num) == true {
        sortedArr.append(num)
    }
    print(sortedArr)
}

//prints out new array based on the operator's effect on the original array
func myMap(_ inputArray: [Int],_ map: (Int) -> Int) {
    var changedArr = [Int]()
    for num in inputArray {
        changedArr.append(map(num))
    }
    print(changedArr)
}

//prints out the result of the operation as an 'Int'    ** does not deal with decimals well since it is an Int, therefore the actually answer may be off by 1
func myReduce(_ inputArray: [Int],_ reduce: (Int) -> Int) {
    var result = 0
    for num in inputArray {
        result += reduce(num)
    }
    print(result)
}


func getHigherOrderInput() -> (String, [Int], String, Int) {
    print("\nEnter your operation e.g. filter 1,5,2,7,3,4 by < 4")
    //these are the permissible characters to be cross-referenced with the user's input
    let permissibleCharacters  = "1234567890"
    let commands = ["filter", "map", "reduce"]
    let mathOperators = ["<", ">", "*", "/", "+", "-"]
    
    let userInput = readLine()
    if let userInput = userInput {
        let arrInput = userInput.components(separatedBy: " ")
        //checks to see if the user's input conforms to the format as described in the example
        if arrInput.count != 5 || commands.contains(arrInput[0]) == false || mathOperators.contains(arrInput[3]) == false || arrInput.last?.last?.isNumber == false || arrInput[1].contains(",") == false {
            return getHigherOrderInput()
        }
        //creates a new array that represents the array of Ints to be used as parameter in myFilter, myMap, and myReduce
        let stringNumInput = arrInput[1].components(separatedBy: ",")
        //checks to see if the user put consecutive commas without anything in between, and checks to see if the elements are ONLY numbers
        for element in stringNumInput where element == "" || permissibleCharacters.contains(element) == false {
            return getHigherOrderInput()
        }
        //convert array of strings of numbers into array of Ints
        var numInput = [Int]()
        for char in stringNumInput {
            numInput.append(Int(char)!)
        }
        //return the string for function, the array of Ints, the string for operator, and the Int for function
        return (arrInput[0], numInput, arrInput[3], Int(arrInput[4])!)
    }
    //do it again if the user input is invalid
    return getHigherOrderInput()
}

func commandLineMathStuff() {
    print("\nEnter type of calculation, 1 (regular) or 2 (high order)?")
    let input = readLine()
    if let input = input {
        if input == "1" {
            getOperation()
        } else if input == "2" {
            let userResponse = getHigherOrderInput()
            switch userResponse.2 {
            case "<":       //filters out numbers in array that are less than the number user had input
                myFilter(userResponse.1) {
                    return $0 < userResponse.3
                }
            case ">":       //filters out numbers in array that are greater than the number user had input
                myFilter(userResponse.1) {
                    return $0 > userResponse.3
                }
            case "*":       //prints out the multiples of the original numbers after multiplying them by the number user had input
                if userResponse.0 == "map" {
                    myMap(userResponse.1) {
                        return $0 * userResponse.3
                    }
                } else if userResponse.0 == "reduce" {
                    //prints out the sum from adding the multiples of the original numbers after multiplying them by the number user had input
                    myReduce(userResponse.1) {
                        return $0 * userResponse.3
                    }
                }
            case "/":       //prints out the quotients of the original numbers after dividing them by the number user had input
                myMap(userResponse.1) {
                    return $0 / userResponse.3
                }
            case "+":       //prints out the sum of original numbers starting from the number the user had input
                myReduce(userResponse.1) {
                    return $0 + (userResponse.3 / userResponse.1.count)
                }
            default:
                print("Didn'tWork")
            }
        } else {
            return commandLineMathStuff()
        }
    }
    //asks user if they want to run the program again
    print("\nCalculate again? Enter 'y' for yes or any other button for no")
    let again = readLine()
    if again == "y" {
        return commandLineMathStuff()
    }
}
//actually calls the function to start the program
commandLineMathStuff()


