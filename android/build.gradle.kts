// Top-level build file where you can add configuration options common to all sub-projects/modules.

plugins {
    // Google Services Gradle plugin (used for Firebase)
    id("com.google.gms.google-services") version "4.4.3" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Custom build directory outside default location
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// Force app project to be evaluated first (needed in multi-module builds)
subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task to delete the build directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
    
}
