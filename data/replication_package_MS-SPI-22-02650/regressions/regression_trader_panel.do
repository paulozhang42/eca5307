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


label variable finquiz_std "Financial quiz score"
label variable age_std "Age"
label variable d_gender "Gender (female)"
label variable finknowledge_std "Self-assesed financial literacy"
label variable playertrading_experience "Trading experience"
label variable playercourse_financial "Finance course taken"

label variable diff_payoff "Payoff difference"


egen prediction_accuracy_mean_std=std(prediction_accuracy_mean)
label variable prediction_accuracy_mean_std "Prediction accuracy"

local controls finquiz_std age_std d_gender finknowledge_std playertrading_experience playercourse_financial prediction_accuracy_mean_std diff_payoff

// Table 3
reghdfe prefer_gamified  `controls' if playerinner_name=="s1", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_3.tex", r2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prefer_gamified  `controls' if playerinner_name=="s2", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_3.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe prefer_gamified  `controls' if playerinner_name=="s3", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_3.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe better_gamified  `controls' if playerinner_name=="s1", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_3.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe better_gamified  `controls' if playerinner_name=="s2", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_3.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe better_gamified  `controls' if playerinner_name=="s3", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_3.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe option_value  `controls' if playerinner_name=="s1", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_3.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe option_value  `controls' if playerinner_name=="s2", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/main_table_3.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


// Appendix Table H.1
reg playersr_badges finquiz_std, vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H1.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reg playersr_badges finquiz_std age_std d_gender finknowledge_std playertrading_experience playercourse_financial prediction_accuracy_mean_std diff_payoff, vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reg playersr_confetti finquiz_std, vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reg playersr_confetti finquiz_std age_std d_gender finknowledge_std playertrading_experience playercourse_financial prediction_accuracy_mean_std diff_payoff, vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reg playersr_notifications finquiz_std, vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reg playersr_notifications finquiz_std age_std d_gender finknowledge_std playertrading_experience playercourse_financial prediction_accuracy_mean_std diff_payoff, vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)