//
//  MaterialShader.m
//  AR-Quest
//
//  Created by Reto Marti on 08.02.13.
//
//-------------------------------------------------------------------------------

#import "MaterialShader.h"
#import "ShaderUtils.h"
#import "Material.h"


@implementation MaterialShader


- (id) init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}


+ (MaterialShader*) newShader {
    
    MaterialShader* shader = [MaterialShader new];
    return shader;
}


- (void) setupInParams {
    [super setupInParams];

    // material
    material.ambientCoeffHandle  = glGetUniformLocation(programID, "material.ambientCoeff");
    ShaderUtils::checkGlError("setupInParams: ambientCoeff");
    material.diffuseCoeffHandle  = glGetUniformLocation(programID, "material.diffuseCoeff");
    ShaderUtils::checkGlError("setupInParams: diffuseCoeff");
    material.specularCoeffHandle = glGetUniformLocation(programID, "material.specularCoeff");
    ShaderUtils::checkGlError("setupInParams: specularCoeff");
    material.specularExpHandle   = glGetUniformLocation(programID, "material.specularExp");
    ShaderUtils::checkGlError("setupInParams: specularCoeff");
    material.shininessHandle     = glGetUniformLocation(programID, "material.shininess");
    ShaderUtils::checkGlError("setupInParams: shininess");

}


- (void) pushMaterialParam: (Material*) aMaterial {
    
    glGetError();
    
    // material.ambientCoeff
    glUniform4fv(material.ambientCoeffHandle, 1, aMaterial->lightReflection.ambientCoeff);
    ShaderUtils::checkGlError("pushMaterialParam: ambientColor");
    
    // material.diffuseCoeff
    glUniform4fv(material.diffuseCoeffHandle, 1, aMaterial->lightReflection.diffuseCoeff);
    ShaderUtils::checkGlError("pushMaterialParam: diffuseColor");
    
    // material.specularCoeff
    glUniform4fv(material.specularCoeffHandle, 1, aMaterial->lightReflection.specularCoeff);
    ShaderUtils::checkGlError("pushMaterialParam: specularColor");
    
    // material.specularExp
    glUniform1f(material.specularExpHandle, aMaterial->lightReflection.specularExp);
    ShaderUtils::checkGlError("pushMaterialParam: specularColor");
    
    // material.shininess
    glUniform1f(material.shininessHandle, aMaterial->lightReflection.shininess);
    ShaderUtils::checkGlError("pushMaterialParam: shininess");
}


- (void) pushInParams {
    [super pushInParams];
    
    // uniform mat4 mvMatrix
    glUniformMatrix4fv(mvMatrixHandle, 1, GL_FALSE, (const GLfloat*)&mvMatrix.data[0]);
    ShaderUtils::checkGlError("pushInParams: setup mvMatrix");

    // uniform mat4 normalMatrix
    glUniformMatrix4fv(normalMatrixHandle, 1, GL_FALSE, (const GLfloat*)&normalMatrix.data[0]);
    ShaderUtils::checkGlError("pushInParams: setup normalMatrix");
    
    // uniform Material material
    [self pushMaterialParam: self.oglObject.material];
}



@end
