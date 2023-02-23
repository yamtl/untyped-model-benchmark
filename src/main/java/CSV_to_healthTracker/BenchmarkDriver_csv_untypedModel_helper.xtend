package CSV_to_healthTracker

import CD.CDPackage
import Relational.RelationalPackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import untypedModel.UntypedModelPackage

class BenchmarkDriver_csv_untypedModel_helper extends BenchmarkHarness_csv {
 
    val BASE_PATH = 'src/main/java/CSV_to_healthTracker'
    
	override getIdentifier() {
		"csv2pa_untyped_helper"
	}

	def static void main(String[] args) {
		
		val runner = new BenchmarkDriver_csv_untypedModel_helper
		runner.runBenchmark(10, 6, 6)
	
	} 
	
	override doInitialization(int size) {
		doStandaloneEMFSetup()
		
		xform = new CSV_to_PA_untyped_helper
		xform.enableCorrectnessCheck = false
//		xform.enableUpfrontResizing(size)
	}

	override doLoad(String inputModelPath) {
		xform.importUntypedModelFromCsvFile('csv', inputModelPath)
		
	}
	
	override doTransformation() {
		xform.execute()
	}
	
	override doSave(String fileName) {
//		var String outputModelPath = '''src/main/java/CSV_to_healthTracker/output_«fileName».xmi'''
//		xform.saveOutputModels(#{'pa' -> outputModelPath})
	}
	
	override doDispose() {
		xform.reset()
		xform.resetTypeExtent()
		xform.resetModelRegistry()
	}

	///////////////////////////////////////////////////////////////////////////////////////////
	// SOLUTION SPECIFIC
	///////////////////////////////////////////////////////////////////////////////////////////
	def doStandaloneEMFSetup() {
		Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("*", new XMIResourceFactoryImpl());
		
		UntypedModelPackage.eINSTANCE.eClass()
		CDPackage.eINSTANCE.eClass()
		RelationalPackage.eINSTANCE.eClass()
	}
	

	
}