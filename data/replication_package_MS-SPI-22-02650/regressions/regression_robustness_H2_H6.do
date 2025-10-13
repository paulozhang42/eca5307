// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
import delimited "`directory'/data_processed/self_reflection"

egen age_std=std(playerage)
gen d_gender=(playergender=="Female")
egen finquiz_std=std(playerpayoff)
egen finknowledge_std=std(playerknowledge)
gen prefer_gamified=(playersr_prefs=="Design 2")
gen better_gamified=(playersr_better_decs=="Design 2")
gen diff_payoff_pct=10000*(profit_gamified-profit_nongamified)/profit_nongamified
egen diff_payoff=std(diff_payoff_pct)
gen option_value=(playersr_better_have_option=="Have an option between Design #1 and Design #2,")

gen d_knowledge = (finknowledge_std >0)

label variable finquiz_std "Financial quiz score"
label variable age_std "Age"
label variable d_gender "Gender (female)"
label variable finknowledge_std "Self-assesed financial literacy"
label variable playertrading_experience "Trading experience"
label variable playercourse_financial "Finance course taken"
label variable d_knowledge "Dummy Self-assessed financial literacy"

label variable diff_payoff "Payoff difference"


egen prediction_accuracy_mean_std=std(prediction_accuracy_mean)
label variable prediction_accuracy_mean_std "Prediction accuracy"

local controls finquiz_std age_std d_gender d_knowledge playertrading_experience playercourse_financial prediction_accuracy_mean_std diff_payoff


reghdfe prefer_gamified  `controls' if playerinner_name=="s1", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H2.tex", r2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prefer_gamified  `controls' if playerinner_name=="s2", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H2.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prefer_gamified  `controls' if playerinner_name=="s3", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H2.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe better_gamified  `controls' if playerinner_name=="s1", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H2.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe better_gamified  `controls' if playerinner_name=="s2", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H2.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe better_gamified  `controls' if playerinner_name=="s3", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H2.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe option_value  `controls' if playerinner_name=="s1", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H2.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe option_value  `controls' if playerinner_name=="s2", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H2.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


clear all
set more off

import delimited "`directory'/data_processed/panel_trader_round"


// encode experimental session
encode playerinner_name, generate(exp_session)
// // Label variables
// // ---------------------------------

egen age_std=std(playerage)
gen d_gender=(playergender=="Female")
egen finquiz_std=std(playerpayoff)
egen finknowledge_std=std(playerknowledge)

gen d_knowledge = (finknowledge_std >0)


label variable excessive_trading "Excessive trading"
label variable gamified "Gamified"
label variable age_std "Age"
label variable d_gender "Gender (female)"
label variable finquiz_std "Financial quiz score"
label variable playertrading_experience "Trading experience"
label variable salient "Salient purchase price"
label variable playercourse_financial "Finance course taken"
label variable finknowledge_std "Self-assessed financial literacy"
label variable d_knowledge "Dummy Self-assessed financial literacy"
label variable prediction_accuracy "Prediction accuracy"
label variable ingame_experience "In-game experience"
label variable accuracy_pred_zero "First-tick prediction"

egen prediction_accuracy_std=std(prediction_accuracy)

// Define a list of controls
local controls salient age_std d_gender finquiz_std d_knowledge playertrading_experience playercourse_financial prediction_accuracy_std
local controls_2 salient age_std d_gender finquiz_std d_knowledge playertrading_experience playercourse_financial                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      


// Table for H1
gen bias_buy=10000*(filtered_prob_buy-0.5)
gen bias_sell=10000*(filtered_prob_sell-0.5)

gen prefers_game=(playersr_prefs=="Design 2")
gen game_prefers_interact=gamified*prefers_game
gen nongame_prefers_interact=gamified*(1-prefers_game)

label variable prefers_game "Prefers gamified"
label variable game_prefers_interact "Gamified $\times$ Prefers gamified"
label variable nongame_prefers_interact  "Gamified $\times$ Prefers non-gamified"

gen ds1=(playerinner_name=="s1")
gen ds2=(playerinner_name=="s2")
gen ds3=(playerinner_name=="s3")
gen ds4=(playerinner_name=="s4")

gen gamified_ds1=gamified*ds1
gen gamified_ds2=gamified*ds2
gen gamified_ds3=gamified*ds3
gen gamified_ds4=gamified*ds4



reghdfe excessive_trading gamified `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H3.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_prefs=="Design 1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_badges==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_badges==2, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_badges==3, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_badges==4, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_badges==5, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


// Table for H2

// reghdfe bias_buy prefers_game   if playerinner_name =="s1", absorb(round_number) vce(robust)
reghdfe bias_buy prefers_game  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H4.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe bias_buy prefers_game game_prefers_interact nongame_prefers_interact  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

// reghdfe bias_sell prefers_game  if playerinner_name =="s1", absorb(round_number) vce(robust)
reghdfe bias_sell prefers_game  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe bias_sell prefers_game game_prefers_interact nongame_prefers_interact  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

// reghdfe plr prefers_game  if playerinner_name =="s1", absorb(round_number) vce(robust)
reghdfe plr prefers_game  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe plr prefers_game game_prefers_interact nongame_prefers_interact  `controls' if playerinner_name =="s1", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

// reghdfe pgr prefers_game   if playerinner_name =="s1", absorb(round_number) vce(robust)
reghdfe pgr prefers_game  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe pgr prefers_game game_prefers_interact nongame_prefers_interact  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


gen disp_effect=pgr_alerts-plr_alerts

reghdfe plr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H6.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe disp_effect  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe plr_alerts  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr_alerts  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe disp_effect  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe plr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe disp_effect  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


clear all
set more off

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
gen d_knowledge = (finknowledge_std >0)

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
label variable d_knowledge "Dummy Self-assessed financial literacy"

// Define a list of controls
local controls salient age_std d_gender finquiz_std d_knowledge playertrading_experience playercourse_financial prediction_accuracy_std
local controls2 salient age_std d_gender finquiz_std d_knowledge playertrading_experience playercourse_financial

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
outreg2 using "`directory'/tables/appendix_table_H5.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe dsell green_alert green_alert_game red_alert red_alert_game filtered_prob_std capital_gains_std gamified if playerinner_name =="s2" & position_lag==1, absorb(participant_code round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe dbuy green_alert green_alert_game red_alert red_alert_game filtered_prob_std  gamified `controls2' if playerinner_name =="s2" & prediction_accuracy==1 & position_lag==0, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe dsell green_alert green_alert_game red_alert red_alert_game filtered_prob_std  capital_gains_std `controls2' gamified    if playerinner_name =="s2" & prediction_accuracy==1 & position_lag==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe dbuy green_alert green_alert_game red_alert red_alert_game filtered_prob_std  gamified `controls' if playerinner_name =="s2" & prediction_accuracy<1 & position_lag==0, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe dsell green_alert green_alert_game red_alert red_alert_game filtered_prob_std  capital_gains_std `controls' gamified    if playerinner_name =="s2" & prediction_accuracy<1 & position_lag==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)