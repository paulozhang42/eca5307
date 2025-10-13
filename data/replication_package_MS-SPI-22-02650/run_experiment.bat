echo off
cd code

echo Selecting main experiment data (select_sample.py 0)
python select_sample.py 0

echo Selecting UofT experiment data (select_sample.py 1)
python select_sample.py 1

echo Plotting sample price path (Figure 3)
python figure_price_path.py

echo Compute optimal trade strategy for Bayesian trader (optimal_trades_theory.py)
python optimal_trades_theory.py

echo Encode preference dummies (self_reflection.py)
python self_reflection.py 0
python self_reflection.py 1

echo Build panels main experiment (build_main_panels.py 0)
python build_main_panels.py 0

echo Build panels UofT experiment (build_main_panels.py 1)
python build_main_panels.py 1

echo Generate figures main experiment (generate_figures.py 0)
python generate_figures.py 0

echo Generate figures UofT experiment (generate_figures.py 1)
python generate_figures.py 1

echo Build jack-knife samples for financial quiz questions (Figure H.1)
python jackknife_financialquiz.py

echo Generate tables with trader-round panel data
cd ../regressions
python execute_stata.py "regression_trader_round.do"

echo Generate tables with trader panel data (i.e., preferences and selection issues)
python execute_stata.py "regression_trader_panel.do"

echo Generate tables with tick-level data
python execute_stata.py "regression_tick_data.do"

echo Generate robustness tables H2 to H6
python execute_stata.py "regression_robustness_H2_H6.do"

echo Generate tables with jack-knife samples for financial quiz questions (Table H.7)
python execute_stata.py "regression_quiz_jackknife.do"

cd ..