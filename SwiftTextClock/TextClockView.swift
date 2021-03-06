//
//  TextClockView.swift
//  SwiftTextClock
//
//  Created by Michael Teeuw on 01-11-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

import UIKit

class TextClockView: UIView {
    
    let ON_ALPHA:CGFloat = 1.0                      // Brightness of the highlighted digits
    let OFF_ALPHA:CGFloat = 0.20                    // Brightness of the powered off digits
    let FADE_SPEED:NSTimeInterval = 1.0             // The fade speed when the digits change
    let TEXT_COLOR = UIColor.whiteColor()           // Color of the digits

    // Define the rows of characters
    let characters = [
        "ITLISASTIME",
        "ACQUARTERDC",
        "TWENTYFIVEX",
        "HALFBTENFTO",
        "PASTERUNINE",
        "ONESIXTHREE",
        "FOURFIVETWO",
        "EIGHTELEVEN",
        "SEVENTWELVE",
        "TENSEOCLOCK"
    ]
    
    // Define the locations of the words
    let words = [
        "IT": 0 + 0, "IS": 0 + 3,
        "A": 11 + 0, "QUARTER": 11 + 2,
        "TWENTY": 22 + 0, "FIVE": 22 + 6,
        "HALF": 33 + 0, "TEN": 33 + 5, "TO": 33 + 9,
        "PAST": 44 + 0, "H-NINE": 44 + 7,
        "H-ONE": 55 + 0, "H-SIX": 55 + 3, "H-THREE": 55 + 6,
        "H-FOUR": 66 + 0, "H-FIVE": 66 + 4, "H-TWO": 66 + 8,
        "H-EIGHT": 77 + 0, "H-ELEVEN": 77 + 5,
        "H-SEVEN": 88 + 0, "H-TWELVE": 88 + 5,
        "H-TEN": 99 + 0, "OCLOCK": 99 + 5
    ]
    
    // Define th string we use in the list above to identifier the hour digits.
    // This is nessecery to distinguish the difference between the two
    // five minutes, and five hour digits.
    let HOUR_IDENTIFIER = "H-"
    
    // Create an Array to store all the references to the views.
    var characterViews = [CharacterView]();
    
    // Create a instance variable for the last displayed time.
    var lastDisplayedTimeString = ""
    
    /**
    Overwrite all the to run setup when they are initialised. 
    This is only nessecery for the coder & frame initializers.
    */
    
    override init()
    {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup();
    }

    /**
    Setup the view. We need to create views for every charater and add them to the characterViews Array.
    */
    func setup() {
        
        // Loop thru all the rows of characters.
        var rowIndex = 0;
        for row in characters {
            
            // Loop thru all the characters
            var characterIndex = 0;
            for character in row {
                
                // Create the views and add them to the characterViews Array.
                let characterView = createCharacterView(character, rowIndex: rowIndex, characterIndex: characterIndex)
                characterViews.append(characterView)
                characterIndex++
            }
            
            rowIndex++;
        }
        
        // If the setup is done, run update to show the current time.
        update()
    }
    
    /**
    To create the characterViews, we use a function that does all the work including adding the constraints.
    
    @param char:Character       The character we want to display.
    @param rowIndex:Int         The row of the character.
    @param characterIndex:Int   The index of the character in the current row.
    
    @return The CharacterView that is created for the character.
    */
    func createCharacterView(char:Character, rowIndex:Int, characterIndex:Int) -> CharacterView {
        
        //Create a view and add it to self.
        let characterView = CharacterView()
        addSubview(characterView)
        
        // Disable the automatic constraints
        characterView.setTranslatesAutoresizingMaskIntoConstraints(false);
        
        // Calculate the sizing factors we need for the autoloayout constraints
        // This we we know where to position the views
        let widthFactor:CGFloat = 1.0 / CGFloat(countElements(characters[0]))
        let heightFactor:CGFloat = 1.0 / CGFloat(characters.count)
        
        let topFactor:CGFloat = 1.0 / CGFloat(characters.count) * CGFloat(rowIndex)
        let leftFactor:CGFloat =  1.0 / CGFloat(countElements(characters[0])) * CGFloat(characterIndex)
        
        // Add the constraints to position and size the character to the right posistion
        self.addConstraint(NSLayoutConstraint(item: characterView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: widthFactor, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: characterView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: heightFactor, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: characterView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: leftFactor, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: characterView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: topFactor, constant: 0))
        
        // Set the text, color and alpha
        characterView.text = String(char)
        characterView.textColor = TEXT_COLOR
        characterView.alpha = 0 //we start with an alpha of 0, it will be faded in on update.
        
        // Return the view
        return characterView
    }
    
    /**
    Update the view with the current time.
    */
    
    func update() {
        
        // Generate the current timestamp and transform it to a human string
        let now = NSDate()
        let humanString = now.humanStringWithHourIdentifier(HOUR_IDENTIFIER)
        
        //check if we need to update
        if humanString != lastDisplayedTimeString {
        
            // Show the human string in the TextClockView
            showString(humanString)
            
            //Set the lastDisplayedTimeString
            lastDisplayedTimeString = humanString
            
        }

    }
    
    /**
    Show the string.
    
    @param string:String    The string we want to show in the view
    */
    func showString(string:String) {
        
        // Animate the brightness of the view
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            // Dimm all the views
            for characterView in self.characterViews {
                characterView.alpha = self.OFF_ALPHA
            }
            
            // Highlight the views for all the words in the string
            for word in string.componentsSeparatedByString(" ") {
                self.highlightWord(word)
            }
        
        }, completion: nil)
        
    }
    
    /**
    Highlight the word.
    
    @param word:String    The word we want to higlight
    */
    func highlightWord(word:String) {
        
        // Create a helper var by removing the HOUR_IDENTIFIER
        // We use this helper var to define the length of the word.
        let strippedWord = word.stringByReplacingOccurrencesOfString(HOUR_IDENTIFIER, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        // Request the index of the first character of the word
        if let wordIndex = words[word] {
            
            // Loop thru all the characters of the word
            for index in 0..<countElements(strippedWord) {
                
                // Get the characterView and change the alpha
                let characterView = characterViews[wordIndex + index]
                characterView.alpha = ON_ALPHA
            }
        }
    }
    
}

extension NSDate {
    
    
    /**
    Translate this NSDate object to a human readable code we want to use in the view
    
    @param hourIdentifier:String    The hour identifier string we want to put in front of the hour string.
    
    @return The human readable string we need for the TextClockVIew
    */
    func humanStringWithHourIdentifier(hourIdentifier:String) -> String {
        
        // Start with a basic string.
        var humanString = "IT IS"
        
        // Create the translation dictionaries for the hours and minutes.
        let hourStrings = [0: "TWELVE", 1: "ONE", 2: "TWO", 3: "THREE", 4: "FOUR", 5: "FIVE", 6: "SIX", 7: "SEVEN", 8: "EIGHT", 9: "NINE", 10: "TEN", 11: "ELEVEN", 12: "TWELVE"]
        let minuteStrings = [
            5: "FIVE PAST",
            10: "TEN PAST",
            15: "A QUARTER PAST",
            20: "TWENTY PAST",
            25: "TWENTY FIVE PAST",
            30: "HALF PAST",
            35: "TWENTY FIVE TO",
            40: "TWENTY TO",
            45: "A QUARTER TO",
            50: "TEN TO",
            55: "FIVE TO"
        ]
        
        // Create a calender object we need to extract the hour and minutes of the current NSDate object
        let calendar = NSCalendar.currentCalendar()
        
        // Extract the components we need
        let components = calendar.components((.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond), fromDate: self)
        
        // Convert the hour and minutes to rounded numbers
        // For the minutes, these wil be rounded to a 5 minute interval.
        let hour = components.hour % 12
        let roundedMinutes = Int(round(Float(components.minute) / 5.0) * 5)
        
        // If we have a string for the minutes, add it to the humanString.
        if let minuteString = minuteStrings[roundedMinutes] {
            humanString += " " + minuteString
        }
        
        // If we have a string for the hours, add it to the humanString.
        if let hourString = hourStrings[(roundedMinutes > 30) ? hour + 1 : hour] {
            humanString += " " + hourIdentifier + hourString
        }
        
        // If we are at the exact full hour, add a o' clock string.
        if roundedMinutes == 0 || roundedMinutes == 60 {
            humanString += " OCLOCK"
        }
        
        // Return the final string.
        return humanString
    }
}
