// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
import delimited "`directory'/data_processed/panel_tick_data"

// encode experimental session
encode playerinner_name, generate(exp_session)
// // Label variables
// // ---------------------------------
egen age_std=std(playerage)
gen d_gender=(playergender=="Female")
egen finquiz_std=std(playerpayoff)
egen finknowledge_std=std(playerknowledge)
egen capital_gains_std=std(capital_gains)
egen prediction_accuracy_std=std(prediction_accuracy)
egen filtered_prob_std=std(filtered_prob)

label variable gamified "Gamified"
label variable age_std "Age"
label variable d_gender "Gender (female)"
label variable finquiz_std "Financial quiz score"
label variable playertrading_experience "Trading experience"
label variable salient "Salient purchase price"
label variable playercourse_financial "Finance course taken"
label variable finknowledge_std "Self-assessed financial literacy"
label variable prediction_accuracy_std "Prediction accuracy"
label variable ingame_experience "In-game experience"
label variable accuracy_pred_zero "First-tick prediction"

// Define a list of controls
local controls salient age_std d_gender finquiz_std finknowledge_std playertrading_experience playercourse_financial prediction_accuracy_std
local controls2 salient age_std d_gender finquiz_std finknowledge_std playertrading_experience playercourse_financial

gen green_alert_game=green_alert * gamified
gen red_alert_game=red_alert * gamified


gen green_alert_salient=green_alert * salient
gen red_alert_salient=red_alert * salient

gen green_alert_gs=green_alert * salient * gamified
gen red_alert_gs=red_alert * salient *gamified

gen dsell=(position_delta==-1) // generate a sell dummy
gen dbuy=(position_delta==1) // generate a buy dummy

label variable green_alert "Green alert"
label variable red_alert "Red alert"
label variable green_alert_game "Green alert $\times$ gamified"
label variable red_alert_game "Red alert $\times$ gamified"
label variable filtered_prob_std "Good state probability"
label variable capital_gains_std "Capital gains"


reghdfe dbuy green_alert green_alert_game red_alert red_alert_game filtered_prob_std  gamified `controls' if playerinner_name =="s2" & position_lag==0, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_6.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe dsell green_alert green_alert_game red_alert red_alert_game filtered_prob_std capital_gains_std gamified if playerinner_name =="s2" & position_lag==1, absorb(participant_code round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe dbuy green_alert green_alert_game red_alert red_alert_game filtered_prob_std  gamified `controls2' if playerinner_name =="s2" & prediction_accuracy==1 & position_lag==0, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe dsell green_alert green_alert_game red_alert red_alert_game filtered_prob_std  capital_gains_std `controls2' gamified    if playerinner_name =="s2" & prediction_accuracy==1 & position_lag==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe dbuy green_alert green_alert_game red_alert red_alert_game filtered_prob_std  gamified `controls' if playerinner_name =="s2" & prediction_accuracy<1 & position_lag==0, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe dsell green_alert green_alert_game red_alert red_alert_game filtered_prob_std  capital_gains_std `controls' gamified    if playerinner_name =="s2" & prediction_accuracy<1 & position_lag==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)



// Interaction with S4

gen ds4=(playerinner_name=="s4")
gen green_alert_s4=green_alert*ds4
gen red_alert_s4=red_alert*ds4
gen green_alert_game_s4=green_alert_game*ds4
gen red_alert_game_s4=red_alert_game*ds4

gen ds2=(playerinner_name=="s2")
gen green_alert_s2=green_alert*ds2
gen red_alert_s2=red_alert*ds2
gen green_alert_game_s2=green_alert_game*ds2
gen red_alert_game_s2=red_alert_game*ds2

label variable green_alert_s2 "Green alert (Session II)"
label variable green_alert_s4 "Green alert (Session IV)"
label variable red_alert_s2 "Red alert (Session II)"
label variable red_alert_s4 "Red alert (Session IV)"
label variable green_alert_game_s4 "Green alert $\times$ gamified $\times$ Session IV"
label variable red_alert_game_s4 "Red alert $\times$ gamified $\times$ Session IV"
label variable green_alert_game_s2 "Green alert $\times$ gamified $\times$ Session II"
label variable red_alert_game_s2 "Red alert $\times$ gamified $\times$ Session II"


local interactions green_alert_s2 green_alert_s4 red_alert_s2 red_alert_s4 green_alert_game_s2 red_alert_game_s2 green_alert_game_s4 red_alert_game_s4 


reghdfe dbuy `interactions'  filtered_prob_std  gamified `controls' if ((playerinner_name =="s2") | (playerinner_name =="s4")) & position_lag==0, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F7.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe dsell `interactions' filtered_prob_std  capital_gains_std `controls' gamified    if ((playerinner_name =="s2") | (playerinner_name =="s4")) & position_lag==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe dbuy `interactions'  filtered_prob_std  gamified `controls2' if ((playerinner_name =="s2") | (playerinner_name =="s4")) & position_lag==0 & prediction_accuracy==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe dsell `interactions' filtered_prob_std  capital_gains_std `controls2' gamified    if ((playerinner_name =="s2") | (playerinner_name =="s4")) & position_lag==1 & prediction_accuracy==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe dbuy `interactions'  filtered_prob_std  gamified `controls' if ((playerinner_name =="s2") | (playerinner_name =="s4")) & position_lag==0 & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe dsell `interactions' filtered_prob_std  capital_gains_std `controls' gamified    if ((playerinner_name =="s2") | (playerinner_name =="s4")) & position_lag==1 & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
