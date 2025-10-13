import pandas as pd
import seaborn as sns
import sys
import matplotlib.pyplot as plt
import numpy as np
import warnings

warnings.filterwarnings("ignore")

uoft_session = int(sys.argv[1])
# uoft_session = 1

if uoft_session:
    # LOAD EXPERIMENTAL DATA
    # --------------------------------------------------------------------
    trade_data = pd.read_csv("../data_prolific/trader_actions_uoft.csv", index_col=0)
    # sort trades by tick and timestamp
    trade_data = trade_data.sort_values(
        ["participant_code", "round_number", "tick_number", "timestamp"]
    )
    trade_data["tick_number"] = (
        trade_data["tick_number"] + 1
    )  # Python indexing starts at zero
    metadata = pd.read_csv("../data_prolific/trader_metadata_uoft.csv", index_col=0)
    metadata["participant_code"] = metadata[
        "participant.code"
    ]  # rename column for consistency
    pretrade = pd.read_csv("../data_prolific/pretrade_data_uoft.csv", index_col=0)

else:
    # LOAD EXPERIMENTAL DATA
    # --------------------------------------------------------------------
    trade_data = pd.read_csv("../data_prolific/trader_actions.csv", index_col=0)
    # sort trades by tick and timestamp
    trade_data = trade_data.sort_values(
        ["participant_code", "round_number", "tick_number", "timestamp"]
    )
    trade_data["tick_number"] = (
        trade_data["tick_number"] + 1
    )  # Python indexing starts at zero
    metadata = pd.read_csv("../data_prolific/trader_metadata.csv", index_col=0)
    metadata["participant_code"] = metadata[
        "participant.code"
    ]  # rename column for consistency
    pretrade = pd.read_csv("../data_prolific/pretrade_data.csv", index_col=0)

pretrade["participant_code"] = pretrade["participant.code"]
trade_data = trade_data.merge(
    metadata[["participant_code", "player.inner_name"]], on="participant_code"
)

# PROCESS OPTIMAL TRADES AND ALERT NOTIFICATIONS
# ----------------------------------------------------------
optimal_trades = pd.read_csv("../data_prolific/optimal_trade_flags.csv", index_col=0)

# alert for price going down three times in a row
optimal_trades["red_alert"] = (
    (
        optimal_trades.groupby("round_number")["price"]
        .diff()
        .fillna(0)
        .lt(0)
        .rolling(3)
        .sum()
    )
    == 3
).astype(int)
# alert only occurs for first tick in the run
optimal_trades["red_alert"] = (
    optimal_trades["red_alert"] & ~(optimal_trades["red_alert"].shift(1) == 1)
).astype(int)
# alert for price going up three times in a row
optimal_trades["green_alert"] = (
    (
        optimal_trades.groupby("round_number")["price"]
        .diff()
        .fillna(0)
        .gt(0)
        .rolling(3)
        .sum()
    )
    == 3
).astype(int)
# alert only occurs for first tick in the run
optimal_trades["green_alert"] = (
    optimal_trades["green_alert"] & ~(optimal_trades["green_alert"].shift(1) == 1)
).astype(int)


# compute optimal trade direction
optimal_trades["trade_sign_raw"] = np.where(
    ((optimal_trades["trade_flag"] == 1) & (optimal_trades["filtered_prob"] > 0.5)),
    -1,
    np.where(
        ((optimal_trades["trade_flag"] == 1) & (optimal_trades["filtered_prob"] < 0.5)),
        1,
        0,
    ),
)


# insert initial position at the beginning of each round
def insert_start_position(group):
    group.iloc[0, group.columns.get_loc("trade_sign_raw")] = -1
    return group


optimal_trades = optimal_trades.groupby(["round_number"]).apply(insert_start_position)
optimal_trades = optimal_trades.reset_index(drop=True)
optimal_trades["position_raw"] = -optimal_trades.groupby("round_number")[
    "trade_sign_raw"
].cumsum()

optimal_trades["dummy"] = 0
first_exceeds_2 = {}
for i, row in optimal_trades.iterrows():
    if row["round_number"] not in first_exceeds_2:
        first_exceeds_2[row["round_number"]] = True
    if first_exceeds_2[row["round_number"]] and row["position_raw"] >= 2:
        optimal_trades.at[i, "dummy"] = 1
        first_exceeds_2[row["round_number"]] = False


optimal_trades["optimal_trade_sign"] = np.where(
    optimal_trades["dummy"] == 1, 0, optimal_trades["trade_sign_raw"]
)
optimal_trades["opt_position"] = -optimal_trades.groupby("round_number")[
    "optimal_trade_sign"
].cumsum()
del optimal_trades["trade_sign_raw"]
del optimal_trades["position_raw"]
del optimal_trades["dummy"]


def remove_start_position(group):
    group.iloc[0, group.columns.get_loc("optimal_trade_sign")] = 0
    return group


optimal_trades = optimal_trades.groupby(["round_number"]).apply(remove_start_position)
optimal_trades = optimal_trades.reset_index(drop=True)
optimal_trades["optimal_trade_flag"] = optimal_trades["optimal_trade_sign"].map(abs)
optimal_trades["optimal_trade_count"] = optimal_trades.groupby("round_number")[
    "optimal_trade_flag"
].transform("sum")

# this is a copy for S1 to S3
optimal_trades_s1_s3 = optimal_trades.copy()


# PROCESS OPTIMAL TRADES AND ALERT NOTIFICATIONS FOR MARKOV
# ----------------------------------------------------------
optimal_trades = pd.read_csv("../data_prolific/markov_trade_flags.csv", index_col=0)

# alert for price going down three times in a row
optimal_trades["red_alert"] = (
    (
        optimal_trades.groupby("round_number")["price"]
        .diff()
        .fillna(0)
        .lt(0)
        .rolling(3)
        .sum()
    )
    == 3
).astype(int)
# alert only occurs for first tick in the run
optimal_trades["red_alert"] = (
    optimal_trades["red_alert"] & ~(optimal_trades["red_alert"].shift(1) == 1)
).astype(int)
# alert for price going up three times in a row
optimal_trades["green_alert"] = (
    (
        optimal_trades.groupby("round_number")["price"]
        .diff()
        .fillna(0)
        .gt(0)
        .rolling(3)
        .sum()
    )
    == 3
).astype(int)
# alert only occurs for first tick in the run
optimal_trades["green_alert"] = (
    optimal_trades["green_alert"] & ~(optimal_trades["green_alert"].shift(1) == 1)
).astype(int)


# compute optimal trade direction
optimal_trades["trade_sign_raw"] = np.where(
    ((optimal_trades["trade_flag"] == 1) & (optimal_trades["filtered_prob"] > 0.5)),
    -1,
    np.where(
        ((optimal_trades["trade_flag"] == 1) & (optimal_trades["filtered_prob"] < 0.5)),
        1,
        0,
    ),
)


# insert initial position at the beginning of each round
def insert_start_position(group):
    group.iloc[0, group.columns.get_loc("trade_sign_raw")] = -1
    return group


optimal_trades = optimal_trades.groupby(["round_number"]).apply(insert_start_position)
optimal_trades = optimal_trades.reset_index(drop=True)
optimal_trades["position_raw"] = -optimal_trades.groupby("round_number")[
    "trade_sign_raw"
].cumsum()

optimal_trades["dummy"] = 0
first_exceeds_2 = {}
for i, row in optimal_trades.iterrows():
    if row["round_number"] not in first_exceeds_2:
        first_exceeds_2[row["round_number"]] = True
    if first_exceeds_2[row["round_number"]] and row["position_raw"] >= 2:
        optimal_trades.at[i, "dummy"] = 1
        first_exceeds_2[row["round_number"]] = False


optimal_trades["optimal_trade_sign"] = np.where(
    optimal_trades["dummy"] == 1, 0, optimal_trades["trade_sign_raw"]
)
optimal_trades["opt_position"] = -optimal_trades.groupby("round_number")[
    "optimal_trade_sign"
].cumsum()
del optimal_trades["trade_sign_raw"]
del optimal_trades["position_raw"]
del optimal_trades["dummy"]


def remove_start_position(group):
    group.iloc[0, group.columns.get_loc("optimal_trade_sign")] = 0
    return group


optimal_trades = optimal_trades.groupby(["round_number"]).apply(remove_start_position)
optimal_trades = optimal_trades.reset_index(drop=True)
optimal_trades["optimal_trade_flag"] = optimal_trades["optimal_trade_sign"].map(abs)
optimal_trades["optimal_trade_count"] = optimal_trades.groupby("round_number")[
    "optimal_trade_flag"
].transform("sum")

# this is a copy for S4
optimal_trades_s4 = optimal_trades.copy()

optimal_trades = pd.DataFrame()
for s in ["s1", "s2", "s3"]:
    optimal_trades_s1_s3["player.inner_name"] = s
    optimal_trades = pd.concat(
        [optimal_trades, optimal_trades_s1_s3], ignore_index=True
    )

optimal_trades_s4["player.inner_name"] = "s4"
optimal_trades = pd.concat([optimal_trades, optimal_trades_s4], ignore_index=True)

###################################################

## FILTER DATA
## ----------------------------

# Select only trader-rounds that were not repeated/restarted
round_starts = (
    trade_data[trade_data.name == "GAME_STARTS"]
    .groupby(["participant_code", "round_number"])
    .count()["id"]
    .reset_index()
)
round_starts = round_starts.rename(columns={"id": "round_starts"})
trade_data = trade_data.merge(
    round_starts, on=["participant_code", "round_number"], how="left"
)
trade_data = trade_data[trade_data.round_starts == 1]

# Get a list of all participant IDs
list_subjects = metadata["participant.code"].tolist()

# keep only trades (e.g, delete game start/end messages) and remove the training round
trades = trade_data[
    (trade_data.name.isin(["buy", "sell"]))
    & (trade_data.round_number >= 2)
    & (trade_data.participant_code.isin(list_subjects))
]

# delete multiple trades within a tick (which produce no effects)
trades["price"] = trades["body"].apply(lambda x: eval(x)["priceA"])
trades["price_shift"] = trades.groupby(["participant_code", "round_number"])[
    "price"
].shift(1)
trades["trade_direction"] = np.where(trades["name"] == "buy", -1, 1)
trades["capital_gains"] = (trades["price"] - trades["price_shift"]) * (
    trades["trade_direction"]
)
trades["capital_gains"] = np.where(
    trades["name"] == "buy", np.nan, trades["capital_gains"]
)

trades["trades_within_tick"] = trades.groupby(
    ["participant_code", "round_number", "tick_number"]
)["id"].transform("count")
trades = trades[trades["trades_within_tick"] % 2 == 1]
trades = trades.drop_duplicates(
    subset=["participant_code", "round_number", "tick_number"], keep="last"
)

# delete "illegal" trades (system bugs: e.g., two sells in a row or two buys in a row)
trades["prev_name"] = trades.groupby(["participant_code", "round_number"])[
    "name"
].shift(1)
trades["duplicate_order"] = 1 * (trades["name"] == trades["prev_name"])
trades = trades[trades.duplicate_order == 0]
trades["first_trade"] = trades.groupby(["participant_code", "round_number"])[
    "name"
].transform("first")
trades = trades[trades.first_trade == "sell"]


## PROCESS PARTICIPANT-ROUND TRADES PANEL
## --------------------------------------


# merge trades with optimal trades
trades = trades.merge(
    optimal_trades[
        [
            "player.inner_name",
            "round_number",
            "tick_number",
            "filtered_prob",
            "optimal_trade_count",
            "red_alert",
            "green_alert",
        ]
    ],
    on=["player.inner_name", "round_number", "tick_number"],
    how="left",
)
# merge trades with metadata
trades = trades.merge(
    metadata[
        [
            "participant_code",
            "player.block_name",
            "player.age",
            "player.payoff",
            "player.gender",
            "player.course_financial",
            "player.trading_experience",
            "player.online_trading_experience",
        ]
    ],
    on="participant_code",
    how="left",
)

# get gamification and salience dummies
trades["round_block"] = trades[["round_number", "player.block_name"]].values.tolist()


# A function to generate gamified and salience dummies
def gamified_salient(roundblock):
    round = roundblock[0]
    block = roundblock[1]

    if ((round in [2, 3]) & (block in ["block 1 (G first)", "block 2 (G first)"])) | (
        (round in [4, 5]) & (block in ["block 3 (G second)", "block 4 (G second)"])
    ):
        gamified = 1
    else:
        gamified = 0

    if ((round in [2, 4]) & (block in ["block 2 (G first)", "block 4 (G second)"])) | (
        (round in [3, 5]) & (block in ["block 1 (G first)", "block 3 (G second)"])
    ):
        salient = 1
    else:
        salient = 0

    return [gamified, salient]


trades["gamified"] = trades["round_block"].apply(
    lambda x: gamified_salient(x)[0]
)  # gamified round dummy
trades["salient"] = trades["round_block"].apply(
    lambda x: gamified_salient(x)[1]
)  # salient round dummy

# dummy for in-game experience
trades["ingame_experience"] = np.where(
    trades["player.block_name"].isin(["block 3 (G second)", "block 4 (G second)"]), 1, 0
)


## MERGE TRADES WITH FIRST-TICK PREDICTIONS
## ----------------------------------------

# distance between first-tick prediction and objective likelihood of price going up
predictions = trade_data[trade_data.name == "PREDICTIONS_SENT"]
predictions["tick_number"] = predictions["tick_number"].fillna(
    0
)  # tick "zero" predictions
predictions["prediction"] = predictions["body"].apply(lambda x: eval(x)["stockUpA"])
predictions["confidence"] = predictions["body"].apply(lambda x: eval(x)["confidenceA"])

pred_zero = predictions[predictions.tick_number == 0]  # select only first predictions

# accuracy of first-tick prediction, normalized between zero (not accurate) and one (perfectly accurate)
pred_zero["accuracy_pred_zero"] = 1 - pred_zero["prediction"].apply(
    lambda x: 1 - np.abs((x - 3) / 2)
)

# merge first-tick prediction with trades
trades = trades.merge(
    pred_zero[["participant_code", "round_number", "accuracy_pred_zero"]],
    on=["participant_code", "round_number"],
    how="left",
)

## MERGE TRADES WITH SELF-ASSESSED KNOWLEDGE
## -----------------------------------------
trades = trades.merge(
    pretrade[["participant_code", "player.knowledge"]], on="participant_code"
)
trades["overconfidence"] = (
    trades["player.knowledge"] / 10 - trades["player.payoff"] / 12
)

## ----------------------------------
## BUILD TICK-BY-TICK DATAFRAME
## ----------------------------------

# merge with optimal trade paths and alerts
tick_data = (
    trades[["player.inner_name", "participant_code", "round_number"]]
    .drop_duplicates()
    .merge(
        optimal_trades[
            [
                "player.inner_name",
                "round_number",
                "price",
                "tick_number",
                "filtered_prob",
                "red_alert",
                "green_alert",
                "optimal_trade_sign",
            ]
        ],
        on=["player.inner_name", "round_number"],
    )
)

# merge with actual trade decisions
tick_data = tick_data.merge(
    trades[["round_number", "participant_code", "tick_number", "name"]],
    on=["round_number", "participant_code", "tick_number"],
    how="left",
).drop_duplicates(subset=["round_number", "participant_code", "tick_number"])


# define function to insert value into first row of each group
def insert_value(group):
    group.iloc[0, group.columns.get_loc("name")] = "buy"
    return group


# account for the fact that participants start with +1 stocks
tick_data = tick_data.groupby(["participant_code", "round_number"]).apply(insert_value)
tick_data = tick_data.reset_index(drop=True)

# position changes
tick_data["position_delta"] = np.where(
    tick_data["name"] == "buy", 1, np.where(tick_data["name"] == "sell", -1, 0)
)

# tick-by-tick position
tick_data["position"] = tick_data.groupby(["participant_code", "round_number"])[
    "position_delta"
].transform("cumsum")

tick_data["position_lag"] = tick_data.groupby(["participant_code", "round_number"])[
    "position"
].shift(1)

# capital gains/losses
tick_data["purchase_price"] = np.where(
    tick_data["position_delta"] == 1, tick_data["price"], np.nan
)
tick_data["purchase_price"] = tick_data.groupby(["participant_code", "round_number"])[
    "purchase_price"
].transform(lambda x: x.ffill())
tick_data["capital_gains"] = tick_data["price"] - tick_data["purchase_price"]


tick_data["red_alert_L1"] = tick_data.groupby(["participant_code", "round_number"])[
    "red_alert"
].shift(1)
tick_data["red_alert_L2"] = tick_data.groupby(["participant_code", "round_number"])[
    "red_alert"
].shift(2)
tick_data["red_alert_L3"] = tick_data.groupby(["participant_code", "round_number"])[
    "red_alert"
].shift(3)
tick_data["green_alert_L1"] = tick_data.groupby(["participant_code", "round_number"])[
    "green_alert"
].shift(1)
tick_data["green_alert_L2"] = tick_data.groupby(["participant_code", "round_number"])[
    "green_alert"
].shift(2)
tick_data["green_alert_L3"] = tick_data.groupby(["participant_code", "round_number"])[
    "green_alert"
].shift(3)

tick_data = tick_data[
    tick_data.tick_number >= 5
]  # delete first 4 ticks since no trades can be executed.

tick_data = tick_data.merge(
    metadata[
        [
            "participant_code",
            "player.block_name",
            "player.age",
            "player.payoff",
            "player.gender",
            "player.course_financial",
            "player.trading_experience",
            "player.online_trading_experience",
        ]
    ],
    on="participant_code",
    how="left",
)

tick_data["ingame_experience"] = np.where(
    tick_data["player.block_name"].isin(["block 3 (G second)", "block 4 (G second)"]),
    1,
    0,
)

## ----------------------------------
## COMPUTE DISPOSITION EFFECT
## ----------------------------------

# Keep only hold and sell ticks
tick_data_hold = tick_data[
    ((tick_data.position == 1) & (tick_data.position_delta == 0))
    | (tick_data.position_delta == -1)
]
tick_data_hold["name"] = tick_data_hold["name"].fillna("hold")
# merge action and capital gains
tick_data_hold["action_gain"] = tick_data_hold[
    ["name", "capital_gains"]
].values.tolist()


# function to bin every sell/hold tick into paper gain/loss and realized gain/loss
def disposition(action_gain):
    action = action_gain[0]
    gain = action_gain[1]

    if (action == "sell") & (gain > 0):
        return "Realized gain"
    elif (action == "sell") & (gain < 0):
        return "Realized loss"
    elif (action == "hold") & (gain > 0):
        return "Paper gain"
    elif (action == "hold") & (gain < 0):
        return "Paper loss"
    else:
        return np.nan


# apply labels
tick_data_hold["category"] = tick_data_hold["action_gain"].map(lambda x: disposition(x))

# count PGR and PLR
count_pgr_plr = (
    tick_data_hold.groupby(["participant_code", "round_number", "category"])
    .count()["price"]
    .reset_index()
    .pivot(index=["participant_code", "round_number"], columns="category")
    .fillna(0)
)
count_pgr_plr = count_pgr_plr.reset_index()
count_pgr_plr.columns = [
    "participant_code",
    "round_number",
    "Paper gain",
    "Paper loss",
    "Realized gain",
    "Realized loss",
]
count_pgr_plr["PGR"] = count_pgr_plr["Realized gain"] / (
    count_pgr_plr["Realized gain"] + count_pgr_plr["Paper gain"]
)
count_pgr_plr["PLR"] = count_pgr_plr["Realized loss"] / (
    count_pgr_plr["Realized loss"] + count_pgr_plr["Paper loss"]
)


# Merge PGR and PLR into trades data
trades = trades.merge(
    count_pgr_plr[["participant_code", "round_number", "PGR", "PLR"]],
    on=["participant_code", "round_number"],
    how="left",
)


# ZOOM IN PGR/PLR @ ALERTS

tick_data_alerts = tick_data[
    ((tick_data.green_alert == 1) | (tick_data.red_alert == 1))
    & (
        ((tick_data.position == 1) & (tick_data.position_delta == 0))
        | (tick_data.position_delta == -1)
    )
]

tick_data_alerts["name"] = tick_data_alerts["name"].fillna("hold")
# merge action and capital gains
tick_data_alerts["action_gain"] = tick_data_alerts[
    ["name", "capital_gains"]
].values.tolist()


# apply labels
tick_data_alerts["category"] = tick_data_alerts["action_gain"].map(
    lambda x: disposition(x)
)

# count PGR and PLR
count_pgr_plr_alerts = (
    tick_data_alerts.groupby(["participant_code", "round_number", "category"])
    .count()["price"]
    .reset_index()
    .pivot(index=["participant_code", "round_number"], columns="category")
    .fillna(0)
)
count_pgr_plr_alerts = count_pgr_plr_alerts.reset_index()
count_pgr_plr_alerts.columns = [
    "participant_code",
    "round_number",
    "Paper gain",
    "Paper loss",
    "Realized gain",
    "Realized loss",
]
count_pgr_plr_alerts["PGR_alerts"] = count_pgr_plr_alerts["Realized gain"] / (
    count_pgr_plr_alerts["Realized gain"] + count_pgr_plr_alerts["Paper gain"]
)
count_pgr_plr_alerts["PLR_alerts"] = count_pgr_plr_alerts["Realized loss"] / (
    count_pgr_plr_alerts["Realized loss"] + count_pgr_plr_alerts["Paper loss"]
)


# Merge PGR and PLR into trades data
trades = trades.merge(
    count_pgr_plr_alerts[
        ["participant_code", "round_number", "PGR_alerts", "PLR_alerts"]
    ],
    on=["participant_code", "round_number"],
    how="left",
)


panel = trades.groupby(["participant_code", "round_number", "player.inner_name"]).agg(
    {
        "n_transactions": "count",
        "optimal_trade_count": "mean",
        "gamified": "mean",
        "salient": "mean",
        "player.intermediary_payoff": "mean",
        "ingame_experience": "mean",
        "accuracy_pred_zero": "mean",
        "player.knowledge": "mean",
        "overconfidence": "mean",
        "PGR": "mean",
        "PLR": "mean",
        "PGR_alerts": "mean",
        "PLR_alerts": "mean",
    }
)
panel["excessive_trading"] = np.where(
    panel["optimal_trade_count"] == 0,
    np.nan,
    panel["n_transactions"] / panel["optimal_trade_count"],
)
panel["diff_PGR_PLR"] = panel["PGR"] - panel["PLR"]
panel["diff_PGR_PLR_alerts"] = panel["PGR_alerts"] - panel["PLR_alerts"]
panel = panel.reset_index()
panel = panel.merge(
    metadata[
        [
            "participant_code",
            "player.age",
            "player.payoff",
            "player.gender",
            "player.course_financial",
            "player.trading_experience",
            "player.online_trading_experience",
        ]
    ],
    on="participant_code",
    how="left",
)


bs = (
    trade_data[trade_data.name.isin(["buy", "sell"])]
    .groupby(["participant_code", "round_number", "player.inner_name", "name"])
    .count()["id"]
    .reset_index()
)
bs = bs.pivot(
    index=["participant_code", "round_number", "player.inner_name"],
    columns="name",
    values="id",
).reset_index()
bs = bs.fillna(0)
bs.columns = [
    "participant_code",
    "round_number",
    "player.inner_name",
    "count_buy",
    "count_sell",
]

panel = panel.merge(
    bs, on=["participant_code", "round_number", "player.inner_name"], how="left"
)

##########
# COMPUTE BUY-SELL PROBABILITY THRESHOLDS
##########
buy_sells = (
    trades.groupby(["participant_code", "round_number", "trade_direction"])[
        ["filtered_prob"]
    ]
    .mean()
    .reset_index()
)
buy_sells = buy_sells.pivot(
    index=["participant_code", "round_number"], columns="trade_direction"
)
buy_sells.columns = ["filtered_prob_buy", "filtered_prob_sell"]
buy_sells = buy_sells.reset_index()

panel = panel.merge(buy_sells, on=["participant_code", "round_number"], how="left")

buy_sells_variance = (
    trades.groupby(["participant_code", "round_number", "trade_direction"])[
        ["filtered_prob"]
    ]
    .std()
    .reset_index()
)
buy_sells_variance = buy_sells_variance.pivot(
    index=["participant_code", "round_number"], columns="trade_direction"
)
buy_sells_variance.columns = ["std_buy_prob", "std_sell_prob"]
buy_sells_variance = buy_sells_variance.reset_index()

panel = panel.merge(
    buy_sells_variance, on=["participant_code", "round_number"], how="left"
)

#########
# COMPUTE MID-ROUND BELIEFS
#########

beliefs = predictions[predictions.tick_number == 31][
    [
        "player.inner_name",
        "round_number",
        "participant_code",
        "tick_number",
        "prediction",
        "confidence",
    ]
]
beliefs = beliefs.merge(
    optimal_trades[
        ["player.inner_name", "round_number", "tick_number", "filtered_prob"]
    ],
    on=["player.inner_name", "round_number", "tick_number"],
)
list_quantiles_probs = (
    tick_data["filtered_prob"].quantile([0.2, 0.4, 0.6, 0.8]).tolist()
)


def likert_convert(p):
    if p <= list_quantiles_probs[0]:
        return 1
    elif p <= list_quantiles_probs[1]:
        return 2
    elif p <= list_quantiles_probs[2]:
        return 3
    elif p <= list_quantiles_probs[3]:
        return 4
    else:
        return 5


beliefs["likert_prob"] = beliefs["filtered_prob"].apply(likert_convert)
beliefs["prediction_accuracy"] = (
    1 - np.abs(beliefs["prediction"] - beliefs["likert_prob"]) / 4
)
beliefs["prediction_confidence"] = (beliefs["confidence"] - 1) / 4

panel = panel.merge(
    beliefs[
        [
            "round_number",
            "participant_code",
            "prediction",
            "prediction_accuracy",
            "prediction_confidence",
        ]
    ],
    on=["round_number", "participant_code"],
    how="left",
)
panel = panel.drop_duplicates(subset=["participant_code", "round_number"])

trades = trades.merge(
    beliefs[
        [
            "round_number",
            "participant_code",
            "prediction",
            "prediction_accuracy",
            "prediction_confidence",
        ]
    ],
    on=["round_number", "participant_code"],
    how="left",
)
trades = trades.drop_duplicates(
    subset=["participant_code", "round_number", "tick_number"]
)

# Merge panel with SR
if uoft_session:
    sr = pd.read_csv("../data_processed/self_reflection_uoft.csv", index_col=0)
else:
    sr = pd.read_csv("../data_processed/self_reflection.csv", index_col=0)
if "participant.code" in sr.columns:
    sr["participant_code"] = sr["participant.code"]
panel = panel.merge(
    sr[
        [
            "participant_code",
            "player.sr_prefs",
            "player.sr_better_decs",
            "player.sr_better_have_option",
            "player.sr_notifications",
            "player.sr_badges",
            "player.sr_confetti",
        ]
    ],
    on="participant_code",
    how="left",
)

trades = trades.merge(
    sr[
        [
            "participant_code",
            "player.sr_prefs",
            "player.sr_better_decs",
            "player.sr_better_have_option",
            "player.sr_notifications",
            "player.sr_badges",
            "player.sr_confetti",
        ]
    ],
    on="participant_code",
    how="left",
)

### SAVE PROCESSED PANELS
if uoft_session:
    panel.to_csv("../data_processed/panel_trader_round_uoft.csv")
else:
    panel.to_csv("../data_processed/panel_trader_round.csv")

tick_data = tick_data.merge(
    panel[["participant_code", "round_number", "gamified", "salient"]],
    on=["participant_code", "round_number"],
    how="left",
)
tick_data = tick_data.merge(
    beliefs[
        ["round_number", "participant_code", "prediction", "prediction_accuracy"]
    ].drop_duplicates(subset=["participant_code", "round_number"]),
    on=["round_number", "participant_code"],
    how="left",
)
tick_data = tick_data.merge(
    pretrade[["participant_code", "player.knowledge"]], on="participant_code"
)
tick_data = tick_data.merge(
    pred_zero[["participant_code", "round_number", "accuracy_pred_zero"]],
    on=["participant_code", "round_number"],
    how="left",
)

if uoft_session:
    tick_data.to_csv("../data_processed/panel_tick_data_uoft.csv")
    trades.to_csv("../data_processed/panel_trades_uoft.csv")

else:
    tick_data.to_csv("../data_processed/panel_tick_data.csv")
    trades.to_csv("../data_processed/panel_trades.csv")


temp_profits = (
    panel.groupby(["participant_code", "gamified"])["player.intermediary_payoff"]
    .mean()
    .reset_index()
    .pivot(index="participant_code", columns="gamified")
)
temp_profits.columns = ["profit_nongamified", "profit_gamified"]
temp_profits = temp_profits.reset_index()

panel = panel.merge(temp_profits, on="participant_code", how="left")
panel["accuracy_pred_zero_mean"] = panel.groupby("participant_code")[
    "accuracy_pred_zero"
].transform("mean")
panel["prediction_accuracy_mean"] = panel.groupby("participant_code")[
    "prediction_accuracy"
].transform("mean")

sr = panel[
    [
        "participant_code",
        "player.inner_name",
        "profit_nongamified",
        "profit_gamified",
        "accuracy_pred_zero_mean",
        "prediction_accuracy_mean",
        "player.knowledge",
        "overconfidence",
        "player.age",
        "player.payoff",
        "player.gender",
        "player.course_financial",
        "player.trading_experience",
        "player.online_trading_experience",
        "player.sr_prefs",
        "player.sr_better_decs",
        "player.sr_better_have_option",
        "player.sr_notifications",
        "player.sr_badges",
        "player.sr_confetti",
    ]
].drop_duplicates(subset="participant_code")

if uoft_session:
    sr.to_csv("../data_processed/self_reflection_uoft.csv")
else:
    sr.to_csv("../data_processed/self_reflection.csv")
