allprojects {
    repositories {
        maven ("https://maven.aliyun.com/repository/public/" )
        maven ("https://maven.aliyun.com/repository/spring/")
        maven ("https://maven.aliyun.com/repository/google/")
        maven ("https://maven.aliyun.com/repository/gradle-plugin/")
        maven ("https://maven.aliyun.com/repository/spring-plugin/")
        maven ("https://maven.aliyun.com/repository/grails-core/")
        maven ("https://maven.aliyun.com/repository/apache-snapshots/")
        maven ("https://maven.aliyun.com/repository/jcenter" )
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

