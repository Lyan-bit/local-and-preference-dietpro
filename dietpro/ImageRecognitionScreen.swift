
import SwiftUI

struct ImageRecognitionScreen: View {
    @State var objectId: String = ""
    @ObservedObject var model : ModelFacade
    
    @State var result : String = ""
    
    var body: some View {
  	NavigationView {
  		ScrollView {
        VStack {
            HStack (spacing: 20) {
             	Text("mealId:").bold()
             	Divider()
                Picker("Select a object", selection: $objectId) {
                  ForEach(model.currentMeals) { Text($0.mealId).tag($0.mealId) }
                }.pickerStyle(.menu)
            }.frame(width: 200, height: 30).border(Color.gray)

            VStack (spacing: 20) {
             	Text("Result:").bold()
                Text("\(result)")
            }.frame(width: 200, height: 60).border(Color.gray)
                
            HStack (spacing: 20) {
                Button(action: {result = self.model.imageRecognition(x: objectId) } ) { Text("Classify") }
				Button(action: {self.model.cancelImageRecognition() } ) { Text("Cancel") }
		    }.buttonStyle(.bordered)
                        
        }.onAppear(perform:
        	{ objectId = model.currentMeal?.mealId ?? "id" 
        	  model.listMeal()
        	})
         }.navigationTitle("imageRecognition")
        }
      }
    }

struct ImageRecognitionScreen_Previews: PreviewProvider {
    static var previews: some View {
        ImageRecognitionScreen(model: ModelFacade.getInstance())
    }
}
