allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as? com.android.build.gradle.BaseExtension
            android?.apply {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        
        if (project.plugins.hasPlugin("org.jetbrains.kotlin.android")) {
            val kotlinOptions = project.extensions.findByName("kotlinOptions") as? org.jetbrains.kotlin.gradle.dsl.KotlinJvmOptions
            kotlinOptions?.jvmTarget = JavaVersion.VERSION_17.toString()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
