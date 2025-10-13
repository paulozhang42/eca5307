// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
import delimited "`directory'/data_processed/self_reflection"
save "`directory'/data_processed/self_reflection.dta", replace
clear
import delimited "`directory'/data_processed/jackknife_finquiz.csv"
save "`directory'/data_processed/jackknife_finquiz.dta", replace

use "`directory'/data_processed/self_reflection.dta", clear
merge m:1 participant_code using "`directory'/data_processed/jackknife_finquiz.dta"

egen age_std=std(playerage)
gen d_gender=(playergender=="Female")
egen finquiz_std=std(playerpayoff)
egen finknowledge_std=std(playerknowledge)
gen prefer_gamified=(playersr_prefs=="Design 2")
gen better_gamified=(playersr_better_decs=="Design 2")
gen diff_payoff_pct=10000*(profit_gamified-profit_nongamified)/profit_nongamified
egen diff_payoff=std(diff_payoff_pct)
gen option_value=(playersr_better_have_option=="Have an option between Design #1 and Design #2,")

egen finquiz_q1_std=std(playerpayoff_q1)
egen finquiz_q2_std=std(playerpayoff_q2)
egen finquiz_q3_std=std(playerpayoff_q3)
egen finquiz_q4_std=std(playerpayoff_q4)
egen finquiz_q5_std=std(playerpayoff_q5)
egen finquiz_q6_std=std(playerpayoff_q6)
egen finquiz_q7_std=std(playerpayoff_q7)
egen finquiz_q8_std=std(playerpayoff_q8)
egen finquiz_q9_std=std(playerpayoff_q9)
egen finquiz_q10_std=std(playerpayoff_q10)
egen finquiz_q11_std=std(playerpayoff_q11)
egen finquiz_q12_std=std(playerpayoff_q12)

gen d_knowledge = (finknowledge_std >0)

label variable finquiz_std "Financial quiz score"

foreach var of varlist finquiz_q1_std finquiz_q2_std finquiz_q3_std finquiz_q4_std finquiz_q5_std finquiz_q6_std finquiz_q7_std finquiz_q8_std finquiz_q9_std finquiz_q10_std finquiz_q11_std finquiz_q12_std {
	label variable `var' "Financial quiz score"
}

label variable age_std "Age"
label variable d_gender "Gender (female)"
label variable finknowledge_std "Self-assesed financial literacy"
label variable playertrading_experience "Trading experience"
label variable playercourse_financial "Finance course taken"
label variable d_knowledge "Dummy Self-assessed financial literacy"

label variable diff_payoff "Payoff difference"


egen prediction_accuracy_mean_std=std(prediction_accuracy_mean)
label variable prediction_accuracy_mean_std "Prediction accuracy"

local controls age_std d_gender finknowledge_std playertrading_experience playercourse_financial prediction_accuracy_mean_std diff_payoff

gen temp_score=finquiz_std
label variable temp_score "Financial quiz score"

reghdfe prefer_gamified  `controls' temp_score if playerinner_name=="s1", noabsorb vce(cl participant_code)
outreg2 using "`directory'/tables/appendix_table_H7.tex", r2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

drop temp_score

foreach var of varlist finquiz_q1_std finquiz_q2_std finquiz_q3_std finquiz_q4_std finquiz_q5_std finquiz_q6_std finquiz_q7_std finquiz_q8_std finquiz_q9_std finquiz_q10_std finquiz_q11_std finquiz_q12_std {
	gen temp_score=`var'
	label variable temp_score "Financial quiz score"
    reghdfe prefer_gamified  `controls' temp_score if playerinner_name=="s1", noabsorb vce(cl participant_code)
    outreg2 using "`directory'/tables/appendix_table_H7.tex", r2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
	drop temp_score
}


