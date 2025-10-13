## Chapkovski, Khapko, and Zoican (2023)  <br> "Trading Gamification and Investor Behavior"
## Experimental replication package

### General instructions

### General Instructions

To run the experiments and generate all Tables and Figures in the paper, follow these setup instructions based on your operating system:

#### For Windows Users:
1. **Set Up Stata Path**: Ensure your local Stata path is correctly set up in `conf/config.yaml`. For Windows, it should look like this (uncomment this line and comment out the Mac path):
   ```yaml
   # Stata path for windows
   stata_path: "C:/Program Files/Stata17/StataMP-64.exe"
   ```
2. **Run the Experiment**: Use the executable file `run_experiment.bat` to execute all code in order. This script generates all Tables and Figures.

#### For macOS and Ubuntu Users:
1. **Set Up Stata Path**: Update your local Stata path in `conf/config.yaml`. For macOS, uncomment the relevant line and comment out the Windows path. Adjust the path based on your Stata version (e.g., StataSE, StataMP):
   ```yaml
   # Stata path for mac
   # You may need to change from StataSE to StataMP depending on your version
   stata_path: "/Applications/Stata/StataSE.app/Contents/MacOS/StataSE"
   ```
2. **Make the Script Executable (if needed)**: Before running the script for the first time, make it executable by running:
   ```
   chmod +x ./run_experiment.sh
   ```
3. **Run the Experiment**: Execute the script `run_experiment.sh` using:
   ```
   ./run_experiment.sh
   ```
   This script will execute all code in order and generate all Tables and Figures.

Note: Ensure that the paths specified in `config.yaml` correctly match the location of your Stata installation. 
* All required raw data is in the `raw_data_dump` folder. You can safely empty the following folders before running the code:
  * `data_processed`, `data_prolific`, `figures`, and `tables`.
    
### Data cleaning and pre-processing

1.  `code/select_sample.py`: Takes the raw Heroku data (which includes all development tests) in the `raw_data_dump` folder and selects the relevant experimental sessions.
    1. Run with parameter `0` to extract data for main sample and with parameter `1` for the University of Toronto sample used in Online Appendix G.
    2. Running the code with parameter `0` populates 3 data files in the `data_prolific` folder: `pretrade_data.csv`, `trader_actions.csv`, and `trader_metadata.csv`.
    3. Running the code with parameter `1` populates 3 other data files in the `data_prolific` folder: `pretrade_data_uoft.csv`, `trader_actions_uoft.csv`, and `trader_metadata_uoft.csv`.
    4. Saves Figure 4 in the main paper as `figures/main_figure_4.png`.
    5. Saves Table 2 in the main paper as `tables/main_table_2.tex`.
2. `code/figure_price_path`: Renders Figure 3 with a sample price path and saves it as `figures/main_figure_3.png`.
3. `code/optimal_trades_theory.py`: Uses the price paths in `price_paths` folder to compute the optimal strategy of a Bayesian trader in any given round. Saves two files:
   1.  `data_prolific/optimal_trade_flags.csv`, for price paths featuring momentum in Sessions I-III
   2.  `data_prolific/markov_trade_flags.csv`, for martingale price paths in Session IV.
4.  `code/self_reflection.py`: Uses post-experimental data to encode preference dummies.
    1.  Run with parameter `0` for main sample, saves panel as `/data_processed/self_reflection.csv`
    2.  Run with parameter `1` for University of Toronto sample, saves panel as `/data_processed/self_reflection_uoft.csv`.
5.  `code/build_main_panels.py` takes the raw data from from `data_prolific` and generates three panels for regression analysis:
   1. `data_processed/panel_trader_round.csv`: a panel with participant-round observation (aggregate measures)
   2. `data_processed/panel_tick_data.csv`: a panel with tick-by-tick actions of participants (including idle ticks)
   3. `data_processed/panel_trades.csv`: a panel with all participant trades.
6. `code/generate_figures.py`: Generate figures in the main paper. Run with parameter `0` for main experiment and parameter `1` for University of Toronto data. List of figures, all saved in `figures` subfolder:
   1. Figures 5 and G1: *Preferences for gamification and financial literacy*
   2. Figures 6 and G2: *Trading activity and preferences for gamification*
   3. Figures 7 and G3: and *Distribution of $\pi_t$ by trading activity*
   4. Figure 8: *Tick-by-tick trading decisions and notifications*
   5. Figures 9 and G4: *Trading decision on notification ticks* 
7. `code/jackknife_financialquiz.py`: Builds a jack-knife samples measure of financial quiz score (dropping questions one by one):
   1. Saves resulting panel of quiz scores as `data_processed/jackknife_finquiz.csv`.
   2. Saves Figure H.1 in the `figures` subfolder.

### Regression code
8. `regressions/execute_stata.py`:
   1. Run with argument `regression_trader_round.do` to generate trader-round tables in `tables` folder: Tables 4, 5, and 7 in the main paper; Tables F1, F2, F3, F4, F5, F6 in the Online Appendix.
   2. Run with argument `regression_trader_panel.do` to generate trader panel tables: Table 3 in the main paper and Table H1 in the Online Appendix.
   3. Run with argument `regression_tick_data.do` to generate tick-level panel tables: Table 6 in the main paper and Table F7 in the Online Appendix.
   4. Run with argument `regression_robustness_H2_H6.do` to generate robustness Tables H2 through H6 in the Online Appendix.
   5. Run with argument `regression_quiz_jackknife.do` to generate Table H.7 with jack-knife measure of the financial quiz score.
   