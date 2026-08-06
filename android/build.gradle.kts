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

// 强制所有 Android 子模块（含 audioplayers_android 等插件）compileSdk=36，
// 否则 checkReleaseAarMetadata 因插件自带 compileSdk=33 依赖需 >=34 而失败。
gradle.projectsEvaluated {
    rootProject.allprojects {
        if (project.path == ":audioplayers_android") return@allprojects
        val android = extensions.findByName("android") ?: return@allprojects
        try {
            val a = android as Any
            val cls = a.javaClass
            val m = cls.methods.firstOrNull { it.name == "setCompileSdk" && it.parameterCount == 1 }
            if (m != null) {
                m.invoke(a, 36)
            }
        } catch (_: Throwable) {
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
