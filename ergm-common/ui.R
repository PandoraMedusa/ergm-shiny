#' ---
#' title: "ergm-common, ui.R"
#' author: "Emily Beylerian"
#' ---
#' ergm-common
#' ============
#' ui.R
#' =========

#' **Before reading this document:** The Shiny app "ergm-common" is not contained in a
#' single R Script. Within the folder "ergm-common" the script `ui.R` controls the 
#' layout and appearance of the app, the script `server.R` controls the content that
#' gets displayed in the app, and the folder "www" contains auxiliary files (javascript,
#' css, and image files). If you are unfamiliar with Shiny apps, it may be more 
#' natural and helpful to start with the documentation for `ui.R` and then move on to
#' `server.R`.
#' 
#' **Basics**
#' 
#' The R functions inside `ui.R` output HTML code, which Shiny turns into a webapp. 
#' Widgets specific functions in Shiny that correspond to elements of the UI that the
#' user can interact with to influence the content that the app produces (see widget
#' examples in the [gallery](http://shiny.rstudio.com/gallery/) ). Some common HTML tags 
#' (e.g. `h1`,`p` and `a` below) have built-in functions in Shiny, many others are 
#' included in the `tags` object (see all the `tags` 
#' [here](http://shiny.rstudio.com/articles/tag-glossary.html)). 
#' It is also possible to write the entire UI 
#' [directly in HTML](http://shiny.rstudio.com/articles/html-ui.html).
#' 
#' Since the `server.R` script generates all the dynamic content of the app,
#' if the script only contains an empty function in the call to the Shiny server, 
#' e.g.
#' ```
#' shinyServer(
#'  function(input,output){})
#' ```
#' then all the UI elements will still be displayed statically without any content.
#' 
#' In a functioning app, `server.R` takes input objects and reactively (because the user
#' might change an input object) creates output objects. In order to display the output
#' object in the interface so the user can see it, it must be called with an appropriate
#' output function (`plotOutput`, `textOuput`, `verbatimTextOutput`, etc.) back in `ui.R`. 
#' 
#' **Code**
#' 
#' The function `customTextInput` is a manipulation of the `textInput` widget
#' that allows for smaller input boxes. In addition to all the normal arguments passed
#' to `textInput`, `class = "input-small"` or `class = "input-mini"` can be specified.
#' 
#+ setup, eval=FALSE
#load necessary packages
library(shiny)
library(statnet)

customTextInput<-function (inputId, label, value="",...) {
  tagList(tags$label(label, `for` = inputId), tags$input(id = inputId,
                                                         type="text",
                                                         value=value,...))
}



#' Everything that gets displayed inside the app is enclosed in a call to `shinyUI`.
#' The first thing to be specified is the type of page to display. The `navbarPage` 
#' includes a navigation bar at the top of the page and each tab leads to different 
#' pages of content. Find out more about layout options 
#' [here](http://shiny.rstudio.com/articles/layout-guide.html).
#' 
#'
#+ eval=FALSE 
shinyUI(
  bootstrapPage(title='statnet - ergm app',
  navbarPage(title=p(a(span('statnet  ', style='font-family:Courier'),
                            href = 'https://statnet.csde.washington.edu/trac',
                            target = '_blank'), 'ergm app'),
#' Within each panel of the navbar, the content can be arranged by nesting rows and
#' columns. The first argument to `column` is the desired width, where the whole
#' browser window has a width of 12. Within any column, nested columns set their 
#' width relative to the parent column. Rows are specified by enclosing elements
#' in `fluidRow()`. It is often necessary to specify rows even when elements seem like
#' they should naturally be aligned horizontally, or when a `wellPanel` that is supposed
#' to hold some content doesn't quite enclose everything correctly.
#' 
#' **Plot Network**
#' 
#' In the "Plot Network" tab panel, the first call to `column` contains all of the 
#' elements on the left side of the page (datasets, network summary and logos). In the 
#' middle of the page is the network plot followed by display options. Notice that 
#' there are no calls to `selectInput` for the options to color code or size the nodes,
#' even though they appear in the app. Most widget functions are called in `ui.R`, but
#' this means that all the options passed to them must be static. If the options depend
#' on user input (the coloring and sizing menus depend on which network the user
#' selects), the widget must be rendered in `server.R` and output in `ui.R` with 
#' `iuOutput`.
#'
#' 
#' 
#+ eval=FALSE
  tabPanel('Plot Network',
    fluidRow(
     column(3,
          wellPanel(
            h5('Choose a dataset'),
            selectInput('dataset',
                         label = 'Sample datasets',
                         c(Choose = '', 'ecoli1', 'ecoli2', 'faux.magnolia.high',
                           'faux.mesa.high', 'flobusiness','flomarriage',
                           'kapferer','kapferer2','samplike'),
                         selectize = FALSE),
                           br(),
                           actionButton('goButton', 'Run')),
      h5('Network Summary'),
      verbatimTextOutput('attr'),
      fluidRow(
        
        column(10, img(src= 'UW.Wordmark_ctr_K.jpg'))
      ),
      fluidRow(
        column(3, a(img(src = 'csdelogo_crop.png', height = 50, width = 50),
                    href = 'https://csde.washington.edu/', target = '_blank')),
        column(7, a(img(src = 'csde_goudy.fw.png'), href = 'https://csde.washington.edu/',
                    target = '_blank'))
        )
      ),
                  
     column(8, 
            plotOutput('nwplot'),
             wellPanel(
               fluidRow(h5('Display Options')),
               fluidRow(column(3,
                               checkboxInput('iso',
                                             label = 'Display isolates?', 
                                             value = TRUE),
                               checkboxInput('vnames',
                                             label = 'Display vertex names?',
                                             value = FALSE)),
                        column(3,
                               uiOutput('dynamiccolor')),
                        column(3,
                               uiOutput('dynamicsize')))))
      )
    ),
#' **Fit Model**
#' 
#' Since model fitting does not happen instantly, a loading icon will help to assure 
#' users that the app is still working on producing output. The following code chunk
#' uses the files `busy.js`, `style.css` and `ajax-loader.gif` located in the directory
#' `ergm-common/www` to create a loading message. To display the loading message on
#' subsequent tabs, we only need to include the `div` statement on those tabs.
#' 
#+ eval=FALSE                  
      tabPanel('Fit Model',
          #code to include progress bar when this tab is loading
          tagList(
            tags$head(
              tags$link(rel="stylesheet", type="text/css",href="style.css"),
              tags$script(type="text/javascript", src = "busy.js")
            )
          ),
           div(class = "busy", 
               p("Calculation in progress..."),
               img(src="ajax-loader.gif")
           ),  
          
#' Conditional panels only exist if the javascript expression passed to the condition
#' argument is true. If the expression is false, nothing inside `conditionalPanel()` 
#' will appear in the app, nor will it take up space in the interface. In this tab, each
#' conditional panel contains a menu of options for one of the ergm terms. There is no
#' javascript function analagous to `is.element` in R, but the JS `indexOf` will return
#' -1 if an element is not within the specified list. 
#' 
#+ eval=FALSE                                          
          fluidRow(
            column(2,
               p('Current network:', verbatimTextOutput('currentdataset1'))),
            column(10,
               p('Current ergm formula:'),
               verbatimTextOutput('checkterms1'))
          ),
         fluidRow(
           column(10, offset=2,
                  p('Summary Statistics:'),
                  verbatimTextOutput('prefitsum'))
           ),
         fluidRow(
           column(3,
                  uiOutput('listofterms'),
                  actionButton('fitButton', 'Fit Model')),
           conditionalPanel(condition = 'input.terms.indexOf("absdiff") > -1',
                            column(2,
                                   uiOutput('dynamicabsdiff'),
                                   customTextInput('absdiff.choosepow',
                                                   label = 'pow = ',
                                                   value = '1', class='input-small')
                                   )),
           conditionalPanel(condition = 'input.terms.indexOf("degree") > -1',
                            column(2,
                                   uiOutput('dynamicdegree'),
                                   customTextInput('choosedegree2',
                                                   label = 'OR, input your own',
                                                   value = NULL, class='input-small',
                                                   helpText("If entered, custom user",
                                                            "input will be prioritized"))
                                   )),
           conditionalPanel(condition = 'input.terms.indexOf("b1degree") > -1',
                            column(2,
                                   uiOutput('dynamicb1degree'),
                                   customTextInput('chooseb1degree2',
                                                   label = 'OR, input your own',
                                                   value = NULL, class='input-small',
                                                   helpText("If entered, custom user",
                                                            "input will be prioritized"))
                            )),
           conditionalPanel(condition = 'input.terms.indexOf("b2degree") > -1',
                            column(2,
                                   uiOutput('dynamicb2degree'),
                                   customTextInput('chooseb2degree2',
                                                   label = 'OR, input your own',
                                                   value = NULL, class='input-small',
                                                   helpText("If entered, custom user",
                                                            "input will be prioritized"))
                            )),
           conditionalPanel(condition = 'input.terms.indexOf("idegree") > -1',
                            column(2,
                                   uiOutput('dynamicidegree'),
                                   customTextInput('chooseidegree2',
                                                   label = 'OR, input your own',
                                                   value = NULL, class='input-small',
                                                   helpText("If entered, custom user",
                                                            "input will be prioritized")))),
           conditionalPanel(condition = 'input.terms.indexOf("odegree") > -1',
                            column(2,
                                   uiOutput('dynamicodegree'),
                                   customTextInput('chooseodegree2',
                                                   label = 'OR, input your own',
                                                   value = NULL, class='input-small',
                                                   helpText("If entered, custom user",
                                                            "input will be prioritized")))),
           conditionalPanel(condition = 'input.terms.indexOf("gwesp") > -1', 
                            column(2,
                                   customTextInput('choosegwesp', 
                                                   label = 'Input alpha for gwesp',
                                                   value = 0, class='input-small'),
                                   checkboxInput('fixgwesp', label = 'fixed?', 
                                                 value = TRUE))),
           conditionalPanel(condition = 'input.terms.indexOf("nodecov") > -1',
                            column(2,
                                   uiOutput('dynamicnodecov')
                                   )),
           conditionalPanel(condition = 'input.terms.indexOf("nodefactor") > -1',
                            column(2,
                                   uiOutput('dynamicnodefactor'),
                                   customTextInput('nodefactor.choosebase',
                                                   label = 'base = ',
                                                   value = '1', class='input-small')
                                   )),
           conditionalPanel(condition = 'input.terms.indexOf("nodematch") > -1',
                            column(2,
                                   uiOutput('dynamicnodematch'),
                                   customTextInput('nodematchkeep', label = 'keep = ',
                                                   value = '', class='input-small'),
                                   checkboxInput('nodematchdiff', label='diff',
                                                 value = FALSE))),
           conditionalPanel(condition = 'input.terms.indexOf("nodemix") > -1',
                            column(2,
                                   uiOutput('dynamicnodemix'),
                                   customTextInput('nodemix.choosebase',
                                                   label = 'base = ',
                                                   value = '', class='input-small')
                                   ))
           
         ),
         
         
         br(),
         tags$hr(),
         h4('Model Summary'),
         p('Check for model degeneracy in the "Diagnostics" tab.'),
         br(),
         tabsetPanel(
           tabPanel('Fitting',
                    verbatimTextOutput('modelfit')),
           tabPanel('Summary',
                    verbatimTextOutput('modelfitsum'))
          )
          ),
#' **Goodness of Fit**
#' 
#+ eval=FALSE   
         navbarMenu('Diagnostics',
            tabPanel('Goodness of Fit',
                     
                     #include progress bar when this tab is loading
                     div(class = "busy", 
                         p("Calculation in progress..."),
                         img(src="ajax-loader.gif")
                     ),  
                     
                     fluidRow(
                       column(2,
                              p('Current network:', verbatimTextOutput('currentdataset2'))),
                       column(10,
                              p('Current ergm formula:',
                                verbatimTextOutput('checkterms2')))
                      ),     
                     fluidRow(
                       column(3, selectInput('gofterm', 'Goodness of Fit Term:',
                                             c(Default='', 'degree', 'distance', 'espartners', 
                                               'dspartners', 'triadcensus', 'model'),
                                             selectize = FALSE))),
                     fluidRow(
                        column(3, actionButton('gofButton', 'Run'))),
                     br(),
                     tags$hr(),
                     p('Test how well your model fits the original data by choosing 
                       a network statistic that is not in the model, and comparing 
                       the value of this statistic observed in the original network 
                       to the distribution of values you get in simulated networks from 
                       your model.'),
                     p('If you do not specify a term the default formula for undirected 
                       networks is ', code('~ degree + espartners + distance'), 'and for 
                       directed networks is ', code('~ idegree + odegree + espartners + 
                                                    distance'), '.'),
                     fluidRow(
                     column(5,
                            verbatimTextOutput('gof.summary')),  
                     column(7,
                            uiOutput('gofplotspace')))
                     ),
#' **MCMC Diagnostics**
#' 
#+ eval=FALSE            
            tabPanel('MCMC Diagnostics',
  #include progress bar when this tab is loading
                    div(class = "busy", 
                        p("Calculation in progress..."),
                        img(src="ajax-loader.gif")
                    ),
                     
                     fluidRow(
                       column(2,
                              p('Current network:', verbatimTextOutput('currentdataset3'))),
                       column(10,
                              p('Current ergm formula:',
                                verbatimTextOutput('checkterms3')))
                     ),     
                     br(),
                     tags$hr(),
                     tabsetPanel(
                       tabPanel('Plot',   
                        plotOutput('diagnosticsplot', height = 600)),
                       tabPanel('Summary', 
                        verbatimTextOutput('diagnostics'))
                     )
            )
            ),
#' **Simulations**
#' 
#+ eval=FALSE  
          tabPanel('Simulations',
                   fluidRow(
                     column(2,
                            p('Current network:', verbatimTextOutput('currentdataset4'))),
                     column(10,
                            p('Current ergm formula:',
                              verbatimTextOutput('checkterms4')))
                   ),
                   br(),
                   tags$hr(),
                   
                   fluidRow(
                     column(3,
                            numericInput('nsims',
                                         label = 'Number of simulations:',
                                         min = 1,
                                         value = 1)      
                     ),
                     column(8, 
                            numericInput('this.sim',
                                        label = 'Choose a simulation to plot',
                                        min = 1,
                                        value = 1)
                            )
                   ),
                   fluidRow( 
                     column(3,
                            actionButton('simButton', 'Simulate'),
                            br(),
                            br(),
                            verbatimTextOutput('sim.summary')
                            ),  
                     column(8,
                            plotOutput('simplot'),
                            
                            
                            wellPanel(
                              fluidRow(h5('Display Options')),
                              fluidRow(column(3,
                                checkboxInput('iso2',
                                              label = 'Display isolates?', 
                                              value = TRUE),
                                checkboxInput('vnames2',
                                              label = 'Display vertex names?',
                                              value = FALSE)),
                              column(3,
                                uiOutput('dynamiccolor2')),
                              column(3,
                                uiOutput('dynamicsize2')))
                              )
                            )
                     )
                   ),
#' **Help**
#' 
#+ eval=FALSE  
  tabPanel('Help',
           h4('Resources'),
           a("statnet Wiki",
             href = "https://statnet.csde.washington.edu/trac", target = "_blank"),
           br(),
           a("ergm: Journal of Statistical Software",
             href = "http://www.jstatsoft.org/v24/i03/", target = "_blank"),
           br(),
           a("Using ergm: Journal of Statistical Software",
             href = "http://www.jstatsoft.org/v24/i04/", target = "_blank"),
           br(),
           a("ergm documentation on CRAN", 
             href = "http://cran.r-project.org/web/packages/ergm/ergm.pdf",
             target = "_blank"),
           br(),
           hr(),
           p("The best way to contact us with questions, comments or suggestions",
             "is through the", strong("statnet users group"), "listserv."),
           p("To post and receive messages from this listserv, you need to join.",
             "Instructions are at:", 
             a("https://mailman.u.washington.edu/mailman/listinfo/statnet_help",
               href = "https://mailman.u.washington.edu/mailman/listinfo/statnet_help",
               target = "_blank")),
           p("You can use the listserv to:"),
           tags$ul(
             tags$li("get help from the statnet development team (and other users)"),
             tags$li("post questions, comments and ideas to other users"),
             tags$li("be informed about statnet updates"),
             tags$li("learn about bugs (and bug fixes)")
             ),
           p("Once you have joined the list, you can post your questions and comments to",
             strong("statnet_help@u.washington.edu")),
           p("A full list of all messages posted to this list is available at",
             a("https://mailman.u.washington.edu/mailman/private/statnet_help",
               href = "https://mailman.u.washington.edu/mailman/private/statnet_help",
               target = "_blank")),
           br(),
           hr(),
           p("This web app is built with", a("Shiny",href="http://shiny.rstudio.com/",
                                             target = "_blank")),
           p("Author of app: Emily Beylerian, University of Washington")
           )
                  
    
    ))
  )
    