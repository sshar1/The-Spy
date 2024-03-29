local wordDict = {}

local words = {
	
	['Fairy Tales'] = {
		"Cinderella",
		"Goldilocks",
		"Jack and the Beanstalk",
		"Hare and the Tortoise",
		"Snow White",
		"Rapunzel",
		"Aladdin",
		"Princess and the Pea",
		"Peter Pan",
		"Little Red Riding Hood",
		"Pinocchio",
		"Beauty and the Beast",
		"Sleeping Beauty",
		"Hansel and Gretel",
		"Gingerbread Man",
		"Three Little Pigs"
	},
	
	['Countries'] = {
		"UK",
		"Spain",
		"Japan",
		"Brazil",
		"France",
		"USA",
		"Italy",
		"Australia",
		"Germany",
		"Mexico",
		"India",
		"Israel",
		"Canada",
		"China",
		"Russia",
		"Egypt"
	},
	
	['Transport'] = {
		"Plane",
		"Car",
		"Tank",
		"Helicopter",
		"Cruise Ship",
		"Hovercraft",
		"Motorbike",
		"Bus",
		"Segway",
		"Cable Car",
		"Jet Ski",
		"Hot Air Balloon",
		"Train",
		"Spaceship",
		"Magic Carpet",
		"Broomstick"
	},
	
	['Under The Sea'] = {
		"Octopus",
		"Starfish",
		"Shark",
		"Jellyfish",
		"Lobster",
		"Seal",
		"Dolphin",
		"Killer Whale",
		"Crab",
		"Giant Squid",
		"Seahorse",
		"Stingray",
		"Sea Turtle",
		"Clownfish",
		"Swordfish",
		"Mermaid"
	},
	
	['Jobs'] = {
		"Fisherman",
		"Lumberjack",
		"Nurse",
		"Waiter",
		"Lighthouse Keeper",
		"Secretary",
		"Accountant",
		"Teacher",
		"Taxi Driver",
		"Security Guard",
		"Chef",
		"Architect",
		"Police Officer",
		"Lawyer",
		"Carpenter",
		"Butcher"
	},
	
	['Sports'] = {
		"Football",
		"Soccer",
		"Golf",
		"Baseball",
		"Basketball",
		"Ice Hockey",
		"Sailing",
		"Squash",
		"Tennis",
		"Badminton",
		"Motor Racing",
		"Wrestling",
		"Lacrosse",
		"Volleyball",
		"Triathlon",
		"Cycling"
	},
	
	['Musical Instruments'] = {
		"Electric Guitar",
		"Piano",
		"Violin",
		"Drums",
		"Bass Guitar",
		"Saxophone",
		"Cello",
		"Flute",
		"Clarient",
		"Trumpet",
		"Voice",
		"Ukulele",
		"Harp",
		"Bagpipes",
		"Harmonica",
		"Banjo"
	},
	
	['Film Genres'] = {
		"Horror",
		"Action",
		"Thriller",
		"Sci-Fi",
		"Rom-Com",
		"Western",
		"Comedy",
		"Christmas",
		"Gangster",
		"Foreign Language",
		"War",
		"Documentary",
		"Musical",
		"Animation",
		"Zombie",
		"Sport"
	},
	
	['Games'] = {
		"Monopoly",
		"Scrabble",
		"Mouse Trap",
		"Guess Who",
		"Risk",
		"Operation",
		"Twister",
		"Pictionary",
		"Battleship",
		"Backgammon",
		"Clue",
		"Chess",
		"Tag",
		"Hide & Seek",
		"Jenga",
		"Hungry Hungry Hippos"
	},
	
	['Food'] = {
		"Pizza",
		"Potatoes",
		"Fish",
		"Cake",
		"Pasta",
		"Salad",
		"Soup",
		"Bread",
		"Eggs",
		"Cheese",
		"Fruit",
		"Sausage",
		"Chicken",
		"Ice Cream",
		"Chocolate",
		"Beef"
	},
	
	['Inventions'] = {
		"Matches",
		"Gunpowder",
		"Wheel",
		"Printing",
		"Computer",
		"Internet",
		"Compass",
		"Plane",
		"TV",
		"Electricity",
		"Writing",
		"Steam Engine",
		"Car",
		"Telephone",
		"Camera",
		"Radio"
	},
	
	['States'] = {
		"California",
		"Texas",
		"Alabama",
		"Hawaii",
		"Florida",
		"Montana",
		"Nevada",
		"Mississippi",
		"North Carolina",
		"New York",
		"Kentucky",
		"Tennessee",
		"Colorado",
		"Washington",
		"Illinois",
		"Alaska"
	},
	
	['Fictional Characters'] = {
		"Indiana Jones",
		"Popeye",
		"Spiderman",
		"Darth Vader",
		"Sherlock Holmes",
		"Gandalf",
		"Superman",
		"Batman",
		"James Bond",
		"Dracula",
		"Homer Simpson",
		"Frankenstein",
		"Robin Hood",
		"Super Mario",
		"Tarzan",
		"Hercules"
	},
	
	['School'] = {
		"Math",
		"Chemistry",
		"Physics",
		"Biology",
		"History",
		"Philosophy",
		"Geography",
		"English",
		"Economics",
		"Spanish",
		"Art",
		"Music",
		"Gym",
		"Latin",
		"Religion",
		"Technology"
	},
	
	['Movies'] = {
		"Jurassic Park",
		"Jaws",
		"Star Wars",
		"Transformers",
		"Toy Story",
		"Home Alone",
		"Titanic",
		"WALL E",
		"The Wizard of Oz",
		"King Kong",
		"The Matrix",
		"Shrek",
		"Godzilla",
		"Finding Nemo",
		"Avatar",
		"Onward"
	},
	
	['Mythical Creatures'] = {
		"Cyclops",
		"Pegasus",
		"Medusa",
		"Sphinx",
		"Werewolf",
		"Unicorn",
		"Dragon",
		"Troll",
		"Loch Ness Monster",
		"Mermaid",
		"Phoenix",
		"Vampire",
		"Minotaur",
		"Hydra",
		"Yeti",
		"Centaur"
	},
	
	['Animals'] = {
		"Elephant",
		"Giraffe",
		"Tiger",
		"Lion",
		"Leopard",
		"Parrot",
		"Dog",
		"Zebra",
		"Flamingo",
		"Alligator",
		"Scorpion",
		"Eagle",
		"Mouse",
		"Peacock",
		"Kangaroo",
		"Bull"
	},
	
	['The Arts'] = {
		"Painting",
		"Sculpture",
		"Architecture",
		"Dance",
		"Literature",
		"Opera",
		"Stand-Up",
		"Comic Books",
		"Illustration",
		"Music",
		"Theatre",
		"Cinema",
		"Video Games",
		"Graffiti",
		"Fashion",
		"Photography"
	}
}

local topics = {
	"Fairy Tales", 
	"Countries", 
	"Transport", 
	"Under The Sea", 
	"Jobs", 
	"Sports", 
	"Musical Instruments", 
	"Film Genres",
	"Games",
	"Food",
	"Inventions",
	"States",
	"Fictional Characters",
	"School",
	"Movies",
	"Mythical Creatures",
	"Animals",
	"The Arts"
}

function wordDict.getRandWord()
	local randTopic = topics[math.random(1, #topics)]
	local wordArr = words[randTopic]
	local randWord = wordArr[math.random(1, #wordArr)]
	
	return randTopic, randWord, wordArr
end

return wordDict
