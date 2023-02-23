package CSV_to_healthTracker

import HealthTracker.AirCondition
import HealthTracker.AirQuality
import HealthTracker.HealthTrackerFactory
import HealthTracker.HealthTrackerPackage
import HealthTracker.Intensity
import HealthTracker.Patient
import HealthTracker.PhysicalActivity
import java.text.SimpleDateFormat
import untypedModel.ERecord
import untypedModel.UntypedModelPackage
import yamtl.core.YAMTLModule

import static yamtl.dsl.Helper.*
import static yamtl.dsl.Rule.*

/**
 * Transformation that mimicks the ATL version (with ATOL improvements)
 * The main difference in the metamodels is that there are additional concepts: Package and Database
 */
class CSV_to_PA_untyped_helper extends YAMTLModule {
	val PA = HealthTrackerPackage.eINSTANCE  
	val PAFactory = HealthTrackerFactory.eINSTANCE  
	new () {
		header().in('csv').out('pa', PA)
		
		ruleStore( newArrayList(
			
rule('Activity')
	.in('r')
	.out('a', PA.physicalActivity) [
		val r = 'r'.fetch as ERecord
		
		val patient_id = r.getInteger("patient_id")
		var p = 'getPatient'.fetch(#{'patient_id' -> patient_id}) as Patient
		p.activities += a
		
		val date = r.getString("date")
		val time = r.getString("time")
		val dateFormat = new SimpleDateFormat("MM/dd/yyyy HH:mm");
		a.date = dateFormat.parse(date + " " + time)
		a.duration = r.getInteger("duration_minutes")
		a.distance = r.getDouble("distance_km")
		a.intensity = Intensity.get(r.getString("intensity"))
		a.airCondition = AirCondition.get(r.getString("air_condition"))
		a.airQuality = AirQuality.get(r.getString("air_quality"))
	]
	
		))
	
	
		helperStore( newArrayList(

// creates a patient for each new id
// the result is unique
staticOperation('getPatient') [ argMap |
	val patient_id = argMap.get('patient_id') as Integer
	val p = PAFactory.createPatient
	p.patientID = patient_id
	p
]

			)
		)
	}
	
	
	
	// BOILERPLATE CODE
	def p() {
		'p'.fetch as Patient
	}
	def a() {
		'a'.fetch as PhysicalActivity
	}
}	
	
		
