	                  
import Foundation
import SwiftUI

/* This code requires OclFile.swift */

func initialiseOclFile()
{ 
  //let systemIn = createByPKOclFile(key: "System.in")
  //let systemOut = createByPKOclFile(key: "System.out")
  //let systemErr = createByPKOclFile(key: "System.err")
}

/* This metatype code requires OclType.swift */

func initialiseOclType()
{ let intOclType = createByPKOclType(key: "int")
  intOclType.actualMetatype = Int.self
  let doubleOclType = createByPKOclType(key: "double")
  doubleOclType.actualMetatype = Double.self
  let longOclType = createByPKOclType(key: "long")
  longOclType.actualMetatype = Int64.self
  let stringOclType = createByPKOclType(key: "String")
  stringOclType.actualMetatype = String.self
  let sequenceOclType = createByPKOclType(key: "Sequence")
  sequenceOclType.actualMetatype = type(of: [])
  let anyset : Set<AnyHashable> = Set<AnyHashable>()
  let setOclType = createByPKOclType(key: "Set")
  setOclType.actualMetatype = type(of: anyset)
  let mapOclType = createByPKOclType(key: "Map")
  mapOclType.actualMetatype = type(of: [:])
  let voidOclType = createByPKOclType(key: "void")
  voidOclType.actualMetatype = Void.self
	
  let mealOclType = createByPKOclType(key: "Meal")
  mealOclType.actualMetatype = Meal.self

  let mealMealId = createOclAttribute()
  	  mealMealId.name = "mealId"
  	  mealMealId.type = stringOclType
  	  mealOclType.attributes.append(mealMealId)
  let mealMealName = createOclAttribute()
  	  mealMealName.name = "mealName"
  	  mealMealName.type = stringOclType
  	  mealOclType.attributes.append(mealMealName)
  let mealCalories = createOclAttribute()
  	  mealCalories.name = "calories"
  	  mealCalories.type = doubleOclType
  	  mealOclType.attributes.append(mealCalories)
  let mealDates = createOclAttribute()
  	  mealDates.name = "dates"
  	  mealDates.type = stringOclType
  	  mealOclType.attributes.append(mealDates)
  let mealImages = createOclAttribute()
  	  mealImages.name = "images"
  	  mealImages.type = stringOclType
  	  mealOclType.attributes.append(mealImages)
  let mealAnalysis = createOclAttribute()
  	  mealAnalysis.name = "analysis"
  	  mealAnalysis.type = stringOclType
  	  mealOclType.attributes.append(mealAnalysis)
  let mealUserName = createOclAttribute()
  	  mealUserName.name = "userName"
  	  mealUserName.type = stringOclType
  	  mealOclType.attributes.append(mealUserName)
  let userOclType = createByPKOclType(key: "User")
  userOclType.actualMetatype = User.self

  let userUserName = createOclAttribute()
  	  userUserName.name = "userName"
  	  userUserName.type = stringOclType
  	  userOclType.attributes.append(userUserName)
  let userGender = createOclAttribute()
  	  userGender.name = "gender"
  	  userGender.type = stringOclType
  	  userOclType.attributes.append(userGender)
  let userHeights = createOclAttribute()
  	  userHeights.name = "heights"
  	  userHeights.type = doubleOclType
  	  userOclType.attributes.append(userHeights)
  let userWeights = createOclAttribute()
  	  userWeights.name = "weights"
  	  userWeights.type = doubleOclType
  	  userOclType.attributes.append(userWeights)
  let userActivityLevel = createOclAttribute()
  	  userActivityLevel.name = "activityLevel"
  	  userActivityLevel.type = stringOclType
  	  userOclType.attributes.append(userActivityLevel)
  let userAge = createOclAttribute()
  	  userAge.name = "age"
  	  userAge.type = doubleOclType
  	  userOclType.attributes.append(userAge)
  let userTargetCalories = createOclAttribute()
  	  userTargetCalories.name = "targetCalories"
  	  userTargetCalories.type = doubleOclType
  	  userOclType.attributes.append(userTargetCalories)
  let userTotalConsumedCalories = createOclAttribute()
  	  userTotalConsumedCalories.name = "totalConsumedCalories"
  	  userTotalConsumedCalories.type = doubleOclType
  	  userOclType.attributes.append(userTotalConsumedCalories)
  let userBmr = createOclAttribute()
  	  userBmr.name = "bmr"
  	  userBmr.type = doubleOclType
  	  userOclType.attributes.append(userBmr)
}

func instanceFromJSON(typeName: String, json: String) -> AnyObject?
	{ let jdata = json.data(using: .utf8)!
	  let decoder = JSONDecoder()
	  if typeName == "String"
	  { let x = try? decoder.decode(String.self, from: jdata)
	      return x as AnyObject
	  }
  return nil
	}

class ModelFacade : ObservableObject {
		                      
	static var instance : ModelFacade? = nil
	private var modelParser : ModelParser? = ModelParser(modelFileInfo: ModelFile.modelInfo)
	var db : DB?
		
	// path of document directory for SQLite database (absolute path of db)
	let dbpath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
	var fileSystem : FileAccessor = FileAccessor()

	static func getInstance() -> ModelFacade { 
		if instance == nil
	     { instance = ModelFacade() 
	       initialiseOclFile()
	       initialiseOclType() }
	    return instance! }
	                          
	init() { 
		db = DB.obtainDatabase(path: "\(dbpath)/myDatabase.sqlite3")
		loadMeal()
		currentUser = getUser()
		loadUser()
	}
	      
	@Published var currentMeal : MealVO? = MealVO.defaultMealVO()
	@Published var currentMeals : [MealVO] = [MealVO]()
	@Published private var preference = ModelPreferencesManager()
	@Published var currentUser : UserVO? = UserVO.defaultUserVO()
	@Published var currentUsers : [UserVO] = [UserVO]()

	func createMeal(x : MealVO) {
		  let res : Meal = createByPKMeal(key: x.mealId)
				res.mealId = x.mealId
		res.mealName = x.mealName
		res.calories = x.calories
		res.dates = x.dates
		res.images = x.images
		res.analysis = x.analysis
		res.userName = x.userName
		  currentMeal = x
		  do { try db?.createMeal(mealvo: x) }
		  catch { print("Error creating Meal") }
	}
		
	func cancelCreateMeal() {
		//cancel function
	}
	
	func deleteMeal(id : String) {
		  if db != nil
	      { db!.deleteMeal(val: id) }
	     	currentMeal = nil
	}
		
	func cancelDeleteMeal() {
		//cancel function
	}
			
	func cancelEditMeal() {
		//cancel function
	}

	func cancelSearchMealByDate() {
	//cancel function
}

    func createUser(x : UserVO) {
        let res : User = createByPKUser(key: x.userName)
        res.userName = x.userName
        res.gender = x.gender
        res.heights = x.heights
        res.weights = x.weights
        res.activityLevel = x.activityLevel
        res.age = x.age
        res.targetCalories = x.targetCalories
        res.totalConsumedCalories = x.totalConsumedCalories
        res.bmr = x.bmr

        currentUser = x
	    currentUsers = [UserVO] ()
	    currentUsers.append(x)
	    
        preference.user = x
    }
    
    func getUser () -> UserVO? {
    	currentUser = preference.user
    	if (currentUser != nil) {
	    currentUsers = [UserVO] ()
	    currentUsers.append(currentUser!)
	    }
        return currentUser
    }
    
	func cancelCreateUser() {
		//cancel function
	}
	
		func findTotalConsumedCaloriesByDate (x: FindTotalConsumedCaloriesByDateVO, dates: String) -> Double {
	      var result = 0.0

var totalConsumedCalories: Double
  totalConsumedCalories  = 0.0
for (_,meal) in x.getMeals() {
	if meal.userName == x.getUser().userName && meal.dates == dates {
		    totalConsumedCalories  = totalConsumedCalories + meal.calories
	}
}
  x.getUser().totalConsumedCalories  = totalConsumedCalories
persistUser (x: x.getUser())
  result  = totalConsumedCalories
	if x.isFindTotalConsumedCaloriesByDateError()
	   {   return result }
        x.setResult(x: result )
	   
	return result
        
    }
       
	func cancelFindTotalConsumedCaloriesByDate() {
		//cancel function
	}
	          
		func findTargetCalories (x: FindTargetCaloriesVO) -> Double {
	      var result = 0.0

  x.getUser().targetCalories  = x.getUser().calculateTargetCalories()
persistUser (x: x.getUser())
  result  = x.getUser().targetCalories
	if x.isFindTargetCaloriesError()
	   {   return result }
        x.setResult(x: result )
	   
	return result
        
    }
       
	func cancelFindTargetCalories() {
		//cancel function
	}
	          
		func findBMR (x: FindBMRVO) -> Double {
	      var result = 0.0

  x.getUser().bmr  = x.getUser().calculateBMR()
persistUser (x: x.getUser())
  result  = x.getUser().bmr
	if x.isFindBMRError()
	   {   return result }
        x.setResult(x: result )
	   
	return result
        
    }
       
	func cancelFindBMR() {
		//cancel function
	}
	          
		func caloriesProgress (x: CaloriesProgressVO) -> Double {
	      var result = 0.0

var progress: Double
  progress  = (x.getUser().totalConsumedCalories / x.getUser().targetCalories) * 100
persistUser (x: x.getUser())
  result  = progress
	if x.isCaloriesProgressError()
	   {   return result }
        x.setResult(x: result )
	   
	return result
        
    }
       
	func cancelCaloriesProgress() {
		//cancel function
	}
	          
  func addUsereatsMeal(x: String, y: String) {
		  if db != nil
	      { db!.addUsereatsMeal(userName : x, mealId : y) }
	    	let userobj : User? = User.getByPKUser(index : x)
	    	let mealobj : Meal? = Meal.getByPKMeal(index : y)
	      if userobj != nil
	      { currentUser = UserVO(x : userobj!) 
	      	currentMeal = MealVO(x : mealobj!) 
	      }
	}
	  
	func cancelAddUsereatsMeal() {
		//cancel function
	}

  func removeUsereatsMeal(x: String, y: String) {
		  if db != nil
	      { db!.removeUsereatsMeal(mealId : y) }
	    	let userobj : User? = User.getByPKUser(index : x)
	    	let mealobj : Meal? = Meal.getByPKMeal(index : y)
	      if userobj != nil
	      { currentUser = UserVO(x : userobj!) 
	      	currentMeal = MealVO(x : mealobj!) 
	      }
	}
	  
	func cancelRemoveUsereatsMeal() {
		//cancel function
	}

    func imageRecognition(x : String) -> String {
        guard let obj = getMealByPK(val: x)
        else {
            return "Please selsect valid mealId"
        }
        
		let dataDecoded = Data(base64Encoded: obj.images, options: .ignoreUnknownCharacters)
		let decodedimage:UIImage = UIImage(data: dataDecoded! as Data)!
        		
    	guard let pixelBuffer = decodedimage.pixelBuffer() else {
        	return "Error"
    	}
    
        // Hands over the pixel buffer to ModelDatahandler to perform inference
        let inferencesResults = modelParser?.runModel(onFrame: pixelBuffer)
        
        // Formats inferences and resturns the results
        guard let firstInference = inferencesResults else {
          return "Error"
        }
        
        obj.analysis = firstInference[0].label
        persistMeal(x: obj)
        
        return firstInference[0].label
        
    }
    
	func cancelImageRecognition() {
		//cancel function
	}
	    

	func loadMeal() {
		let res : [MealVO] = listMeal()
		
		for (_,x) in res.enumerated() {
			let obj = createByPKMeal(key: x.mealId)
	        obj.mealId = x.getMealId()
        obj.mealName = x.getMealName()
        obj.calories = x.getCalories()
        obj.dates = x.getDates()
        obj.images = x.getImages()
        obj.analysis = x.getAnalysis()
        obj.userName = x.getUserName()
			}
		 currentMeal = res.first
		 currentMeals = res
		}
		
  		func listMeal() -> [MealVO] {
			if db != nil
			{ currentMeals = (db?.listMeal())!
			  return currentMeals
			}
			currentMeals = [MealVO]()
			let list : [Meal] = MealAllInstances
			for (_,x) in list.enumerated()
			{ currentMeals.append(MealVO(x: x)) }
			return currentMeals
		}
				
		func stringListMeal() -> [String] { 
			currentMeals = listMeal()
			var res : [String] = [String]()
			for (_,obj) in currentMeals.enumerated()
			{ res.append(obj.toString()) }
			return res
		}
				
		func getMealByPK(val: String) -> Meal? {
			var res : Meal? = Meal.getByPKMeal(index: val)
			if res == nil && db != nil
			{ let list = db!.searchByMealmealId(val: val)
			if list.count > 0
			{ res = createByPKMeal(key: val)
			}
		  }
		  return res
		}
				
		func retrieveMeal(val: String) -> Meal? {
			let res : Meal? = getMealByPK(val: val)
			return res 
		}
				
		func allMealids() -> [String] {
			var res : [String] = [String]()
			for (_,item) in currentMeals.enumerated()
			{ res.append(item.mealId + "") }
			return res
		}
				
		func setSelectedMeal(x : MealVO)
			{ currentMeal = x }
				
		func setSelectedMeal(i : Int) {
			if 0 <= i && i < currentMeals.count
			{ currentMeal = currentMeals[i] }
		}
				
		func getSelectedMeal() -> MealVO?
			{ return currentMeal }
				
		func persistMeal(x : Meal) {
			let vo : MealVO = MealVO(x: x)
			editMeal(x: vo)
		}
			
		func editMeal(x : MealVO) {
			let val : String = x.mealId
			let res : Meal? = Meal.getByPKMeal(index: val)
			if res != nil {
			res!.mealId = x.mealId
		res!.mealName = x.mealName
		res!.calories = x.calories
		res!.dates = x.dates
		res!.images = x.images
		res!.analysis = x.analysis
		res!.userName = x.userName
		}
		currentMeal = x
			if db != nil
			 { db!.editMeal(mealvo: x) }
		 }
			
	    func cancelMealEdit() {
	    	//cancel function
	    }
	    
 	func searchByMealmealId(val : String) -> [MealVO]
		  { 
		      if db != nil
		        { let res = (db?.searchByMealmealId(val: val))!
		          return res
		        }
		    currentMeals = [MealVO]()
		    let list : [Meal] = MealAllInstances
		    for (_,x) in list.enumerated()
		    { if x.mealId == val
		      { currentMeals.append(MealVO(x: x)) }
		    }
		    return currentMeals
		  }
		  
 	func searchByMealmealName(val : String) -> [MealVO]
		  { 
		      if db != nil
		        { let res = (db?.searchByMealmealName(val: val))!
		          return res
		        }
		    currentMeals = [MealVO]()
		    let list : [Meal] = MealAllInstances
		    for (_,x) in list.enumerated()
		    { if x.mealName == val
		      { currentMeals.append(MealVO(x: x)) }
		    }
		    return currentMeals
		  }
		  
 	func searchByMealcalories(val : Double) -> [MealVO]
		  { 
		      if db != nil
		        { let res = (db?.searchByMealcalories(val: val))!
		          return res
		        }
		    currentMeals = [MealVO]()
		    let list : [Meal] = MealAllInstances
		    for (_,x) in list.enumerated()
		    { if x.calories == val
		      { currentMeals.append(MealVO(x: x)) }
		    }
		    return currentMeals
		  }
		  
 	func searchByMealdates(val : String) -> [MealVO]
		  { 
		      if db != nil
		        { let res = (db?.searchByMealdates(val: val))!
		          return res
		        }
		    currentMeals = [MealVO]()
		    let list : [Meal] = MealAllInstances
		    for (_,x) in list.enumerated()
		    { if x.dates == val
		      { currentMeals.append(MealVO(x: x)) }
		    }
		    return currentMeals
		  }
		  
 	func searchByMealimages(val : String) -> [MealVO]
		  { 
		      if db != nil
		        { let res = (db?.searchByMealimages(val: val))!
		          return res
		        }
		    currentMeals = [MealVO]()
		    let list : [Meal] = MealAllInstances
		    for (_,x) in list.enumerated()
		    { if x.images == val
		      { currentMeals.append(MealVO(x: x)) }
		    }
		    return currentMeals
		  }
		  
 	func searchByMealanalysis(val : String) -> [MealVO]
		  { 
		      if db != nil
		        { let res = (db?.searchByMealanalysis(val: val))!
		          return res
		        }
		    currentMeals = [MealVO]()
		    let list : [Meal] = MealAllInstances
		    for (_,x) in list.enumerated()
		    { if x.analysis == val
		      { currentMeals.append(MealVO(x: x)) }
		    }
		    return currentMeals
		  }
		  
 	func searchByMealuserName(val : String) -> [MealVO]
		  { 
		      if db != nil
		        { let res = (db?.searchByMealuserName(val: val))!
		          return res
		        }
		    currentMeals = [MealVO]()
		    let list : [Meal] = MealAllInstances
		    for (_,x) in list.enumerated()
		    { if x.userName == val
		      { currentMeals.append(MealVO(x: x)) }
		    }
		    return currentMeals
		  }
		  
	func loadUser() {
			let res : [UserVO] = listUser()
			
			for (_,x) in res.enumerated() {
				let obj = createByPKUser(key: x.userName)
		        obj.userName = x.getUserName()
        obj.gender = x.getGender()
        obj.heights = x.getHeights()
        obj.weights = x.getWeights()
        obj.activityLevel = x.getActivityLevel()
        obj.age = x.getAge()
        obj.targetCalories = x.getTargetCalories()
        obj.totalConsumedCalories = x.getTotalConsumedCalories()
        obj.bmr = x.getBmr()
				}
			 currentUser = res.first
			 currentUsers = res
		}
		
		func listUser() -> [UserVO] {
			currentUser = getUser()
	            if currentUser != nil {
	                currentUsers = [UserVO]()
	                currentUsers.append(currentUser!)
	            }
            return currentUsers
		}
						
	func stringListUser() -> [String] { 
		currentUsers = listUser()
		var res : [String] = [String]()
		for (_,obj) in currentUsers.enumerated()
		{ res.append(obj.toString()) }
		return res
	}
			
	func getUserByPK(val: String) -> User? {
		var res : User? = User.getByPKUser(index: val)
		if res == nil {
		   res = createByPKUser(key: preference.user.userName)
		}
		return res 
	}
			
	func retrieveUser(val: String) -> User? {
		let res : User? = getUserByPK(val: val)
		return res 
	}
			
	func allUserids() -> [String] {
		var res : [String] = [String]()
		for (_,item) in currentUsers.enumerated()
		{ res.append(item.userName + "") }
		return res
	}
			
	func setSelectedUser(x : UserVO)
		{ currentUser = x }
			
	func setSelectedUser(i : Int) {
		if 0 <= i && i < currentUsers.count
		{ currentUser = currentUsers[i] }
	}
			
	func getSelectedUser() -> UserVO?
		{ return currentUser }
			
	func persistUser(x : User) {
		let vo : UserVO = UserVO(x: x)
		editUser(x: vo)
	}
		
	func editUser(x : UserVO) {
		let val : String = x.userName
		let res : User? = User.getByPKUser(index: val)
		if res != nil {
		res!.userName = x.userName
		res!.gender = x.gender
		res!.heights = x.heights
		res!.weights = x.weights
		res!.activityLevel = x.activityLevel
		res!.age = x.age
		res!.targetCalories = x.targetCalories
		res!.totalConsumedCalories = x.totalConsumedCalories
		res!.bmr = x.bmr
		}
		currentUser = x
		preference.user = x
	 }
		
    func cancelUserEdit() {
    	//cancel function
    }
    
 	func searchByUseruserName(val : String) -> [UserVO] {
		currentUser = getUser()
        if currentUser != nil && currentUser?.userName == val {
           currentUsers = [UserVO]()
           currentUsers.append(currentUser!)
        }
        return currentUsers
		}
		
 	func searchByUsergender(val : String) -> [UserVO] {
		currentUser = getUser()
        if currentUser != nil && currentUser?.gender == val {
           currentUsers = [UserVO]()
           currentUsers.append(currentUser!)
        }
        return currentUsers
		}
		
 	func searchByUserheights(val : Double) -> [UserVO] {
		currentUser = getUser()
        if currentUser != nil && currentUser?.heights == val {
           currentUsers = [UserVO]()
           currentUsers.append(currentUser!)
        }
        return currentUsers
		}
		
 	func searchByUserweights(val : Double) -> [UserVO] {
		currentUser = getUser()
        if currentUser != nil && currentUser?.weights == val {
           currentUsers = [UserVO]()
           currentUsers.append(currentUser!)
        }
        return currentUsers
		}
		
 	func searchByUseractivityLevel(val : String) -> [UserVO] {
		currentUser = getUser()
        if currentUser != nil && currentUser?.activityLevel == val {
           currentUsers = [UserVO]()
           currentUsers.append(currentUser!)
        }
        return currentUsers
		}
		
 	func searchByUserage(val : Double) -> [UserVO] {
		currentUser = getUser()
        if currentUser != nil && currentUser?.age == val {
           currentUsers = [UserVO]()
           currentUsers.append(currentUser!)
        }
        return currentUsers
		}
		
 	func searchByUsertargetCalories(val : Double) -> [UserVO] {
		currentUser = getUser()
        if currentUser != nil && currentUser?.targetCalories == val {
           currentUsers = [UserVO]()
           currentUsers.append(currentUser!)
        }
        return currentUsers
		}
		
 	func searchByUsertotalConsumedCalories(val : Double) -> [UserVO] {
		currentUser = getUser()
        if currentUser != nil && currentUser?.totalConsumedCalories == val {
           currentUsers = [UserVO]()
           currentUsers.append(currentUser!)
        }
        return currentUsers
		}
		
 	func searchByUserbmr(val : Double) -> [UserVO] {
		currentUser = getUser()
        if currentUser != nil && currentUser?.bmr == val {
           currentUsers = [UserVO]()
           currentUsers.append(currentUser!)
        }
        return currentUsers
		}
		

	}
