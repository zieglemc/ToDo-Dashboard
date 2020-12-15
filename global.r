## Custom input control for a textbox that only sends its value
## when you hit Enter.
## See www/binding.js and http://shiny.rstudio.com/articles/building-inputs.html
commandInput <- function(inputId, ..., autoclear = TRUE) {
    tagList(
        tags$head(singleton(tags$script(src="binding.js"))),
        tags$input(id=inputId, type="text", class="command-text",
                   `data-autoclear` = autoclear,.noWS = 
                   ...)
    )
}

## some custom functions
readTodos <- function(fPath) {
    todos <- read.csv(file=fPath)
    return(todos)
}

writeTodos <- function(todos,fPath) {
    write.csv(todos,file=fPath,row.names=FALSE)
}

## some global variables
todoFilePath = "~/PROGRAMMING/Dashboards/ToDos/todos.txt"
