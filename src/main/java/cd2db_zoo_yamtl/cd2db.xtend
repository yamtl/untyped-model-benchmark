package cd2db_zoo_yamtl

import CD.Attribute
import CD.CDPackage
import CD.Class
import CD.DataType
import Relational.Column
import Relational.RelationalPackage
import Relational.Table
import Relational.Type
import java.util.List
import yamtl.core.YAMTLModule

import static yamtl.dsl.Rule.*
import static yamtl.dsl.Helper.*
import static org.apache.commons.text.WordUtils.uncapitalize

/**
 * Transformation that mimicks the ATL version (with ATOL improvements)
 * The main difference in the metamodels is that there are additional concepts: Package and Database
 */
class cd2db extends YAMTLModule {
	val CD = CDPackage.eINSTANCE  
	val DB = RelationalPackage.eINSTANCE  
	new () {
		header().in('cd', CD).out('db', DB)
		
		ruleStore( newArrayList(
			
			rule('ClassToTable')
				.in('c', CD.class_)
				.out('t', DB.table, [
					t.name = c.name
					t.col += pk_col
					t.key += pk_col
					t.col += c.attr.filter[a | !a.multiValued].fetch as List<Column>
				])
				.out('pk_col', DB.column, [
					pk_col.name = 'objectId'
					pk_col.type = 'objectIdType'.fetch as Type
				]),
		
			rule('DataTypeAttributeToColumn')
				.in('att', CD.attribute).filter([
					att.type instanceof DataType && !att.multiValued
				])
				.out('col', DB.column, [ 
					col.name = att.name
					col.type = att.type.fetch as Type
				]),

			rule('MultiValuedDataTypeAttribute2Column')
				.in('att', CD.attribute).filter([
					att.type instanceof DataType && att.multiValued
				])
				.out('t', DB.table, [
					t.name = att.owner.name + '_' + att.name
					t.col += #[ pk_col, col ]
					t.key += pk_col
				])
				.out('pk_col', DB.column, [
					pk_col.name = uncapitalize(att.owner.name) + 'Id' 
					pk_col.type = 'objectIdType'.fetch as Type
				])
				.out('col', DB.column, [ 
					col.name = att.name
					col.type = att.type.fetch as Type
				]),
				
			rule('ClassAttribute2Column')
				.in('att', CD.attribute).filter([
					att.type instanceof Class && !att.multiValued
				])
				.out('col', DB.column, [ 
					col.name = att.name + 'Id'
					col.type = 'objectIdType'.fetch as Type
				]),
				
			rule('MultiValuedClassAttribute2Column')
				.in('att', CD.attribute).filter([
					att.type instanceof Class && att.multiValued
				])
				.out('t', DB.table, [
					t.name = att.owner.name + '_' + att.name
					t.col += #[ pk_col, fk_col ]
					t.key += #[ pk_col, fk_col ] // different from ATL, where PK is not declared
				])
				.out('pk_col', DB.column, [
					pk_col.name = uncapitalize(att.owner.name) + 'Id'
					pk_col.type = 'objectIdType'.fetch as Type 
				])
				.out('fk_col', DB.column, [ 
					fk_col.name = att.name + 'Id'
					fk_col.type = 'objectIdType'.fetch as Type 
				]),
				
			rule('DataType2Type')
				.in ('dt', CD.dataType)
				.out('tp', DB.type) [
					tp.name = dt.name
				]
				
		))
		
		helperStore( newArrayList(

staticAttribute('objectIdType') [ 
	CD.dataType.allInstances.filter[(it as DataType).name=="Integer"].head.fetch as Type
]

			)
		)
	}
	
	
	def objectIdType() {
		CD.dataType.allInstances.filter[(it as DataType).name=="Integer"].head.fetch as Type
	}
	
	
	// CD Helpers
	def c() {
	  'c'.fetch() as Class
	}
	def att() {
	  'att'.fetch() as Attribute
	}
	def ref() {
	  'ref'.fetch() as Attribute
	}	
	def dt() {
	  'dt'.fetch() as DataType
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
