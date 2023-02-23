package cd2db_zoo_yamtl

class Runner {
	def public static void main(String[] args) {
		val BASE_PATH = 'src/main/java/cd2db_zoo_yamtl'
		var String inputModelPath = '''«BASE_PATH»/sourceModel.xmi'''
		var String inputModelDynamicPath = '''«BASE_PATH»/sourceModel_dynamic.xmi'''
		
		
		/*
		 * TYPED CD
		 */
		val xform = new cd2db

		// PREPARE MODELS
		xform.loadInputModels(#{'cd' -> inputModelPath})
		
		// EXECUTE TRAFO 
		xform.execute()
		
		// STORE MODELS
		var String outputModelPath = '''«BASE_PATH»/targetInitial.xmi'''
		xform.saveOutputModels(#{'db' -> outputModelPath})
		
		// PRINT STATS
		println(xform.toStringStats)
//		println(xform.generateBoilerplateCode)

	}
	
	
}