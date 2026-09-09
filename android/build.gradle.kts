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

// Different plugins ship with different hardcoded Java/Kotlin JVM targets
// (flutter_timezone wanted 11, image_picker_android wants 17, ...), and
// Gradle now hard-errors on any mismatch within one module ("Inconsistent
// JVM Target Compatibility"). Force every subproject to the same target
// (17 — required anyway by current AGP/Java tooling).
subprojects {
    // Kotlin task configuration is lazy (configureEach runs whenever the
    // task is actually configured), so this alone reliably wins last.
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    // compileOptions is a plain property set during script evaluation, so a
    // plugin's own build.gradle can still overwrite it after this block —
    // reapply once evaluation finishes. :app is forced to evaluate early
    // (see evaluationDependsOn above), so guard against double-evaluation.
    fun applyCompileOptions() {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
    }
    if (state.executed) applyCompileOptions() else afterEvaluate { applyCompileOptions() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
