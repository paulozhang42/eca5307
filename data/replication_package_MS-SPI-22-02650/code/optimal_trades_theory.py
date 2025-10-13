import numpy as np
import pandas as pd
import warnings

warnings.filterwarnings("ignore")


# function to filter up-tick probabilities from prices
def filter_probs(z, tr_prob):
    q = np.zeros(len(z))
    q[0] = 0.5  # initialize
    for i in range(1, len(q)):
        num = (0.5 + 0.05 * z[i]) * (
            tr_prob[0] * q[i - 1] + tr_prob[1] * (1 - q[i - 1])
        )
        denom = num + (0.5 - 0.05 * z[i]) * (
            tr_prob[1] * q[i - 1] + tr_prob[0] * (1 - q[i - 1])
        )
        q[i] = num / denom
    return [q, tr_prob[1] + q * (tr_prob[0] - tr_prob[1])]


# Markov transition matrix
transition_matrix = {"g": {"g": 0.85, "b": 0.15}, "b": {"g": 0.15, "b": 0.85}}
transition_matrix_mkv = {"g": {"g": 0.5, "b": 0.5}, "b": {"g": 0.5, "b": 0.5}}
optimal_trading = pd.DataFrame()
markov_final = pd.DataFrame()

for round in range(1, 5):
    # read prices data
    prices = pd.read_csv(
        f"../price_paths/prices_markov_main_{str(round)}.csv", index_col=0
    )
    # compute sign changes in price direction
    zt = prices.diff().applymap(np.sign)
    # filter probabilities
    fwdprob = {
        "stock": filter_probs(
            zt["stock"].to_list(),
            [transition_matrix["g"]["g"], transition_matrix["g"]["b"]],
        )[1]
    }
    fwdprob = pd.DataFrame(fwdprob)
    fwdprob = fwdprob.reset_index()
    fwdprob = fwdprob.rename(
        columns={"index": "tick_number"}
    )  # relabel for merge with trade data
    fwdprob["tick_number"] = (
        fwdprob["tick_number"] + 1
    )  # Account for 0-indexing in Python
    fwdprob["round_number"] = round + 1  # round number (counted from 2 to 5)

    # optimal position
    fwdprob["opt_position"] = np.where(fwdprob.stock > 0.5, 1, -1)
    # flag if position needs to be switched (i.e., a trade)
    fwdprob["position_switch"] = fwdprob["opt_position"] * fwdprob[
        "opt_position"
    ].shift(1)
    fwdprob["trade_flag"] = np.where(fwdprob["position_switch"] == -1, 1, 0)

    # count optimal # of trades (keeping in mind first 4 ticks cannot be traded)
    notrades = fwdprob.iloc[4:]["trade_flag"].sum()

    fwdprob["optimal_trade_count"] = notrades
    fwdprob["filtered_prob"] = fwdprob["stock"]
    fwdprob["price"] = prices

    temp = fwdprob[
        [
            "round_number",
            "tick_number",
            "filtered_prob",
            "trade_flag",
            "optimal_trade_count",
            "price",
        ]
    ]

    optimal_trading = pd.concat([optimal_trading, temp], ignore_index=True)


for round in range(1, 5):
    # read prices data
    prices = pd.read_csv(
        f"../price_paths/prices_markov_robust_{str(round)}.csv", index_col=0
    )
    # compute sign changes in price direction
    zt = prices.diff().applymap(np.sign)
    # filter probabilities
    fwdprob = {
        "stock": filter_probs(
            zt["stock"].to_list(),
            [transition_matrix_mkv["g"]["g"], transition_matrix_mkv["g"]["b"]],
        )[1]
    }
    fwdprob = pd.DataFrame(fwdprob)
    fwdprob = fwdprob.reset_index()
    fwdprob = fwdprob.rename(
        columns={"index": "tick_number"}
    )  # relabel for merge with trade data
    fwdprob["tick_number"] = (
        fwdprob["tick_number"] + 1
    )  # Account for 0-indexing in Python
    fwdprob["round_number"] = round + 1  # round number (counted from 2 to 5)

    # optimal position
    fwdprob["opt_position"] = np.where(fwdprob.stock > 0.5, 1, -1)
    # flag if position needs to be switched (i.e., a trade)
    fwdprob["position_switch"] = fwdprob["opt_position"] * fwdprob[
        "opt_position"
    ].shift(1)
    fwdprob["trade_flag"] = np.where(fwdprob["position_switch"] == -1, 1, 0)

    # count optimal # of trades (keeping in mind first 4 ticks cannot be traded)
    notrades = fwdprob.iloc[4:]["trade_flag"].sum()

    fwdprob["optimal_trade_count"] = notrades
    fwdprob["filtered_prob"] = fwdprob["stock"]
    fwdprob["price"] = prices

    temp = fwdprob[
        [
            "round_number",
            "tick_number",
            "filtered_prob",
            "trade_flag",
            "optimal_trade_count",
            "price",
        ]
    ]

    markov_final = pd.concat([markov_final, temp], ignore_index=True)

optimal_trading.to_csv("../data_prolific/optimal_trade_flags.csv")
markov_final.to_csv("../data_prolific/markov_trade_flags.csv")
