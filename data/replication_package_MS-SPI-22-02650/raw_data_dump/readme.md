
# Raw Files Description

1. **events_04_13_2023_00_46_00.csv**: 
   - Description: Contains a comprehensive list of all events that occurred with each participant in every round during the trading sessions. There are six types of registered events: GAME_ENDS, GAME_STARTS, PREDICTIONS_SENT, assignAward, buy, and sell.

2. **all_apps_wide_2023-04-13.csv**: 
   - Description: Consolidates wide-format data from all three apps in the experimental project (pretrade, trader_wrapper, post_experimental). Variable names follow the `<APP_NAME>.<ROUND_NUMBER>.<FIELD_NAME>` format, including additional participant and session-specific variables.

3. **correct_finquiz_answers.csv**: 
   - Description: Contains correct answers for the financial literacy quiz, aligning with the variable names in the post-experimental data. Matches the `data/financial_quiz.yaml` file in the oTree code.

4. **PageTimes-2023-04-13.csv**: 
   - Description: Standard oTree output file tracking the amount of time each participant spent on each page. Not used in the current analysis.
   
5. **post_experimental_2023-04-13_custom.csv**: 
   - Description: Contains individual responses to the financial quiz, merged with demographic data such as age, gender, and education. 
   **Attention**: no column names are embedded. Column names are: Question Label, Answer, Participant Code, Session Code, Session Display Name,  Age,  Gender,  Education


6. **post_experimental_2023-04-13.csv**: 
   - Description: Includes all demographic and financial experience data, as well as open-ended responses about the participants' perceived purpose of the study and any difficulties they encountered.

7. **pretrade_2023-04-13.csv**: 
   - Description: Encompasses fields related to participant consent, control questions, and questions assessing initial financial familiarity.

8. **prolific_export_demographic_uk.csv**: 
   - Description: This file contains demographic information of Prolific users from *the United Kingdom* who participated in the study. It  includes data such as age, sex, fluency in languages etc.

9. **prolific_export_demographic_us.csv**: 
   - Description: This file contains demographic information of Prolific users from *the United States* who participated in the study. It  includes data such as age, sex, fluency in languages etc.


8. **seed_markov.pickle**: 
   - Description: This pickle file contains a serialized seed state for random number generation. It is used to ensure replicability in simulations of price chart.

9. **trader_wrapper_2023-04-13.csv**: 
    - Description: Contains content identical to events_04_13_2023_00_46_00.csv, documenting all events but with some less relevant columns removed for brevity.

10. **trader_wrapper_2023-04-13_simple.csv**: 
    - Description: Features standard oTree-formatted long-form data from the trader_wrapper app. It includes details of treatments and blocks assigned to participants in each round, their payoffs per round, and the prices shown on the trading platform.


**Note**: In all oTree-generated raw data files, `participant.label` (when not null) refers to the Prolific user ID. These oTree data should be merged with Prolific demographic data using these IDs. Criteria used to filter out completed submissions include: `participant.label` != None, `participant._current_page_name` == 'FinalForProlific', and `session.is_demo` == False.
