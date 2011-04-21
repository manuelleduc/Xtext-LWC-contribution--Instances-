/*
 * generated by Xtext
 */
package org.xtext.lwc.instances.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IFileSystemAccess
import org.xtext.lwc.instances.instances.Instance
import org.eclipse.xtext.xbase.XVariableDeclaration
import org.eclipse.emf.common.util.EList
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.compiler.StringBuilderBasedAppendable
import org.eclipse.xtext.xbase.XBlockExpression
import org.xtext.lwc.instances.instances.ObjectLiteral

class InstancesGenerator implements IGenerator {
	
	@Inject ExpressionsCompiler as compiler
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		val instance = resource.contents.head as Instance
		val lastSegment = resource.URI.lastSegment
		val simpleFileName = lastSegment.substring(0, lastSegment.indexOf('.'))
		if (instance!=null) {
			fsa.generateFile(simpleFileName+".java", generateJavaFile(instance, simpleFileName))
		}
	}
	
	generateJavaFile(Instance inst, String name) '''
		public class �name� {
			�FOR varDecl : inst.expressions.filter(typeof(XVariableDeclaration))�
				private �varDecl.type.identifier� �varDecl.name� = null;
				public �varDecl.type.identifier� get�varDecl.name.toFirstUpper�() {
					if (�varDecl.name� == null) {
						�varDecl.name� = new �varDecl.type.identifier�();
						�generateExpression(varDecl.right, varDecl.name)�
					}
					return �varDecl.name�; 
				}
			�ENDFOR�
		}
	'''
	
	dispatch String generateExpression(XExpression expr, String name) {
		throw new IllegalArgumentException()
	}
	
	dispatch String generateExpression(ObjectLiteral expr, String name) {
		val appendable = new StringBuilderBasedAppendable()
		appendable.declareVariable(expr, name)
		for (e : expr.expressions) {
			compiler.toJavaStatement(e, appendable, false)
		}
		return appendable.toString;
	}
}
