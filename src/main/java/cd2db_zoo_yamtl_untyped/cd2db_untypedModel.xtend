package cd2db_zoo_yamtl_untyped

import Relational.Column
import Relational.RelationalPackage
import Relational.Table
import Relational.Type
import java.util.List
import untypedModel.ERecord
import untypedModel.UntypedModelPackage
import yamtl.core.YAMTLModule

import static org.apache.commons.text.WordUtils.uncapitalize
import static yamtl.dsl.Helper.*
import static yamtl.dsl.Rule.*

/**
 * Transformation that mimicks the ATL version (with ATOL improvements)
 * The main difference in the metamodels is that there are additional concepts: Package and Database
 */
class cd2db_untypedModel extends YAMTLModule {
	val CD = UntypedModelPackage.eINSTANCE  
	val DB = RelationalPackage.eINSTANCE  
	new () {
		header().in('cd').out('db', DB)
		
		ruleStore( newArrayList(
			
			rule('ClassToTable')
				.in('c').filter [
					c.getString("eClass_") == "Class"
				]
				.out('t', DB.table, [
					t.name = c.getString("name")
					t.col += pk_col
					t.key += pk_col
					t.col += c.getRefs("attr").filter[att | !att.getBoolean("multiValued")].fetch as List<Column>
				])
				.out('pk_col', DB.column, [
					pk_col.name = 'objectId'
					pk_col.type = 'objectIdType'.fetch as Type
				]),
		
			rule('DataTypeAttributeToColumn')
				.in('att').filter [
					att.getString("eClass_") == "Attribute" 
					&&
					att.getRefs("type")?.head.getString("eClass_") == "DataType"
					&& 
					!att.getBoolean("multiValued")
				]
				.out('col', DB.column, [ 
					col.name = att.getString("name")
					col.type = att.getRefs("type").head.fetch as Type
				]),

			rule('MultiValuedDataTypeAttribute2Column')
				.in('att').filter [
					att.getString("eClass_") == "Attribute" 
					&&
					att.getRefs("type")?.head.getString("eClass_") == "DataType"
					&& 
					att.getBoolean("multiValued")
				]
				.out('t', DB.table, [
					t.name = att.getRefs("owner").head.getString("name") + '_' + att.getString("name")
					t.col += #[ pk_col, col ]
					t.key += pk_col
				])
				.out('pk_col', DB.column, [
					pk_col.name = uncapitalize(att.getRefs("owner").head.getString("name")) + 'Id' 
					pk_col.type = 'objectIdType'.fetch as Type
				])
				.out('col', DB.column, [ 
					col.name = att.getString("name")
					col.type = att.getRefs("type").head.fetch as Type
				]),
				
			rule('ClassAttribute2Column')
				.in('att').filter([
					att.getString("eClass_") == "Attribute" 
					&&
					att.getRefs("type")?.head.getString("eClass_") == "Class"
					&& 
					!att.getBoolean("multiValued")
				])
				.out('col', DB.column, [ 
					col.name = att.getString("name") + 'Id'
					col.type = 'objectIdType'.fetch as Type
				]),
				
			rule('MultiValuedClassAttribute2Column')
				.in('att').filter([
					att.getString("eClass_") == "Attribute" 
					&&
					att.getRefs("type")?.head.getString("eClass_") == "Class"
					&& 
					att.getBoolean("multiValued")
				])
				.out('t', DB.table, [
					t.name = att.getRefs("owner").head.getString("name") + '_' + att.getString("name")
					t.col += #[ pk_col, fk_col ]
					t.key += #[ pk_col, fk_col ] // different from ATL, where PK is not declared
				])
				.out('pk_col', DB.column, [
					pk_col.name = uncapitalize(att.getRefs("owner").head.getString("name")) + 'Id'
					pk_col.type = 'objectIdType'.fetch as Type 
				])
				.out('fk_col', DB.column, [ 
					fk_col.name = att.getString("name") + 'Id'
					fk_col.type = 'objectIdType'.fetch as Type 
				]),
				
			rule('DataType2Type')
				.in('dt').filter [
					dt.getString("eClass_") == "DataType" 
				]
				.out('tp', DB.type) [
					tp.name = dt.getString("name")
				]
				
		))
		
				helperStore( newArrayList(

staticAttribute('objectIdType') [ 
	CD.ERecord.allInstances
		.map[it as ERecord]
		.filter[ it.getString("eClass_") == "DataType" && it.getString("name")=="Integer" ]
		.head.fetch as Type
]

			)
		)
	}
	
	
	// CD Helpers
	def c() {
	  'c'.fetch() as ERecord
	}
	def att() {
	  'att'.fetch() as ERecord
	}
	def ref() {
	  'ref'.fetch() as ERecord
	}
	def dt() {
	  'dt'.fetch() as ERecord
	}
	
	// DB Helpers
	def t() {
	  't'.fetch() as Table
	}
	def pk_col() {
	  'pk_col'.fetch() as Column
	}
	def col() {
	  'col'.fetch() as Column
	}
	def fk_col() {
	  'fk_col'.fetch() as Column
	}
	def tp() {
	  'tp'.fetch() as Type
	}
		
}


