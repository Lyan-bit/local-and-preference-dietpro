import Foundation
import SQLite3

/* Code adapted from https://www.raywenderlich.com/6620276-sqlite-with-swift-tutorial-getting-started */

class DB {
  let dbPointer : OpaquePointer?
  static let dbNAME = "dietproApp.db"
  static let dbVERSION = 1

  static let mealTABLENAME = "Meal"
  static let mealID = 0
  static let mealCOLS : [String] = ["TableId", "mealId", "mealName", "calories", "dates", "images", "analysis", "userName"]
  static let mealNUMBERCOLS = 0

  static let mealCREATESCHEMA =
    "create table Meal (TableId integer primary key autoincrement" + 
        ", mealId VARCHAR(50) not null"  +
        ", mealName VARCHAR(50) not null"  +
        ", calories double not null"  +
        ", dates VARCHAR(50) not null"  +
        ", images VARCHAR(50) not null"  +
        ", analysis VARCHAR(50) not null"  +
        ", userName VARCHAR(50) not null"  +
	"" + ")"
	
  private init(dbPointer: OpaquePointer?)
  { self.dbPointer = dbPointer }

  func createDatabase() throws
  { do 
    { 
    try createTable(table: DB.mealCREATESCHEMA)
      print("Created database")
    }
    catch { print("Errors: " + errorMessage) }
  }

  static func obtainDatabase(path: String) -> DB?
  {
    var db : DB? = nil
    if FileAccessor.fileExistsAbsolutePath(filename: path)
    { print("Database already exists")
      do
      { try db = DB.open(path: path)
        if db != nil
        { print("Opened database") }
        else
        { print("Failed to open existing database") }
      }
      catch { print("Error opening existing database") 
              return nil 
            }
    }
    else
    { print("New database will be created")
      do
      { try db = DB.open(path: path)
        if db != nil
        { print("Opened new database") 
          try db!.createDatabase() 
        }
        else
        { print("Failed to open new database") }
      }
      catch { print("Error opening new database")  
              return nil }
    }
    return db
  }

  fileprivate var errorMessage: String
  { if let errorPointer = sqlite3_errmsg(dbPointer)
    { let eMessage = String(cString: errorPointer)
      return eMessage
    } 
    else 
    { return "Unknown error from sqlite." }
  }
  
  func prepareStatement(sql: String) throws -> OpaquePointer?   
  { var statement: OpaquePointer?
    guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) 
        == SQLITE_OK
    else 
    { return nil }
    return statement
  }
  
  static func open(path: String) throws -> DB? 
  { var db: OpaquePointer?
  
    if sqlite3_open(path, &db) == SQLITE_OK 
    { return DB(dbPointer: db) }
    else 
    { defer 
      { if db != nil 
        { sqlite3_close(db) }
      }
  
      if let errorPointer = sqlite3_errmsg(db)
      { let message = String(cString: errorPointer)
        print("Error opening database: " + message)
      } 
      else 
      { print("Unknown error opening database") }
      return nil
    }
  }
  
  func createTable(table: String) throws
  { let createTableStatement = try prepareStatement(sql: table)
    defer 
    { sqlite3_finalize(createTableStatement) }
    
    guard sqlite3_step(createTableStatement) == SQLITE_DONE 
    else
    { print("Error creating table") 
      return
    }
    print("table " + table + " created.")
  }

  func listMeal() -> [MealVO]
  { var res : [MealVO] = [MealVO]()
    let statement = "SELECT * FROM Meal "
    let queryStatement = try? prepareStatement(sql: statement)
    if queryStatement == nil { 
    	return res
    }
    
    while (sqlite3_step(queryStatement) == SQLITE_ROW)
    { //let id = sqlite3_column_int(queryStatement, 0)
      let mealvo = MealVO()
      
    guard let queryResultMealCOLMEALID = sqlite3_column_text(queryStatement, 1) 
    else { return res } 
    let mealId = String(cString: queryResultMealCOLMEALID) 
    mealvo.setMealId(x: mealId) 

    guard let queryResultMealCOLMEALNAME = sqlite3_column_text(queryStatement, 2) 
    else { return res } 
    let mealName = String(cString: queryResultMealCOLMEALNAME) 
    mealvo.setMealName(x: mealName) 

    let queryResultMealCOLCALORIES = sqlite3_column_double(queryStatement, 3) 
    let calories = Double(queryResultMealCOLCALORIES) 
    mealvo.setCalories(x: calories) 

    guard let queryResultMealCOLDATES = sqlite3_column_text(queryStatement, 4) 
    else { return res } 
    let dates = String(cString: queryResultMealCOLDATES) 
    mealvo.setDates(x: dates) 

    guard let queryResultMealCOLIMAGES = sqlite3_column_text(queryStatement, 5) 
    else { return res } 
    let images = String(cString: queryResultMealCOLIMAGES) 
    mealvo.setImages(x: images) 

    guard let queryResultMealCOLANALYSIS = sqlite3_column_text(queryStatement, 6) 
    else { return res } 
    let analysis = String(cString: queryResultMealCOLANALYSIS) 
    mealvo.setAnalysis(x: analysis) 

    guard let queryResultMealCOLUSERNAME = sqlite3_column_text(queryStatement, 7) 
    else { return res } 
    let userName = String(cString: queryResultMealCOLUSERNAME) 
    mealvo.setUserName(x: userName) 

      res.append(mealvo)
    }
    sqlite3_finalize(queryStatement)
    return res
  }

  func createMeal(mealvo : MealVO) throws
  { let insertSQL : String = "INSERT INTO Meal (mealId, mealName, calories, dates, images, analysis, userName) VALUES (" 
     + "'" + mealvo.getMealId() + "'" + "," 
     + "'" + mealvo.getMealName() + "'" + "," 
     + String(mealvo.getCalories()) + "," 
     + "'" + mealvo.getDates() + "'" + "," 
     + "'" + mealvo.getImages() + "'" + "," 
     + "'" + mealvo.getAnalysis() + "'" + "," 
     + "'" + mealvo.getUserName() + "'"
      + ")"
    let insertStatement = try prepareStatement(sql: insertSQL)
    defer 
    { sqlite3_finalize(insertStatement)
    }
    sqlite3_step(insertStatement)
  }

  func searchByMealmealId(val : String) -> [MealVO]
	  { var res : [MealVO] = [MealVO]()
	    let statement : String = "SELECT * FROM Meal WHERE mealId = " + "'" + val + "'" 
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let mealvo = MealVO()
	      
	      guard let queryResultMealCOLMEALID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let mealId = String(cString: queryResultMealCOLMEALID)
		      mealvo.setMealId(x: mealId)
	      guard let queryResultMealCOLMEALNAME = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let mealName = String(cString: queryResultMealCOLMEALNAME)
		      mealvo.setMealName(x: mealName)
	      let queryResultMealCOLCALORIES = sqlite3_column_double(queryStatement, 3)
		      let calories = Double(queryResultMealCOLCALORIES)
		      mealvo.setCalories(x: calories)
	      guard let queryResultMealCOLDATES = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let dates = String(cString: queryResultMealCOLDATES)
		      mealvo.setDates(x: dates)
	      guard let queryResultMealCOLIMAGES = sqlite3_column_text(queryStatement, 5)
		      else { return res }	      
		      let images = String(cString: queryResultMealCOLIMAGES)
		      mealvo.setImages(x: images)
	      guard let queryResultMealCOLANALYSIS = sqlite3_column_text(queryStatement, 6)
		      else { return res }	      
		      let analysis = String(cString: queryResultMealCOLANALYSIS)
		      mealvo.setAnalysis(x: analysis)
	      guard let queryResultMealCOLUSERNAME = sqlite3_column_text(queryStatement, 7)
		      else { return res }	      
		      let userName = String(cString: queryResultMealCOLUSERNAME)
		      mealvo.setUserName(x: userName)

	      res.append(mealvo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  
  func searchByMealmealName(val : String) -> [MealVO]
	  { var res : [MealVO] = [MealVO]()
	    let statement : String = "SELECT * FROM Meal WHERE mealName = " + "'" + val + "'" 
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let mealvo = MealVO()
	      
	      guard let queryResultMealCOLMEALID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let mealId = String(cString: queryResultMealCOLMEALID)
		      mealvo.setMealId(x: mealId)
	      guard let queryResultMealCOLMEALNAME = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let mealName = String(cString: queryResultMealCOLMEALNAME)
		      mealvo.setMealName(x: mealName)
	      let queryResultMealCOLCALORIES = sqlite3_column_double(queryStatement, 3)
		      let calories = Double(queryResultMealCOLCALORIES)
		      mealvo.setCalories(x: calories)
	      guard let queryResultMealCOLDATES = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let dates = String(cString: queryResultMealCOLDATES)
		      mealvo.setDates(x: dates)
	      guard let queryResultMealCOLIMAGES = sqlite3_column_text(queryStatement, 5)
		      else { return res }	      
		      let images = String(cString: queryResultMealCOLIMAGES)
		      mealvo.setImages(x: images)
	      guard let queryResultMealCOLANALYSIS = sqlite3_column_text(queryStatement, 6)
		      else { return res }	      
		      let analysis = String(cString: queryResultMealCOLANALYSIS)
		      mealvo.setAnalysis(x: analysis)
	      guard let queryResultMealCOLUSERNAME = sqlite3_column_text(queryStatement, 7)
		      else { return res }	      
		      let userName = String(cString: queryResultMealCOLUSERNAME)
		      mealvo.setUserName(x: userName)

	      res.append(mealvo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  
  func searchByMealcalories(val : Double) -> [MealVO]
	  { var res : [MealVO] = [MealVO]()
	    let statement : String = "SELECT * FROM Meal WHERE calories = " + String( val )
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let mealvo = MealVO()
	      
	      guard let queryResultMealCOLMEALID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let mealId = String(cString: queryResultMealCOLMEALID)
		      mealvo.setMealId(x: mealId)
	      guard let queryResultMealCOLMEALNAME = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let mealName = String(cString: queryResultMealCOLMEALNAME)
		      mealvo.setMealName(x: mealName)
	      let queryResultMealCOLCALORIES = sqlite3_column_double(queryStatement, 3)
		      let calories = Double(queryResultMealCOLCALORIES)
		      mealvo.setCalories(x: calories)
	      guard let queryResultMealCOLDATES = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let dates = String(cString: queryResultMealCOLDATES)
		      mealvo.setDates(x: dates)
	      guard let queryResultMealCOLIMAGES = sqlite3_column_text(queryStatement, 5)
		      else { return res }	      
		      let images = String(cString: queryResultMealCOLIMAGES)
		      mealvo.setImages(x: images)
	      guard let queryResultMealCOLANALYSIS = sqlite3_column_text(queryStatement, 6)
		      else { return res }	      
		      let analysis = String(cString: queryResultMealCOLANALYSIS)
		      mealvo.setAnalysis(x: analysis)
	      guard let queryResultMealCOLUSERNAME = sqlite3_column_text(queryStatement, 7)
		      else { return res }	      
		      let userName = String(cString: queryResultMealCOLUSERNAME)
		      mealvo.setUserName(x: userName)

	      res.append(mealvo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  
  func searchByMealdates(val : String) -> [MealVO]
	  { var res : [MealVO] = [MealVO]()
	    let statement : String = "SELECT * FROM Meal WHERE dates = " + "'" + val + "'" 
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let mealvo = MealVO()
	      
	      guard let queryResultMealCOLMEALID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let mealId = String(cString: queryResultMealCOLMEALID)
		      mealvo.setMealId(x: mealId)
	      guard let queryResultMealCOLMEALNAME = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let mealName = String(cString: queryResultMealCOLMEALNAME)
		      mealvo.setMealName(x: mealName)
	      let queryResultMealCOLCALORIES = sqlite3_column_double(queryStatement, 3)
		      let calories = Double(queryResultMealCOLCALORIES)
		      mealvo.setCalories(x: calories)
	      guard let queryResultMealCOLDATES = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let dates = String(cString: queryResultMealCOLDATES)
		      mealvo.setDates(x: dates)
	      guard let queryResultMealCOLIMAGES = sqlite3_column_text(queryStatement, 5)
		      else { return res }	      
		      let images = String(cString: queryResultMealCOLIMAGES)
		      mealvo.setImages(x: images)
	      guard let queryResultMealCOLANALYSIS = sqlite3_column_text(queryStatement, 6)
		      else { return res }	      
		      let analysis = String(cString: queryResultMealCOLANALYSIS)
		      mealvo.setAnalysis(x: analysis)
	      guard let queryResultMealCOLUSERNAME = sqlite3_column_text(queryStatement, 7)
		      else { return res }	      
		      let userName = String(cString: queryResultMealCOLUSERNAME)
		      mealvo.setUserName(x: userName)

	      res.append(mealvo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  
  func searchByMealimages(val : String) -> [MealVO]
	  { var res : [MealVO] = [MealVO]()
	    let statement : String = "SELECT * FROM Meal WHERE images = " + "'" + val + "'" 
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let mealvo = MealVO()
	      
	      guard let queryResultMealCOLMEALID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let mealId = String(cString: queryResultMealCOLMEALID)
		      mealvo.setMealId(x: mealId)
	      guard let queryResultMealCOLMEALNAME = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let mealName = String(cString: queryResultMealCOLMEALNAME)
		      mealvo.setMealName(x: mealName)
	      let queryResultMealCOLCALORIES = sqlite3_column_double(queryStatement, 3)
		      let calories = Double(queryResultMealCOLCALORIES)
		      mealvo.setCalories(x: calories)
	      guard let queryResultMealCOLDATES = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let dates = String(cString: queryResultMealCOLDATES)
		      mealvo.setDates(x: dates)
	      guard let queryResultMealCOLIMAGES = sqlite3_column_text(queryStatement, 5)
		      else { return res }	      
		      let images = String(cString: queryResultMealCOLIMAGES)
		      mealvo.setImages(x: images)
	      guard let queryResultMealCOLANALYSIS = sqlite3_column_text(queryStatement, 6)
		      else { return res }	      
		      let analysis = String(cString: queryResultMealCOLANALYSIS)
		      mealvo.setAnalysis(x: analysis)
	      guard let queryResultMealCOLUSERNAME = sqlite3_column_text(queryStatement, 7)
		      else { return res }	      
		      let userName = String(cString: queryResultMealCOLUSERNAME)
		      mealvo.setUserName(x: userName)

	      res.append(mealvo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  
  func searchByMealanalysis(val : String) -> [MealVO]
	  { var res : [MealVO] = [MealVO]()
	    let statement : String = "SELECT * FROM Meal WHERE analysis = " + "'" + val + "'" 
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let mealvo = MealVO()
	      
	      guard let queryResultMealCOLMEALID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let mealId = String(cString: queryResultMealCOLMEALID)
		      mealvo.setMealId(x: mealId)
	      guard let queryResultMealCOLMEALNAME = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let mealName = String(cString: queryResultMealCOLMEALNAME)
		      mealvo.setMealName(x: mealName)
	      let queryResultMealCOLCALORIES = sqlite3_column_double(queryStatement, 3)
		      let calories = Double(queryResultMealCOLCALORIES)
		      mealvo.setCalories(x: calories)
	      guard let queryResultMealCOLDATES = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let dates = String(cString: queryResultMealCOLDATES)
		      mealvo.setDates(x: dates)
	      guard let queryResultMealCOLIMAGES = sqlite3_column_text(queryStatement, 5)
		      else { return res }	      
		      let images = String(cString: queryResultMealCOLIMAGES)
		      mealvo.setImages(x: images)
	      guard let queryResultMealCOLANALYSIS = sqlite3_column_text(queryStatement, 6)
		      else { return res }	      
		      let analysis = String(cString: queryResultMealCOLANALYSIS)
		      mealvo.setAnalysis(x: analysis)
	      guard let queryResultMealCOLUSERNAME = sqlite3_column_text(queryStatement, 7)
		      else { return res }	      
		      let userName = String(cString: queryResultMealCOLUSERNAME)
		      mealvo.setUserName(x: userName)

	      res.append(mealvo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  
  func searchByMealuserName(val : String) -> [MealVO]
	  { var res : [MealVO] = [MealVO]()
	    let statement : String = "SELECT * FROM Meal WHERE userName = " + "'" + val + "'" 
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let mealvo = MealVO()
	      
	      guard let queryResultMealCOLMEALID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let mealId = String(cString: queryResultMealCOLMEALID)
		      mealvo.setMealId(x: mealId)
	      guard let queryResultMealCOLMEALNAME = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let mealName = String(cString: queryResultMealCOLMEALNAME)
		      mealvo.setMealName(x: mealName)
	      let queryResultMealCOLCALORIES = sqlite3_column_double(queryStatement, 3)
		      let calories = Double(queryResultMealCOLCALORIES)
		      mealvo.setCalories(x: calories)
	      guard let queryResultMealCOLDATES = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let dates = String(cString: queryResultMealCOLDATES)
		      mealvo.setDates(x: dates)
	      guard let queryResultMealCOLIMAGES = sqlite3_column_text(queryStatement, 5)
		      else { return res }	      
		      let images = String(cString: queryResultMealCOLIMAGES)
		      mealvo.setImages(x: images)
	      guard let queryResultMealCOLANALYSIS = sqlite3_column_text(queryStatement, 6)
		      else { return res }	      
		      let analysis = String(cString: queryResultMealCOLANALYSIS)
		      mealvo.setAnalysis(x: analysis)
	      guard let queryResultMealCOLUSERNAME = sqlite3_column_text(queryStatement, 7)
		      else { return res }	      
		      let userName = String(cString: queryResultMealCOLUSERNAME)
		      mealvo.setUserName(x: userName)

	      res.append(mealvo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  

  func editMeal(mealvo : MealVO)
  { var updateStatement: OpaquePointer?
    let statement : String = "UPDATE Meal SET " 
    + " mealName = '"+mealvo.getMealName() + "'" 
 + "," 
    + " calories = " + String(mealvo.getCalories()) 
 + "," 
    + " dates = '"+mealvo.getDates() + "'" 
 + "," 
    + " images = '"+mealvo.getImages() + "'" 
 + "," 
    + " analysis = '"+mealvo.getAnalysis() + "'" 
 + "," 
    + " userName = '"+mealvo.getUserName() + "'" 
    + " WHERE mealId = '" + mealvo.getMealId() + "'" 

    if sqlite3_prepare_v2(dbPointer, statement, -1, &updateStatement, nil) == SQLITE_OK
    { sqlite3_step(updateStatement) }
    sqlite3_finalize(updateStatement)
  }

  func deleteMeal(val : String)
  { let deleteStatementString = "DELETE FROM Meal WHERE mealId = '" + val + "'"
    var deleteStatement: OpaquePointer?
    
    if sqlite3_prepare_v2(dbPointer, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK
    { sqlite3_step(deleteStatement) }
    sqlite3_finalize(deleteStatement)
  }

  func addUsereatsMeal(userName: String, mealId: String)
  { var updateStatement : OpaquePointer?
	let statement : String = "UPDATE Meal SET userName = '" + userName + "' WHERE mealId = '" + mealId + "'"
	if sqlite3_prepare_v2(dbPointer, statement, -1, &updateStatement, nil) == SQLITE_OK
	{ sqlite3_step(updateStatement) }
	  sqlite3_finalize(updateStatement)
	}
	
  func removeUsereatsMeal(mealId: String)
  { var updateStatement : OpaquePointer?
	let statement : String = "UPDATE Meal SET userName = 'NULL ' WHERE mealId = '" + mealId + "'"
	if sqlite3_prepare_v2(dbPointer, statement, -1, &updateStatement, nil) == SQLITE_OK
	{ sqlite3_step(updateStatement) }
	  sqlite3_finalize(updateStatement)
	}
	

  deinit
  { sqlite3_close(self.dbPointer) }

}

