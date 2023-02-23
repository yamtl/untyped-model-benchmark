package benchmark

import com.google.common.testing.GcFinalization
import java.io.File
import java.util.Date
import java.util.List
import java.util.TimeZone
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.util.Files

abstract class BenchmarkHarness_cd2db  {
	
	val BASE_PATH = "models/cd"
	val WARM_UP_ITERATION_NUMBER = 10
	
	@Accessors 
	public boolean debug = false 
	
	extension val static GroovyUtil util = new GroovyUtil() 

    def abstract void doInitialization(int size)
    def abstract void doLoad(String iteration)   
    def abstract void doTransformation()
    def abstract void doSave(String iteration)
    def abstract void doDispose()
    
    def abstract String getIdentifier() 
	
		
	def getIterations() {
		val list = newArrayList
		
		
		// intance sizes
//		val i_size = #[8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]
		val i_size = #[8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768]
		for (i: i_size) {
			list.add('''Package_«pad(i,5)»''')
		}
		
		list
	}
    
	
	def runBenchmark(int times) 
	{
		// bytes
		var long memoryBeforeLoadingModels
		var long memoryAfterLoadingModels
		var long memoryBeforeInitialization
		var long memoryAfterInitialization
		var long memoryBeforeTransformation
		var long memoryAfterTransformation
		var long memoryBeforeSaving
		var long memoryAfterSaving
		
		var long start 
		var long now 
		var double loadTime 
		var double preProcessTime 
		var double trafoTime 
		var double saveTime
		var String previousFileName
		
		var List<PerformanceResult> iterPerformanceResults = newArrayList
		var List<MemoryResult> iterMemoryResults = newArrayList
				
		var results = "scale"
		
		for (i: 0 ..< times) {
			results += ''', init «i» (ms), load «i» (ms), trafo «i» (ms), save «i» (ms), total «i» (ms)'''
		}
		results += ", total_median (ms), init_median (ms), load_median (ms), trafo_median (ms), save_median (ms)\n"
		
		var resultsMemory = "scale"
		for (i: 0 ..< times) {
			resultsMemory += ''', load «i» (MB), init «i» (MB), trafo «i» (MB), save «i» (MB), total «i» (MB)'''
		}
		results += ", total_median (ms), init_median (ms), load_median (ms), trafo_median (ms), save_median (ms)\n"
		

		

		/**
		 * WARM-UP
		 */
		val fileNameWarmUp = 'Package_00008'
		val filePathWarmUp = '''«BASE_PATH»/«fileNameWarmUp».xmi'''
		for (iter : 0 ..< WARM_UP_ITERATION_NUMBER) { 
		
			//////////////////////////////////////////////////////////////////////////
			// INITIALIZATION
			doInitialization(100)

			//////////////////////////////////////////////////////////////////////////
			// LOAD
			doLoad(filePathWarmUp)
			
			//////////////////////////////////////////////////////////////////////////
			// TRANSFORMATION
			doTransformation
			
			//////////////////////////////////////////////////////////////////////////
			// SAVE OUTPUT
			doSave(fileNameWarmUp)
		}
		 

		for (fileName : getIterations) {
			val filePath = '''«BASE_PATH»/«fileName».xmi'''

			println("------------------------------------------------------------------------")
			println('''transforming «fileName»''')
			
			results += '''«fileName»'''
			resultsMemory += '''«fileName»'''
			
			iterPerformanceResults = newArrayList
			iterMemoryResults = newArrayList
			for (iter : 0 ..< times) { 
				println("	iteration " + iter)
				
				freeGC()

				//////////////////////////////////////////////////////////////////////////
				// INITIALIZATION
				
				// get size
				val size = Integer.valueOf(fileName.substring(fileName.length-5, fileName.length))
				
				memoryBeforeInitialization = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
				start = System.nanoTime();
				doInitialization(size)
				now = System.nanoTime();
				preProcessTime = (now - start) / 1000000 as double;
				memoryAfterInitialization = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();

				if (debug) println('''pre-process time: «preProcessTime»''')
				freeGC()
				
				//////////////////////////////////////////////////////////////////////////
				// LOAD
				memoryBeforeLoadingModels = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
				start = System.nanoTime();
				doLoad(filePath)
				now = System.nanoTime();
				loadTime = (now - start) / 1000000 as double;
				memoryAfterLoadingModels = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();

				if (debug) println('''load time: «loadTime»''')
				freeGC()
			

				
				//////////////////////////////////////////////////////////////////////////
				// TRANSFORMATION
				memoryBeforeTransformation = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
				start = System.nanoTime();
				doTransformation
				now = System.nanoTime();
				trafoTime = (now - start) / 1000000 as double;
				memoryAfterTransformation = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();

				if (debug) {
					println('''trafo time: «start»''')
					println('''trafo time: «now»''')
					println('''trafo time: «now-start»''')
					println('''trafo time: «trafoTime»''')
				}
				freeGC()
				
				//////////////////////////////////////////////////////////////////////////
				// SAVE OUTPUT
				memoryBeforeSaving = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
				start = System.nanoTime();
				doSave(fileName)
				now = System.nanoTime();
				saveTime = (now - start) / 1000000 as double;
				memoryAfterSaving = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();

				if (debug) println('''save time: «saveTime»''')
				
				// SAVING ITER RESULTS
				val result = new PerformanceResult(loadTime, preProcessTime, trafoTime, saveTime)
				iterPerformanceResults.add(
					result
				)
				
				val memoryResult = new MemoryResult(
					memoryAfterLoadingModels-memoryBeforeLoadingModels,
					memoryAfterInitialization-memoryBeforeInitialization, 
					memoryAfterTransformation-memoryBeforeTransformation,
					memoryAfterSaving-memoryBeforeSaving
				)
				iterMemoryResults.add(
					memoryResult
				)
				
			}
		


		
			////////////////////////////////////////////////////////////////////////
			// BENCHMARKS RESULTS FOR THE ITERATION
							
			// PERFORMANCE
			// iterPerformanceResults.sortInplaceBy[totalTime]
			val double median=iterPerformanceResults.map[it.totalTime].median
			val double init_median=iterPerformanceResults.map[it.initTime].median
			val double load_median=iterPerformanceResults.map[it.loadTime].median
			val double trafo_median=iterPerformanceResults.map[it.trafoTime].median
			val double save_median=iterPerformanceResults.map[it.saveTime].median
			val double avg=iterPerformanceResults.map[totalTime].reduce[ a, b | a + b ] / times
			
			println('''time taken: median («median» ms), avg («avg» ms)''')
			
			results += ''
			
			// we have deleted min, max
			for (result: iterPerformanceResults) {
				results += ''', «result.initTime», «result.loadTime», «result.trafoTime», «result.saveTime», «result.totalTime»'''
			}
			results += ''',«median»,«init_median»,«load_median»,«trafo_median»,«save_median»
			'''
			
			
			// MEMORY			
			// iterMemoryResults.sortInplaceBy[totalMemory]
			val long mem_median=iterMemoryResults.map[totalMemory].median
			val long mem_init_median=iterMemoryResults.map[it.initMemory].median
			val long mem_load_median=iterMemoryResults.map[it.loadMemory].median
			val long mem_trafo_median=iterMemoryResults.map[it.trafoMemory].median
			val long mem_save_median=iterMemoryResults.map[it.saveMemory].median
			val long memoryAvg=iterMemoryResults.map[totalMemory].reduce[ a, b | a + b ] / times
			println('''memory taken: «mem_median.toMB» MB''')
			
			resultsMemory += ''
			// we have deleted min, max
			for (result: iterMemoryResults) {
				resultsMemory += ''', «result.initMemory.toMB», «result.loadMemory.toMB», «result.trafoMemory.toMB», «result.saveMemory.toMB», «result.totalMemory.toMB»'''
			}
			resultsMemory += ''',«mem_median.toMB»,«mem_init_median.toMB»,«mem_load_median.toMB»,«mem_trafo_median.toMB»,«mem_save_median.toMB»
			'''
			
			//////////////////////////////////////////////////////////////////////////
			// CLEAN MEMORY
			doDispose
			
			
			// Append loading/saving times
//			results +=	'''«fileName»,«loadTime»,«saveTime»''' + results
//			resultsMemory += '''«fileName»,«(memoryAfterLoadingModels-memoryBeforeLoadingModels).toMB»,«(memoryAfterSaving-memoryAfterTransformation).toMB»''' + resultsMemory
			
			
			// FLUSH TO FILE
			val timestamp = new Date().format("yyyyMMdd-HHmm", TimeZone.getTimeZone('UTC'))
			val outputFileName = '''«identifier»_«timestamp».csv'''
			val outputMemoryFileName = '''«identifier»_«timestamp».csv'''
			
			// store file during iteration to avoid waiting for large models
			Files.writeStringIntoFile(
				"results_" + outputFileName,
				results
			)
			Files.writeStringIntoFile(
				"resultsMemory_" + outputMemoryFileName,
				resultsMemory
			)
			
			// delete file generated for previous iteration
			if ((previousFileName !== null) && (previousFileName != outputFileName))  
			{
				new File("results_" + previousFileName).delete	
				new File("resultsMemory_" + previousFileName).delete	
			}
			previousFileName = outputFileName
			
			
		}
	}
	
	def static long median(long[] m) {
		// sort list in ascending order
		m.sortInplace
		
	    val int middle = m.length/2;
	    if (m.length%2 == 1) {
	        return m.get(middle);
	    } else {
	        return (m.get(middle) + m.get(middle)) / 2;
	    }
	}
	def static double median(double[] m) {
		// sort list in ascending order
		m.sortInplace
		
	    val int middle = m.length/2;
	    if (m.length%2 == 1) {
	        return m.get(middle);
	    } else {
	        return (m.get(middle) + m.get(middle)) / 2;
	    }
	}
	
	def toMB(long value) {
		value/(1024*1024) // Mbs
	}
	
	def freeGC() {
		// MEMORY usage measurement: from https://wiki.eclipse.org/VIATRA/Query/FAQ#Best_practices
		System.gc();
		System.gc();
		System.gc();
		System.gc();
		System.gc();
		
		try {
		  Thread.sleep(1000); // wait for the GC to settle
		} catch (InterruptedException e) { 
			// TODO handle exception properly 
		}
		
		// https://stackoverflow.com/a/27831908
		GcFinalization.awaitFullGc();
	}
	
	def String pad(int number, int N) {
		val String str = Integer.toString(number);
		val int zeros = N - str.length();
		var String prefix = "";
		for (var i = 0; i < zeros; i++) {
			prefix += "0";
		}
		return prefix + str;
	}
}