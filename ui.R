library(shiny)
library(plotly)

shinyUI(fluidPage(
  tags$style(
    type='text/css', 
    ".selectize-input { font-family: Courier New, monospace; } .selectize-dropdown { font-family: Courier New, monospace; }"
  ),
  tags$style(HTML(
    "body { font-family: Courier New, monospace; line-height: 1.1; }"
  )),
  
  titlePanel("Case History of the Coronavirus (COVID-19) in Wiltshire"),
  fluidRow(
    plotlyOutput("dailyMetrics")
  ),
  fluidRow(
    plotlyOutput("cumulatedMetrics")
  )
))

renderBarPlot = function(varPrefix, legendPrefix, yaxisTitle) {
  renderPlotly({
    data = data()
    plt = data %>% 
      plot_ly() %>%
      config(displayModeBar=FALSE) %>%
      layout(
        barmode='group', 
        xaxis=list(
          title="", tickangle=-90, type='category', 
          ticktext=as.list(data$dateStr), 
          tickvals=as.list(data$date)), 
        yaxis=list(title=yaxisTitle),
        legend=list(x=0.1, y=0.9,bgcolor='rgba(240,240,240,0.5)'),
        font=f1
      )
    for(metric in input$metrics) 
      plt = plt %>%
      add_trace(
        x=~date, y=data[[paste0(varPrefix, metric)]],type='bar', 
        name=paste(legendPrefix, metric, "Cases"),
        marker=list(
          color=switch(metric, 
                       Confirmed='rgb(96,161,76)'),
          line=list(color='rgb(8,48,107)', width=1.0)
        )
      )
    plt
  })
}

output$dailyMetrics = renderBarPlot(
  "New", legendPrefix="New", yaxisTitle="New Cases per Day")
output$cumulatedMetrics = renderBarPlot(
  "Cum", legendPrefix="Cumulated", yaxisTitle="Cumulated Cases")