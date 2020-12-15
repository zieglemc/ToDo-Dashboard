shinyServer(function(input, output, session) {

    todos <- reactiveValues(data=data.frame(task=c(),done=c()))
    prevTodos = readTodos(todoFilePath)
    numTodos <- length(prevTodos)
    todos$data <- prevTodos
    ## This observer handles the creation of new tasks
    observe({
        ## The only reactive it depends on is input$newtask.
        ## (Other reactive todos are accessed, but only in
        ## the isolate() block, so the observer won't run
        ## automatically when those change.)
        newtask <- input$newtask
        if (is.null(newtask)) return()  ## No command entered yet
        isolate({
            print(todos$data)
            ## Add the new task and the fact that it's not done
            todos$data <-rbind(todos$data,data.frame(task=newtask,done=FALSE))
            numTodos <- length(todos$data$task)
        })
    })

    ## The renderUI block down below will make a new
    ## row with new done_x and task_x inputs. Make new
    ## observers to monitor each of those so we can write
    ## changes in those todos to our lists.
    observeEvent(input[[sprintf("done_%s", numTodos)]],{
        isDone <- input[[sprintf("done_%s", numTodos)]]
        if (is.null(isDone)) return()  ## The done_x input wasn't created yet
        ## The done value changed. Update todos$done.
        ## Note that we have to read todos$done in an
        ## isolate block, otherwise it will cause an endless
        ## cycle.
        isolate({
            done <- todos$data$done
            done[[numTodos]] <- isDone
            todos$data$done <- done
        })
    })

    observe({
        task <- input[[sprintf("task_%s", numTodos)]]
        if (is.null(task)) return()  ## The task_x input wasn't created yet

        ## The task name changed. Update todos$tasks.
        ## Note that we have to read todos$tasks in an
        ## isolate block, otherwise it will cause an endless
        ## cycle.
        isolate({
            tasks <- todos$data$task
            tasks[[numTodos]] <- task
            todos$data$task <- tasks
        })
    })



    ## Render a message indicating ## of active tasks
    output$count <- renderUI({
        count <- length(which(!todos$data$done))
        tags$p(
                 tags$strong(count),
                 if (count == 1) "item" else "items",
                 "left"
             )
    })

    ## Render the list of tasks as a table
    output$tasks <- renderUI({
        if (length(todos$data$done) == 0)  return()

        allowed <- switch(input$filter,
                          "All" = c(TRUE, FALSE),
                          "Active" = FALSE,
                          "Completed" = TRUE
                          )

        isolate({
            tags$table(
                     lapply(1:length(todos$data$done), function(i) {
                         ## Don't show if it doesn't pass the filter
                         if (!(todos$data$done[[i]] %in% allowed)) return()

                         ## Render the row. Each row contains two inputs, so
                         ## that the user can modify the done state and task
                         ## name.
                         tags$tr(
                                  tags$td(
                                           checkboxInput(sprintf("done_%s", i), NULL,
                                                         value = todos$data$done[[i]])
                                       ),
                                  tags$td(
                                           textInput(sprintf("task_%s", i), NULL,
                                                     value = todos$data$task[[i]])
                                       )
                              )
                     })
                 )
        })
    })

    ## write the current todos to a file on exit
    onStop(function(){
        isolate({
            writeTodos(todos$data,todoFilePath)
        })
    })
})
