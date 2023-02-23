package cd2db_zoo_yamtl_untyped

import CD.CDPackage
import Relational.RelationalPackage
import benchmark.BenchmarkHarness_cd2db
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import untypedModel.UntypedModelPackage

class BenchmarkDriver_cd2db_untypedModel extends BenchmarkHarness_cd2db {
	var cd2db_untypedModel xform 
    val BASE_PATH = 'src/main/java/cd2db_zoo_yamtl_untyped'
    
	override getIdentifier() {
		"cd2db_untypedModel"
	}

	def static void main(String[] args) {
		
		val runner = new BenchmarkDriver_cd2db_untypedModel
		runner.runBenchmark(10)
	
	} 

	ResourceSet resourceSet;
	override doInitialization(int size) {
		doStandaloneEMFSetup()
	
		resourceSet = new ResourceSetImpl
		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().
		put(
				Resource.Factory.Registry.DEFAULT_EXTENSION, 
				new XMIResourceFactoryImpl()
		);		
		resourceSet.getPackageRegistry().put(UntypedModelPackage.eINSTANCE.getNsURI(), UntypedModelPackage.eINSTANCE);
		resourceSet.getPackageRegistry().put(CDPackage.eINSTANCE.getNsURI(), CDPackage.eINSTANCE);
		
	
		// to load metamodel
		CDPackage.eINSTANCE.eClass
		
		xform = new cd2db_untypedModel
		xform.fromRoots = false
		xform.enableCorrectnessCheck = false
		xform.enableUpfrontResizing(size)
	}

	override doLoad(String inputModelPath) {
		xform.importUntypedModelFromEMF('cd', inputModelPath)
	}
	
	override doTransformation() {
		xform.execute()
	}
	
	override doSave(String fileName) {
		var String outputModelPath = '''«BASE_PATH»/out_«fileName».xmi'''
	 	xform.saveOutputModels(#{'db' -> outputModelPath})
	}
	
	override doDispose() {
		xform.reset()
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