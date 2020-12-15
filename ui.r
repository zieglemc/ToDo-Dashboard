shinyUI(dashboardPage(
    dashboardHeader(title="Todo-Liste"),
    dashboardSidebar(),
    dashboardBody(
        commandInput("newtask", placeholder = "Hier das ToDo eintragen...",width=400),
        uiOutput("tasks"),
        uiOutput("count"),
        radioButtons("filter", NULL, c("All", "Active", "Completed"),
                     selected = "All"
                     ),
        actionButton("clear", "Clear completed")
    )
))
