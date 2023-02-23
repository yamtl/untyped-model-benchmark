package CSV_to_healthTracker

import CD.CDPackage
import Relational.RelationalPackage
import benchmark.BenchmarkHarness_cd2db
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import com.fasterxml.jackson.dataformat.csv.CsvMapper
import com.fasterxml.jackson.databind.MappingIterator
import com.fasterxml.jackson.dataformat.csv.CsvSchema
import java.io.File
import java.util.ArrayList
import java.util.List
import java.util.Map

// loads CSV using Jackson library only
class BenchmarkDriver_csv_jackson extends BenchmarkHarness_csv {
    val BASE_PATH = 'src/main/java/CSV_to_healthTracker'
    
	override getIdentifier() {
		"csv_jackson"
	}

	def static void main(String[] args) {
		
		val runner = new BenchmarkDriver_csv_jackson
		runner.runBenchmark(10,1,6)
	
	} 


	override doInitialization(int size) {
	}
	
	override doLoad(String inputModelPath) {

		val File csvFile = new File(inputModelPath);
		val CsvMapper csvMapper = new CsvMapper();
		val CsvSchema schema = CsvSchema.emptySchema().withHeader(); // use first row as header; otherwise defaults are fine
		val MappingIterator<Map<String,String>> iterator = csvMapper.readerFor(Map)
		   .with(schema)
		   .readValues(csvFile);

		// parse contents
		val List<Map<String,String>> recordList = newArrayList
		while (iterator.hasNext()) {
		  val Map<String,String> rowAsMap = iterator.next();
		  recordList.add(rowAsMap);
		}
		
	}
	
	override doTransformation() {
	}
	
	override doSave(String fileName) {
	}
	
	override doDispose() {
	}

}