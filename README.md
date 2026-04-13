# Development
This is a draft version of Aurora, currently under development. We are planning to submit Aurora for publication in the Journal of Open Source Software.

# Summary
‘Aurora’ is a free, open-source laboratory information management system (LIMS), which operates as an R Shiny web application using R and RStudio. Aurora is intended to simplify the tracking and management of biological samples. It is designed to accommodate a very broad range of sample types, although many features focus on genetic samples. Since Aurora uses a small number of clearly annotated R scripts, users with modest knowledge of the R language can easily customise the application. Aurora uses a relational database approach, where all data are linked to a primary key: the sample accession. Data are saved in RDS files and the application includes many automatic steps for data formatting and backing up. Within the application’s graphical user interface, users can search, edit and export data. Under typical usage, users use the Upload tab in Aurora to import new data from a Microsoft Excel file (aurora_queue.xlsx). It is easy to filter data within Aurora, and the application can generate interactive tables, figures and reports for exploring data. Aurora comes with example data and the launch page answers many frequently asked questions. Aurora is necessary, as most LIMS are subscription-based, proprietary software that are challenging to customise and often unwieldy for the wide diversity of sample types and tests found in most biological research laboratories.

# Credit / Contributions
Aurora was developed by Grant Abernethy and Felix Zareie-Vaux.

# AI usage disclosure
Generative artificial intelligence chatbots, Google Gemini 3 Flash and OpenAI ChatGPT-5.3, were used assist with R code generation, editing and annotation. All authors have reviewed, edited and validated these AI-assisted outputs and made the core design decisions.
