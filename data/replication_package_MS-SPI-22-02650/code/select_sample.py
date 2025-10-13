import pandas as pd
import numpy as np
import sys
import warnings

warnings.simplefilter(action="ignore")

# load trade-by-trade data
trade_data = pd.read_csv("../raw_data_dump/trader_wrapper_2023-04-13.csv")
trade_simple = pd.read_csv("../raw_data_dump/trader_wrapper_2023-04-13_simple.csv")
trade_simple["participant_code"] = trade_simple["participant.code"]
trade_simple["round_number"] = trade_simple["subsession.round_number"]

# load post-experimental metadata
metadata = pd.read_csv("../raw_data_dump/post_experimental_2023-04-13.csv")

# load pre-trade data
pretrade = pd.read_csv("../raw_data_dump/pretrade_2023-04-13.csv")

# US session code is 'vvlpwazd', ran on April 12 and April 13, 2023.
# UK session code is 'uw95ivu5', ran on April 13, 2023
main_sessions = ["vvlpwazd", "uw95ivu5"]
toronto_sessions = ["vmu7c279", "t7od4xlw"]  # sessions ran at UofT


uoft_session = int(sys.argv[1])
# uoft_session = 0

if uoft_session:
    # select only participants in main sessions (i.e., drop all test sessions)
    metadata = metadata.loc[metadata["session.code"].isin(toronto_sessions)]
else:
    metadata = metadata.loc[metadata["session.code"].isin(main_sessions)]


# select only participants who finished the experiment (i.e., last page accessed is "FinalForProlific")
metadata = metadata.loc[
    metadata["participant._current_page_name"] == "FinalForProlific"
]
# get a list of all unique trader codes (for UK/US sessions, and those traders who finished the experiment)
trader_ids = metadata["participant.code"].unique()

# select only trades/actions of the participants who finished the experiment
trade_data = trade_data.loc[trade_data["participant_code"].isin(trader_ids)]
trade_simple = trade_simple.loc[trade_simple["participant_code"].isin(trader_ids)]

if uoft_session:
    pretrade = pretrade[
        (pretrade["session.code"].isin(toronto_sessions))
        & (pretrade["participant.code"].isin(trader_ids))
    ]
else:
    pretrade = pretrade[
        (pretrade["session.code"].isin(main_sessions))
        & (pretrade["participant.code"].isin(trader_ids))
    ]

if uoft_session:
    pretrade.to_csv("../data_prolific/pretrade_data_uoft.csv")
else:
    pretrade.to_csv("../data_prolific/pretrade_data.csv")

# Participant sample size across experimental sessions
# -----------------------------------------------------
# print("Participant sample size across experimental sessions")
# print(
#     metadata.groupby(["session.code", "player.treatment_name"])
#     .size()
#     .reset_index(name="count")
# )

# Save table with demographic information
if uoft_session == 0:
    df = (
        metadata.groupby(["session.code", "player.treatment_name"])
        .size()
        .reset_index(name="count")
    )
    session_labels = df["player.treatment_name"].drop_duplicates().to_list()
    dict_session = dict(zip(session_labels, [1, 2, 3, 4]))

    df["session_number"] = df["player.treatment_name"].apply(lambda x: dict_session[x])

    grouped_df = df.groupby("session_number")["count"].sum().reset_index()

    # Create a new DataFrame with the desired structure
    new_df = pd.DataFrame(
        {
            "Session #": grouped_df["session_number"],
            "US Participants": df[df["session.code"] == "vvlpwazd"]
            .groupby("session_number")["count"]
            .sum()
            .values,
            "UK Participants": df[df["session.code"] == "uw95ivu5"]
            .groupby("session_number")["count"]
            .sum()
            .values,
            "Total session": grouped_df["count"],
        }
    )

    # Add a total row
    total_row = {
        "Session #": "Total",
        "US Participants": new_df["US Participants"].sum(),
        "UK Participants": new_df["UK Participants"].sum(),
        "Total session": new_df["Total session"].sum(),
    }
    new_df.loc[len(new_df)] = total_row

    # Convert to LaTeX table
    latex_table = new_df.to_latex(
        index=False, escape=False, column_format="cD{.}{.}{2}D{.}{.}{2}D{.}{.}{2}"
    )
    latex_table = latex_table.replace(
        "\\toprule",
        "\\toprule\nSession \\# & \\multicolumn{1}{c}{US Participants} & \\multicolumn{1}{c}{UK Participants} & \\multicolumn{1}{c}{Total session} \\\\ \n\\cmidrule{1-4}",
    )

    filename = "../tables/main_table_2.tex"
    with open(filename, "w") as file:
        file.write(latex_table)

metadata["cad_payoff"] = 0.05 * (
    metadata["player.payoff"] * 4 + metadata["participant.payoff"]
)
# print("CAD payoff summary")
# print(metadata["cad_payoff"].describe())

# some demographics tibbles
# ----------------------------
education_bins = metadata.groupby(["player.education"]).size().reset_index(name="count")
education_bins["percentage"] = education_bins["count"] / education_bins["count"].sum()

studymajor_bins = (
    metadata.groupby(["player.study_major"]).size().reset_index(name="count")
)
studymajor_bins["percentage"] = (
    studymajor_bins["count"] / studymajor_bins["count"].sum()
)

checkport_bins = (
    metadata.groupby(["player.portfolio_frequency"]).size().reset_index(name="count")
)
checkport_bins["percentage"] = checkport_bins["count"] / checkport_bins["count"].sum()

tradefreq_bins = (
    metadata.groupby(["player.trading_frequency"]).size().reset_index(name="count")
)
tradefreq_bins["percentage"] = tradefreq_bins["count"] / tradefreq_bins["count"].sum()

# print("Trading experience stats")
# print(metadata["player.trading_experience"].describe()[["mean", "50%", "std"]])
# print("Online trading experience stats")
# print(metadata["player.online_trading_experience"].describe()[["mean", "50%", "std"]])

import seaborn as sns
from matplotlib import rc, font_manager
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def settings_plot(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines["right"].set_visible(False)
    ax.spines["top"].set_visible(False)
    return ax


sizeOfFont = 18
ticks_font = font_manager.FontProperties(size=sizeOfFont)


sizefigs_L = (16, 5)
gs = gridspec.GridSpec(1, 2)


fig = plt.figure(facecolor="white", figsize=sizefigs_L)
ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)

sns.histplot(
    data=metadata,
    x="player.payoff",
    hue="player.online_trading_experience",
    stat="percent",
    multiple="dodge",
    bins=12,
    common_norm=False,
    palette="mako",
)

plt.xlabel("Financial quiz score", fontsize=20)
plt.ylabel(r"Percent of sample (%)", fontsize=20)

plt.title("Quiz score and trading experience", fontsize=20)
plt.xticks(np.arange(1, 12 + 1, 1.0))
plt.xticks(rotation=60)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(
    handles, ["No trading experience", "Trading experience"], frameon=False, fontsize=16
)


ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

sns.histplot(
    data=metadata,
    x="player.payoff",
    hue="player.course_financial",
    stat="percent",
    multiple="dodge",
    bins=12,
    common_norm=False,
    palette="mako",
)

plt.xlabel("Financial quiz score", fontsize=20)
plt.ylabel(r"Percent of sample (%)", fontsize=20)

plt.title("Quiz score and finance courses", fontsize=20)
plt.xticks(np.arange(1, 12 + 1, 1.0))
plt.xticks(rotation=60)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(handles, ["No finance course", "Finance course"], frameon=False, fontsize=16)


plt.tight_layout(pad=5.0)
# plt.show()

if uoft_session == 0:
    plt.savefig("../figures/main_figure_4.png", bbox_inches="tight")

trade_data = trade_data.reset_index(drop=True)
trade_data = trade_data.rename(columns={"part_number": "round_number"})

trade_data = trade_data.merge(
    trade_simple[["participant_code", "round_number", "player.intermediary_payoff"]],
    on=["participant_code", "round_number"],
    how="left",
)

if uoft_session:
    trade_data.to_csv("../data_prolific/trader_actions_uoft.csv")
    metadata = metadata.reset_index(drop=True)
    metadata.to_csv("../data_prolific/trader_metadata_uoft.csv")
else:
    trade_data.to_csv("../data_prolific/trader_actions.csv")
    metadata = metadata.reset_index(drop=True)
    metadata.to_csv("../data_prolific/trader_metadata.csv")
