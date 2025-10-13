// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
import delimited "`directory'/data_processed/panel_trader_round"


// encode experimental session
encode playerinner_name, generate(exp_session)
// // Label variables
// // ---------------------------------

egen age_std = std(playerage)
gen d_gender = (playergender == "Female")
egen finquiz_std = std(playerpayoff)
egen finknowledge_std = std(playerknowledge)

gen d_knowledge = (finknowledge_std > 0)


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

egen prediction_accuracy_std = std(prediction_accuracy)

// Define a list of controls
local controls salient age_std d_gender finquiz_std finknowledge_std playertrading_experience playercourse_financial prediction_accuracy_std
local controls_2 salient age_std d_gender finquiz_std finknowledge_std playertrading_experience playercourse_financial
local controls_3 salient age_std d_gender finquiz_std d_knowledge playertrading_experience playercourse_financial prediction_accuracy_std
local controls_4 salient age_std d_gender finquiz_std d_knowledge playertrading_experience playercourse_financial


gen bias_buy = 10000 * (filtered_prob_buy - 0.5)
gen bias_sell = 10000 * (filtered_prob_sell - 0.5)

gen prefers_game = (playersr_prefs == "Design 2")
gen game_prefers_interact = gamified * prefers_game
gen nongame_prefers_interact = gamified * (1 - prefers_game)

label variable prefers_game "Prefers gamified"
label variable game_prefers_interact "Gamified $\times$ Prefers gamified"
label variable nongame_prefers_interact "Gamified $\times$ Prefers non-gamified"

gen ds1 = (playerinner_name == "s1")
gen ds2 = (playerinner_name == "s2")
gen ds3 = (playerinner_name == "s3")
gen ds4 = (playerinner_name == "s4")

gen gamified_ds1 = gamified * ds1
gen gamified_ds2 = gamified * ds2
gen gamified_ds3 = gamified * ds3
gen gamified_ds4 = gamified * ds4


// Table 4

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_4.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_prefs=="Design 1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_badges==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_badges==2, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_badges==3, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_badges==4, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe excessive_trading gamified `controls' if playerinner_name =="s1" & playersr_badges==5, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


// Table 5

reghdfe bias_buy prefers_game  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_5.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe bias_buy prefers_game game_prefers_interact nongame_prefers_interact  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe bias_sell prefers_game  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe bias_sell prefers_game game_prefers_interact nongame_prefers_interact  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe plr prefers_game  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe plr prefers_game game_prefers_interact nongame_prefers_interact  `controls' if playerinner_name =="s1", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe pgr prefers_game  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe pgr prefers_game game_prefers_interact nongame_prefers_interact  `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


// Table 7

reghdfe plr  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe plr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe plr  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe plr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

gen disp_effect=pgr_alerts-plr_alerts

reghdfe plr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe disp_effect  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe plr_alerts  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr_alerts  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe disp_effect  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy==1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe plr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr_alerts  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe disp_effect  gamified `controls'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_7.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)



// Appendix Table F.1

gen rev=finquiz_std
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe excessive_trading gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F1.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe excessive_trading gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

gen rev=1-salient
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe excessive_trading gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe excessive_trading gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

gen rev=ingame_experience
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe excessive_trading gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe excessive_trading gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

gen rev=accuracy_pred_zero
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe excessive_trading gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe excessive_trading gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

gen rev=overconfidence
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe excessive_trading gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe excessive_trading gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

// Appendix Table F.2 (top panel, buys)

gen rev=finquiz_std
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe bias_buy gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_buys.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe bias_buy gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_buys.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

gen rev=1-salient
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe bias_buy gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_buys.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe bias_buy gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_buys.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

gen rev=ingame_experience
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe bias_buy gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_buys.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe bias_buy gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_buys.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev


gen rev=accuracy_pred_zero
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe bias_buy gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_buys.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe bias_buy gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_buys.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

gen rev=overconfidence
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe bias_buy gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_buys.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe bias_buy gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_buys.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev


// Appendix Table F.2 (bottom panel, sells)

gen rev=finquiz_std
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe bias_sell gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_sells.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe bias_sell gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_sells.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

gen rev=1-salient
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe bias_sell gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_sells.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe bias_sell gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_sells.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

gen rev=ingame_experience
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe bias_sell gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_sells.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe bias_sell gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_sells.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev


gen rev=accuracy_pred_zero
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe bias_sell gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_sells.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe bias_sell gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_sells.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev

gen rev=overconfidence
gen gamified_rev=gamified*rev
label variable gamified_rev "Gamified $\times$ REV"
reghdfe bias_sell gamified gamified_rev `controls' if playerinner_name =="s1", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_sells.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe bias_sell gamified gamified_rev `controls' if playerinner_name =="s1" & playersr_prefs=="Design 2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F2_sells.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
drop rev
drop gamified_rev


// Appendix Table F.3
 
reghdfe prediction_accuracy gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F3.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prediction_accuracy  gamified `controls_2'   ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy_std<=0, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prediction_accuracy  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" &  & prediction_accuracy_std>0, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe prediction_accuracy  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prediction_accuracy  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" &  & prediction_accuracy_std<=0 [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prediction_accuracy  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" &  & prediction_accuracy_std>0 [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

// Appendix Table F.4

egen overcon_mean=mean(overconfidence)

reghdfe prediction_accuracy  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy_std<=0 [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F4.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prediction_accuracy  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & prediction_accuracy_std>0  [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe prediction_accuracy  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & overconfidence>overcon_mean & prediction_accuracy_std<=0 [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prediction_accuracy  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & overconfidence>overcon_mean & prediction_accuracy_std>0 [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe prediction_accuracy  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & overconfidence<=overcon_mean & prediction_accuracy_std<=0 [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prediction_accuracy  gamified `controls_2'  ingame_experience accuracy_pred_zero if playerinner_name =="s2" & overconfidence<=overcon_mean & prediction_accuracy_std>0 [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)



// Appendix Table F.5.

gen std_buy_prob_100=100*std_buy_prob
gen std_sell_prob_100=100*std_sell_prob

reghdfe std_buy_prob_100 gamified if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F5.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe std_buy_prob_100 gamified  `controls' ingame_experience  if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe std_sell_prob_100 gamified if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe std_sell_prob_100 gamified  `controls' ingame_experience  if playerinner_name =="s2", absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe std_buy_prob_100 gamified  if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe std_buy_prob_100 gamified  `controls' ingame_experience  if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe std_sell_prob_100 gamified if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe std_sell_prob_100 gamified  `controls' ingame_experience   if playerinner_name =="s2" & prediction_accuracy<1, absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


// Appendix Table F.6

label variable ds3 "$ d_\text{session III}$"
label variable gamified_ds3 "Gamified $\times d_\text{session III}$"


reghdfe plr_alerts  gamified gamified_ds3 ds3  `controls'  ingame_experience accuracy_pred_zero if (playerinner_name =="s2" | playerinner_name =="s3") & (prediction_accuracy_std<=0), absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F6.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe plr_alerts  gamified gamified_ds3 ds3  `controls'  ingame_experience accuracy_pred_zero if (playerinner_name =="s2" | playerinner_name =="s3") & (prediction_accuracy_std>0), absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr_alerts  gamified gamified_ds3 ds3  `controls'  ingame_experience accuracy_pred_zero if (playerinner_name =="s2" | playerinner_name =="s3") & (prediction_accuracy_std<=0), absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe pgr_alerts  gamified gamified_ds3 ds3  `controls'  ingame_experience accuracy_pred_zero if (playerinner_name =="s2" | playerinner_name =="s3") & (prediction_accuracy_std>0), absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prediction_accuracy   gamified gamified_ds3 ds3  `controls_2'  ingame_experience accuracy_pred_zero if (playerinner_name =="s2" | playerinner_name =="s3") & (prediction_accuracy_std<=0) [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prediction_accuracy   gamified gamified_ds3 ds3  `controls_2'  ingame_experience accuracy_pred_zero if (playerinner_name =="s2" | playerinner_name =="s3") & (prediction_accuracy_std>0) [pweight=prediction_confidence], absorb(round_number) vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_F6.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)