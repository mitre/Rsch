#' Connect to a remote server
#'
#'
#' @param host the name of the remote system
#' @param user a string for the username on the remote system.  The default is to use the same name as the current user.
#' @param password the password for the user on the remote system
#' @param port this is usually 22 for ssh connections
#'
#' @importFrom credentials get_credentials
#' @return an object of class Rsch_connection
#'
#' @examples
#' \dontrun{
#' connection <- get_connection(host = "cuckoo.lbnl.gov", user = "cliff", password = "TopSecret")
#' }
#' @export
get_connection <- function( host, user = credentials::guess_user(), password, port = 22){
  # if host contains @, check for : before @. if : split and set both password and user, else just set usr
  # if password is unset prompt user
  # check if host contains a port number at the end
  # rewrite host to be just the server name/ip address
  # rough java:
  # Jsch rsch = new Jsch()
  # Session session = rsch.getSession(user, host, port)
  # session.setPassword(password)
  # session.connecy
  # END JAVA
  # return(session)

  initializeRsch()

  glue <- .jnew("org.mitre.caasd.rsch.Glue")  ## call the constructor
  #setVar("glue", glue)

  if (missing(password)) {
    credentials <- get_credentials(prompt=paste("Enter Credentials for", host),
                                   username=user, toggle_cache=FALSE)
    user <- credentials$username
    password <- credentials$password
  }

  connection <- .jcall(glue, "Lcom/jcraft/jsch/Session;",method="getSession", user, password, host, as.character(port))

  foo <- structure(list(glue = glue,
                        connection = connection,
                        host = host,
                        port = port,
                        user = user), class="Rsch_connection")
  return(foo)
}

#' Run remote commands
#'
#' @param connection a connection object as returned by \code{\link{get_connection}}
#' @param command a valid command for the remote system's shell environment
#' @examples
#' \dontrun{
#' connection <- get_connection(host = "some.remote.system", user = "you")
#' execute(connection, "ps -ef | grep R /*")
#' }
#' @export
execute <- function(connection, command){
  # ROUGH JAVA:
  # Channel channel=session.openChannel("exec");
  # ((ChannelExec)channel).setCommand(command);
  # channel.setInputStream(null)
  # ((ChannelExec)channel).setErrStream(System.err);
  # InputStream in=channel.getInputStream();
  # channel.connect()
  # // read back stuff spewing from server
  # channel.close()

  .jcall(connection$glue, returnSig = "V",method="sendCommand", connection$connection, command)
}

#' Read back from the remote system
#'
#' This function returns a vector of strings that is the entire output of the remote system since
#' the last call to \code{\link{execute}}
#' @param connection An Rsch_connection object
#' @param split passed on to \code{\link[base]{strsplit}} UNLESS the value is \code{NA}
#' in which case a single string will be returned.  The default is \code{\\n}
#'
#' @return generally a vector of strings representing the console output resulting from the last
#' command issued to \code{\link{execute}}.
#'
#' @examples
#' \dontrun{
#' connection <- get_connection(host = "cuckoo.lbnl.gov", user = "cliff", password = "TopSecret")
#' execute(connection,"grep \"nuclear\" /*")
#' results <- printout(connection)
#'
#' }
#' @export
printout <- function(connection, split="\n"){
  if(is.na(split))
   return(.jcall(connection$glue, returnSig = "S", method = "printout"))
  unlist(strsplit(.jcall(connection$glue, returnSig = "S", method="printout"), split = split))
}

#' Closes the remote connection
#'
#' @param connection an Rsch_connection object
#'  @examples
#' \dontrun{
#' connection <- get_connection(host = "cuckoo.lbnl.gov", user = "cliff", password = "TopSecret")
#' execute(connection,"grep \"nuclear\" /*")
#' results <- printout(connection)
#' goodbye(connection)
#' }
#' @export
goodbye<-function(connection){
  .jcall(connection$glue, returnSig = "V",method="goodbye")
}

#' Print properties of an Rsch_connection object
#'
#' @param  x an Rsch_connection object
#' @param ... currently ignored
#' @export
print.Rsch_connection <- function(x,...){
  print(paste0("host: ", x$host))
  print(paste0( "port: ",x$port))
  print(paste0( "user: ", x$user))
}

#' Reconnect after calling \code{\link{goodbye}}
#'
#' @param connection and Rsch_connection object
#' @param password the password associated with the account in the Rsch_connection object
#' @return an Rsch_connection object
#'  @examples
#' \dontrun{
#' connection <- get_connection(host = "cuckoo.lbnl.gov", user = "cliff", password = "TopSecret")
#' execute(connection,"grep \"nuclear\" /*")
#' results <- printout(connection)
#' goodbye(connection)
#'
#' connection <- reconnect(connection, "TopSecret")
#' execute(connection,"grep \"SDI\" /*")
#'
#' }
#' @export
reconnect <- function(connection, password){
  return(get_connection(connect$host, connection$user, password, connect$port))
}
