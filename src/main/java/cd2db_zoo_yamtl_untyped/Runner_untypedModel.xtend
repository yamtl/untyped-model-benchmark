package cd2db_zoo_yamtl_untyped

import CD.CDPackage

class Runner_untypedModel {
	def static void main(String[] args) {
		val BASE_PATH = 'src/main/java/cd2db_zoo_yamtl_untyped'
		var String mmPath = '''models/cd/CD.ecore'''
		var String inputModelPath = '''«BASE_PATH»/sourceModel.xmi'''
		
		
		// LOAD ENGINE AND INPUT MODELs
		val xform_untypedModel = new cd2db_untypedModel
		xform_untypedModel.loadMetamodel(mmPath, true)
		xform_untypedModel.importUntypedModelFromEMF('cd', inputModelPath)
		
		// EXECUTE TRAFO 
		xform_untypedModel.execute()
		
		// STORE MODELS
		var String outputModelPath_dynamic = '''«BASE_PATH»/targetInitial_untyped.xmi'''
		xform_untypedModel.saveOutputModels(#{'db' -> outputModelPath_dynamic})
		
		// PRINT STATS
		println(xform_untypedModel.toStringStats)
//		println(xform_dynamic.generateBoilerplateCode)
	}
	
	
}