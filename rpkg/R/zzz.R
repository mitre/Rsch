.onLoad <- function(libname, pkgname) {
  j_home <-Sys.getenv("JAVA_HOME")
  if (j_home!="")
    Sys.setenv(JAVA_HOME="")

  require(rJava)
  .jpackage(name = pkgname, jars = "*")

  e <- new.env()
  assign("pkg_globals", e, envir=parent.env(environment()))
  assign("j_home", j_home, envir=e)
}

#' get things set up for interfacing with Jsch
#'
#'
#' @author Seth Wenchel
#' @import rJava
initializeRsch <- function() {
  # start JVM and point to apamatlab jar
  path2jar <- file.path(find.package("Rsch"), "java", "Rsch-0.0.1.jar")
  .jinit(path2jar)

}

.onUnload<-function(libpath){
  j_home <- get("j_home",pkg_globals)
  Sys.setenv(JAVA_HOME=j_home)
}

