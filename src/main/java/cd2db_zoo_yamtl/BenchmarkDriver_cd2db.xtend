package cd2db_zoo_yamtl

import CD.CDPackage
import Relational.RelationalPackage
import benchmark.BenchmarkHarness_cd2db
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl

class BenchmarkDriver_cd2db extends BenchmarkHarness_cd2db {
	var cd2db xform 
    val BASE_PATH = 'src/main/java/cd2db_zoo_yamtl'
    
	override getIdentifier() {
		"cd2db"
	}

	def static void main(String[] args) {
		
		val runner = new BenchmarkDriver_cd2db
		runner.runBenchmark(10)
	
	} 

	
	override doInitialization(int size) {
		doStandaloneEMFSetup()
		
		xform = new cd2db
		xform.fromRoots = false
		xform.enableCorrectnessCheck = false
		xform.enableUpfrontResizing(size)
	}

	override doLoad(String inputModelPath) {
		xform.loadInputModels(#{'cd' -> inputModelPath})
	}
	
	override doTransformation() {
		xform.execute()
	}
	
	override doSave(String fileName) {
//		var String outputModelPath = '''«BASE_PATH»/out_«fileName».xmi'''
// 	 	xform.saveOutputModels(#{'db' -> outputModelPath})
	}
	
	override doDispose() {
		xform.reset()
	}

	///////////////////////////////////////////////////////////////////////////////////////////
	// SOLUTION SPECIFIC
	///////////////////////////////////////////////////////////////////////////////////////////
	def doStandaloneEMFSetup() {
		Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("*", new XMIResourceFactoryImpl());
		
		CDPackage.eINSTANCE.eClass()
		RelationalPackage.eINSTANCE.eClass()
	}

	
}