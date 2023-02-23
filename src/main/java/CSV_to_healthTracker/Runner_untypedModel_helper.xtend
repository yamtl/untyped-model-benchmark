package CSV_to_healthTracker

class Runner_untypedModel_helper {
	def static void main(String[] args) {
		
		var String BASE_PATH = '''C:/Users/ab373/Documents/git-artur/yamtl-untyped/ecmfa23-model-gen/models/physicalActivity'''
		val String FILE_NAME = "dataset_1"
		
		var String inputPath = BASE_PATH + "/" + FILE_NAME + ".csv"
		val xform = new CSV_to_PA_untyped_helper

		// PREPARE MODELS
		// Parses a CSV file and stores it as a runtime model in the YAMTL registry
		xform.importUntypedModelFromCsvFile('csv', inputPath)
		
		// EXECUTE TRAFO 
		xform.execute()
		
		// STORE MODELS
		var String outputModelPath = '''src/main/java/CSV_to_healthTracker/output_«FILE_NAME».xmi'''
		xform.saveOutputModels(#{'pa' -> outputModelPath})
		
		// PRINT STATS
		println(xform.toStringStats)
		
		// GENERATE BOlIERPLATE CODE
		// println(xform.generateBoilerplateCode())
		
	}
}