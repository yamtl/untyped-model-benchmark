# YAMTL Benchmark with Untyped Models 

This repository contains two case studies.

## Class to Relational

The class to relational example, based on the ATL zoo case study:
 
* Metamodels can be found at `models/cd/CD.ecore` and `models/db/Relational.ecore`
* Input models can be found at `models/cd/`
* There are two model transformations
  * `cd2db_zoo_yamtl`: YAMTL trafo mimicking the ATL one with metamodel-based models
    * transformation: `cd2db.xtend`
    * runner (program invoking the transformation): `Runner.xtend`  
    * benchmark driver
  * `cd2db_zoo_yamtl_untyped`: YAMTL trafo mimicking the ATL one with untyped input models (class diagrams)
    * transformation: `cd2db_untypedModel.xtend`
    * runner (program invoking the transformation): `Runner_untypedModel.xtend`  
    * benchmark driver

The input models can be found in `models/cd/input_models.zip`.

## Datasets to PhysicalActivity

This is a case study demonstrating how to load large datasets available in CSV format in YAMTL. CSV files are loaded as untyped models and then transformed to instances of a metamodel, after undergoing some data transformations. The metamodel is available at `models/physicalActivity/HealthTracker.ecore`.

The transformation can be found at `CSV_to_healthTracker`:

* transformation: `CSV_to_PA_untyped_helper.xtend`
* runner (program invoking the transformation): `Runner_untypedModel_helper.xtend` 
* benchmark driver
    
The datasets can be found `models/physicalActivity/datasets.zip`.
