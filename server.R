#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)

source('./scripts/tab-industries.R')
source('./scripts/tab-influenza.R')
source('./scripts/tab-public-transportation.R')
source('./scripts/tab-housing.R')

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$industry_split <- renderPlotly({
    get_split_proportion_industry_plot(num_rank = input$industry_split_num_rank,
                                       sector_filter = input$industry_split_sector,
                                       plot_interactive = T)
  })
  
  industry_rank_proportion_df <- reactive({
    get_rank_proportion_industry_df(df = industry_full_data,
                                    num_top_rank = input$industry_rank_num_top,
                                    num_bot_rank = input$industry_rank_num_bot,
                                    sector_filter = input$industry_rank_split_sector)
  })
  
  output$industry_rank_viz <- renderPlotly({
    industry_rank_proportion_df() %>% 
      get_rank_proportion_industry_plot(plot_interactive = T)
  })
  
  output$industry_rank_table <- renderTable({
    industry_rank_proportion_df() %>% 
      get_rank_proportion_industry_diff_table(diff_threshold = input$industry_rank_diff_thresh / 100)
  })
  
  output$industry_covid19_prev_dist_viz <- renderPlot({
    get_covid19_prevalence_dist_industry()
  })

  transportationInput <- reactive({
    if ( "Public Transportation" %in% input$transportation_metric) return(public_transportation_viz)
    if ( "Drive" %in% input$transportation_metric) return(drive_viz)
  })
  
  output$transportation <- renderPlotly({   
    trans_viz = transportationInput()
    trans_viz <- ggplotly(trans_viz)
    return(trans_viz)
  }) 
  
  output$drive <- renderPlot({
    drive_viz
  })
  
  output$Borough <- renderPlot({
    borough_graph
  })
  
  output$nyc_covid <- renderPlot({
    nyc_mapping
  })
  
  output$influenza_covid_scatterplot <- renderPlot({
    influenza_v_covid_scatterplot
  })
  
  output$influenza_covid_table <- renderTable({
    borough_case_contributions
  })
  
  
  #--- housing
  housingInput <- reactive({
    if ( "Percentage of COVID tests that were positive" %in% input$select_covid_metric) return(viz_housing_unit_covidpos_hov)
    if ( "Cumulative hospitalizations due to COVID-19" %in% input$select_covid_metric) return(viz_housing_unit_covidhos_hov)
    if( "Percentage of deaths due to COVID" %in% input$select_covid_metric) return(viz_housing_unit_coviddeath_hov) 
  })
  
  output$viz_housing_unit <- renderPlotly({
    housingViz = housingInput()
    print(housingViz)
  })
  
  output$viz_housing_crowded <- renderPlotly({
    viz_house_crowded
    print(viz_house_crowded)
  })

})




