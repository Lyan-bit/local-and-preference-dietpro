import Foundation
import SQLite3

/* Code adapted from https://www.raywenderlich.com/6620276-sqlite-with-swift-tutorial-getting-started */

class DB {
  let dbPointer : OpaquePointer?
  static let dbName = "dietproApp.db"
  static let dbVersion = 1

  static let mealTableName = "Meal"
  static let mealID = 0
  static let mealCols : [String] = ["TableId", "mealId", "mealName", "calories", "dates", "images", "analysis", "userName"]
  static let mealNumberCols = 0

  static let mealCreateSchema =
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
    try createTable(table: DB.mealCreateSchema)
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
  { 
  	let statement = "SELECT * FROM Meal "
  	return setDataMeal(statement: statement)
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
	  { 
	  	let statement : String = "SELECT * FROM Meal WHERE mealId = " + "'" + val + "'" 
	  	return setDataMeal(statement: statement)
	  }
	  
  func searchByMealmealName(val : String) -> [MealVO]
	  { 
	  	let statement : String = "SELECT * FROM Meal WHERE mealName = " + "'" + val + "'" 
	  	return setDataMeal(statement: statement)
	  }
	  
  func searchByMealcalories(val : Double) -> [MealVO]
	  { 
	  	let statement : String = "SELECT * FROM Meal WHERE calories = " + String( val )
	  	return setDataMeal(statement: statement)
	  }
	  
  func searchByMealdates(val : String) -> [MealVO]
	  { 
	  	let statement : String = "SELECT * FROM Meal WHERE dates = " + "'" + val + "'" 
	  	return setDataMeal(statement: statement)
	  }
	  
  func searchByMealimages(val : String) -> [MealVO]
	  { 
	  	let statement : String = "SELECT * FROM Meal WHERE images = " + "'" + val + "'" 
	  	return setDataMeal(statement: statement)
	  }
	  
  func searchByMealanalysis(val : String) -> [MealVO]
	  { 
	  	let statement : String = "SELECT * FROM Meal WHERE analysis = " + "'" + val + "'" 
	  	return setDataMeal(statement: statement)
	  }
	  
  func searchByMealuserName(val : String) -> [MealVO]
	  { 
	  	let statement : String = "SELECT * FROM Meal WHERE userName = " + "'" + val + "'" 
	  	return setDataMeal(statement: statement)
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

  func setDataMeal(statement: String) -> [MealVO] {
          var res : [MealVO] = [MealVO]()
          let queryStatement = try? prepareStatement(sql: statement)
          
          while (sqlite3_step(queryStatement) == SQLITE_ROW)
          { 
            let mealvo = MealVO()
            
	      guard let queryResultMealColMealId = sqlite3_column_text(queryStatement, 1)
			      else { return res }	      
			      let mealId = String(cString: queryResultMealColMealId)
			      mealvo.setMealId(x: mealId)
	      guard let queryResultMealColMealName = sqlite3_column_text(queryStatement, 2)
			      else { return res }	      
			      let mealName = String(cString: queryResultMealColMealName)
			      mealvo.setMealName(x: mealName)
	      let queryResultMealColCalories = sqlite3_column_double(queryStatement, 3)
			      let calories = Double(queryResultMealColCalories)
			      mealvo.setCalories(x: calories)
	      guard let queryResultMealColDates = sqlite3_column_text(queryStatement, 4)
			      else { return res }	      
			      let dates = String(cString: queryResultMealColDates)
			      mealvo.setDates(x: dates)
	      guard let queryResultMealColImages = sqlite3_column_text(queryStatement, 5)
			      else { return res }	      
			      let images = String(cString: queryResultMealColImages)
			      mealvo.setImages(x: images)
	      guard let queryResultMealColAnalysis = sqlite3_column_text(queryStatement, 6)
			      else { return res }	      
			      let analysis = String(cString: queryResultMealColAnalysis)
			      mealvo.setAnalysis(x: analysis)
	      guard let queryResultMealColUserName = sqlite3_column_text(queryStatement, 7)
			      else { return res }	      
			      let userName = String(cString: queryResultMealColUserName)
			      mealvo.setUserName(x: userName)
  
            res.append(mealvo)
          }
          sqlite3_finalize(queryStatement)
          return res
      }
      
}

