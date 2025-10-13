# File descriptions for data files located in data_prolific folder
(take into the account that the entire folder can be easily wiped out and then recreated using run_experiment.bat or run_epxeriment.sh)


## File Descriptions

### `markov_trade_flags.csv`
- **Description**: Contains data on trade flags and optimal trade counts determined by a Markov decision process. It is created using the transition_matrix_mkv, which has equal probabilities for all transitions: {"g": {"g": 0.5, "b": 0.5}, "b": {"g": 0.5, "b": 0.5}}. This matrix suggests a scenario where future price movements are completely uncertain.
- **Columns**: [round_number, tick_number, filtered_prob, trade_flag,  optimal_trade_count, price]

### `optimal_trade_flags.csv`
- **Description**:Contains data on trade flags and optimal trade counts determined  using the transition_matrix, which has transition probabilities of {"g": {"g": 0.85, "b": 0.15}, "b": {"g": 0.15, "b": 0.85}}. This matrix represents an expected model of price changes, where there is a higher probability of price continuing in its current trend (good to good or bad to bad).
- **Columns**: [round_number, tick_number, filtered_prob, trade_flag,  optimal_trade_count, price]


### `pretrade_data_uoft.csv`
- **Description**: Contains pre-trade app data specific to the University of Toronto (UofT) sessions. 
- **Columns**: [player.knowledge, player.martingale, player.consent...]

### `pretrade_data.csv`
- **Description**: Similar to `pretrade_data_uoft.csv`, but for the main experimental sessions (excluding UofT). 
- **Columns**: [player.knowledge, player.martingale, player.consent...]

### `trader_actions_uoft.csv`
- **Description**: Records the actions of traders participating in the University of Toronto (UofT) sessions. Contains a comprehensive list of all events that occurred with each participant in every round during the trading sessions. There are six types of registered events (`name` variable): GAME_ENDS, GAME_STARTS, PREDICTIONS_SENT, assignAward, buy, and sell. It also includes full `body` of the messages sent from a client to server and the full timestamp of an event.
- **Columns**: [round_number,	owner,	name,	timestamp,	body,	balance,	tick_number,	n_transactions,	participant_code,	session_code,	treatment,	player.intermediary_payoff]

### `trader_actions.csv`
- **Description**: Records the actions of traders from the main experimental sessions (excluding UofT). Contains a comprehensive list of all events that occurred with each participant in every round during the trading sessions. There are six types of registered events (`name` variable): GAME_ENDS, GAME_STARTS, PREDICTIONS_SENT, assignAward, buy, and sell. It also includes full `body` of the messages sent from a client to server and the full `timestamp` of an event.
- **Columns**: [round_number,	owner,	name,	timestamp,	body,	balance,	tick_number,	n_transactions,	participant_code,	session_code,	treatment,	player.intermediary_payoff]


### `trader_metadata_uoft.csv`
- **Description**:  Contains metadata based on the post-experimental queestionnaire for traders who participated in the UofT sessions. Includes participants' opinions on different aspects of gamification,  demographic information, treatment and session details, and some open questions (like self-reported purpose of the study).
- **Columns**: [player.age, player.nationality, player.gender,...]

### `trader_metadata.csv`
- **Description**: Similar to `trader_metadata_uoft.csv`, but for traders from the main sessions. Contains metadata based on the post-experimental queestionnaire for traders who participated  from the main sessions (not the UofT). Includes participants' opinions on different aspects of gamification,  demographic information, treatment and session details, and some open questions (like self-reported purpose of the study).
- **Columns**: [player.age, player.nationality, player.gender,...]
