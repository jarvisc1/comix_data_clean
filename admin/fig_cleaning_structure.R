library(magrittr)
library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

gph <- DiagrammeR::grViz("digraph G {
compound=true
graph [layout = dot, rankdir = LR]

dm1 [label =  'dm01.R\n Save as QS ', shape= rectangle]
dm2 [label =  'dm02.R\n Add cnty, panel, wave', shape= rectangle]
dm3 [label =  'dm03.R\n Turn to datatable', shape= rectangle]
dm4 [label =  'dm04.R\n Change names', shape= rectangle]
dm5 [label =  'dm05.R\n Combine data' , shape= rectangle]

dt_input [label = 'SPSS Dataset']
dt1 [label =  'data_1.qs ']
dt2 [label =  'data_2.qs' ]
dt3 [label =  'data_3.qs' ]
dt4 [label =  'data_4.qs']
dt5 [label =  'dirty_combined_5.qs' ]


	subgraph cluster0 {
		style=filled;
		color=lightgrey;
		node [style=filled,color=white];
	   dm1 -> dm2 -> dm3 -> dm4 -> dm5;
		label = 'Scripts';
	}
	subgraph cluster1 {
		node [style=filled];
	  dt1 -> dt2 -> dt3 -> dt4 -> dt5 ;
		label = 'Data';
		color=blue
	}

	dm1 -> dt1 [ltail=cluster_0];
	dm2 -> dt2 [ltail=cluster_0];
	dm3 -> dt3 [ltail=cluster_0];
	dm4 -> dt4 [ltail=cluster_0];
	dm5 -> dt5 [ltail=cluster_0];
	dt1 -> dm2 [ltail=cluster_0];
	dt2 -> dm3 [ltail=cluster_0];
	dt3 -> dm4 [ltail=cluster_0];
	dt4 -> dm5 [ltail=cluster_0];
	dt_input -> dm1
	dt_input -> dt1
}")


gph %>%
  export_svg() %>%
  charToRaw %>% 
  rsvg_png(file = "./admin/cleaning_structure.pdf", width = 25, height = 10)


## Can be removed was trying to put in data naming convention as well.
# data[ label = 'Data is saved as cnty_wkN_yyyymmdd_pN_wvN_N.qs\n
#                cnty = country\n
#                wkN = week number\n
#                yyymmdd = date data received\n
#                pN = panel number\n
#                wvN = wave number\n
#                N = date cleaning step\n
#               ', shape = rectangle]