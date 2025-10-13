import pandas as pd
import numpy as np
import seaborn as sns
import sys
import matplotlib.pyplot as plt
from matplotlib import rc, font_manager
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import warnings

warnings.filterwarnings("ignore")


def settings_plot(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines["right"].set_visible(False)
    ax.spines["top"].set_visible(False)
    return ax


# sourcery skip: hoist-similar-statement-from-if, hoist-statement-from-if
sizeOfFont = 18
ticks_font = font_manager.FontProperties(size=sizeOfFont)


uoft_session = int(sys.argv[1])

if uoft_session:
    tick_data_full = pd.read_csv(
        "../data_processed/panel_tick_data_uoft.csv", index_col=0
    )
    tick_data_full["finscore_above_median"] = 1 * (tick_data_full["player.payoff"] > 9)
    trade_data = pd.read_csv("../data_processed/panel_trades_uoft.csv", index_col=0)
    trader_round = pd.read_csv(
        "../data_processed/panel_trader_round_uoft.csv", index_col=0
    )
    trader_round["finscore_above_median"] = 1 * (trader_round["player.payoff"] > 9)
    trader_round["excessive_trading_dummy"] = np.where(
        trader_round["excessive_trading"] >= 1, 1, 0
    )
    sr_data = pd.read_csv("../data_processed/self_reflection_uoft.csv", index_col=0)
    tick_data = tick_data_full[tick_data_full["player.inner_name"] == "s2"]
    tick_data["alert"] = np.where(
        tick_data.green_alert == 1,
        "green",
        np.where(tick_data.red_alert == 1, "red", 0),
    )
else:
    # Load the three data frames
    tick_data_full = pd.read_csv("../data_processed/panel_tick_data.csv", index_col=0)
    tick_data_full["finscore_above_median"] = 1 * (tick_data_full["player.payoff"] > 9)
    trade_data = pd.read_csv("../data_processed/panel_trades.csv", index_col=0)
    trader_round = pd.read_csv("../data_processed/panel_trader_round.csv", index_col=0)
    trader_round["finscore_above_median"] = 1 * (trader_round["player.payoff"] > 9)
    trader_round["excessive_trading_dummy"] = np.where(
        trader_round["excessive_trading"] >= 1, 1, 0
    )
    sr_data = pd.read_csv("../data_processed/self_reflection.csv", index_col=0)

    tick_data = tick_data_full[tick_data_full["player.inner_name"] == "s2"]
    tick_data["alert"] = np.where(
        tick_data.green_alert == 1,
        "green",
        np.where(tick_data.red_alert == 1, "red", 0),
    )

##### FIGURE: TICK-BY-TICK
############################

sizefigs_L = (24, 10)
gs = gridspec.GridSpec(2, 1)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)
rnd = 2

sns.barplot(
    data=tick_data[tick_data.round_number == rnd],
    x="tick_number",
    y="position_delta",
    hue="gamified",
    errorbar="se",
    palette="Blues",
)
red_alerts = (
    tick_data[(tick_data.round_number == rnd) & (tick_data["red_alert"] == 1)][
        "tick_number"
    ]
    .drop_duplicates()
    .tolist()
)
green_alerts = (
    tick_data[(tick_data.round_number == rnd) & (tick_data["green_alert"] == 1)][
        "tick_number"
    ]
    .drop_duplicates()
    .tolist()
)
for r in red_alerts:
    plt.axvline(x=r - 5, c="r", lw=24, alpha=0.3)
for g in green_alerts:
    plt.axvline(x=g - 5, c="g", lw=24, alpha=0.3)

plt.xticks(rotation=60)
plt.ylabel("Position change", fontsize=22)
plt.title("Experimental round %i" % (rnd - 1), fontsize=22)

plt.xlabel("Tick number", fontsize=22)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(handles, ["Not gamified", "Gamified"], frameon=False, fontsize=22)

ax = fig.add_subplot(gs[1, 0])
ax = settings_plot(ax)
rnd = 5

sns.barplot(
    data=tick_data[tick_data.round_number == rnd],
    x="tick_number",
    y="position_delta",
    hue="gamified",
    errorbar="se",
    palette="Blues",
)
red_alerts = (
    tick_data[(tick_data.round_number == rnd) & (tick_data["red_alert"] == 1)][
        "tick_number"
    ]
    .drop_duplicates()
    .tolist()
)
green_alerts = (
    tick_data[(tick_data.round_number == rnd) & (tick_data["green_alert"] == 1)][
        "tick_number"
    ]
    .drop_duplicates()
    .tolist()
)
for r in red_alerts:
    plt.axvline(x=r - 5, c="r", lw=24, alpha=0.3)
for g in green_alerts:
    plt.axvline(x=g - 5, c="g", lw=24, alpha=0.3)

plt.xticks(rotation=60)
plt.ylabel("Position change", fontsize=22)
plt.title("Experimental round %i" % (rnd - 1), fontsize=22)

plt.xlabel("Tick number", fontsize=22)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(handles, ["Not gamified", "Gamified"], frameon=False, fontsize=22)


plt.tight_layout(pad=5.0)
# plt.show()
if uoft_session:
    # plt.savefig("../figures/figuretick_by_tick_notifications_uoft.png", bbox_inches="tight")
    print("No in-text figure for UofT session")
else:
    plt.savefig("../figures/main_figure_8.png", bbox_inches="tight")


##### FIGURE: DECISIONS ON ALERT
############################

alert_ticks = tick_data[tick_data["alert"].isin(["green", "red"])]

alert_ticks["dbuy"] = 1 * (alert_ticks["position_delta"] == 1)
alert_ticks["dbuy"] = np.where(
    alert_ticks["position_lag"] == 0, alert_ticks["dbuy"], np.nan
)

alert_ticks["dsell"] = 1 * (alert_ticks["position_delta"] == -1)
alert_ticks["dsell"] = np.where(
    alert_ticks["position_lag"] == 1, alert_ticks["dsell"], np.nan
)


sizefigs_L = (16, 9)
gs = gridspec.GridSpec(2, 2)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)
sns.barplot(
    data=alert_ticks,
    x="alert",
    y="position_delta",
    hue="gamified",
    palette="Blues",
    errorbar="se",
    order=["green", "red"],
)

plt.ylabel("Position change", fontsize=18)
plt.xlabel("Notification alert", fontsize=18)
ax.set_xticklabels(labels=["Green alert", "Red alert"])
plt.title("Full sample", fontsize=18)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(handles, ["Not gamified", "Gamified"], frameon=False, fontsize=18)

ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)
sns.kdeplot(
    data=trader_round[trader_round["player.inner_name"] == "s2"],
    x="prediction_accuracy",
)

plt.xlabel("Prediction accuracy", fontsize=18)
plt.ylabel("Density", fontsize=18)
plt.title("Distribution of prediction accuracy (mid-round)", fontsize=18)

ax = fig.add_subplot(gs[1, 0])
ax = settings_plot(ax)
sns.barplot(
    data=alert_ticks[alert_ticks.accuracy_pred_zero < 1],
    x="alert",
    y="position_delta",
    hue="gamified",
    palette="Blues",
    errorbar="se",
    order=["green", "red"],
)


plt.ylabel("Position change", fontsize=18)
plt.xlabel("Notification alert", fontsize=18)
ax.set_xticklabels(labels=["Green alert", "Red alert"])
plt.title("Participants with predicition accuracy < 1", fontsize=18)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(handles, ["Not gamified", "Gamified"], frameon=False, fontsize=18)


ax = fig.add_subplot(gs[1, 1])
ax = settings_plot(ax)
sns.barplot(
    data=alert_ticks[alert_ticks.accuracy_pred_zero == 1],
    x="alert",
    y="position_delta",
    hue="gamified",
    palette="Blues",
    errorbar="se",
    order=["green", "red"],
)


plt.ylabel("Position change", fontsize=18)
plt.xlabel("Notification alert", fontsize=18)
ax.set_xticklabels(labels=["Green alert", "Red alert"])
plt.title("Participants with prediction accuracy = 1", fontsize=18)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(handles, ["Not gamified", "Gamified"], frameon=False, fontsize=18)


plt.tight_layout(pad=5.0)
# plt.show()

if uoft_session:
    plt.savefig("../figures/appendix_figure_g4.png", bbox_inches="tight")
else:
    plt.savefig("../figures/main_figure_9.png", bbox_inches="tight")


#####
## FIGURE: ENGAGEMENT HEDONIC
#####

sizefigs_L = (16, 6)
gs = gridspec.GridSpec(1, 2)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

sns.barplot(
    data=trader_round[(trader_round["player.inner_name"] == "s1")],
    x="player.sr_prefs",
    y="excessive_trading",
    hue="gamified",
    palette="Blues",
    errorbar="se",
)

plt.ylabel("Trading activity", fontsize=18)
plt.xlabel("Design preference", fontsize=18)
ax.set_xticklabels(labels=["Non-gamified", "Gamified"], fontsize=18)

if uoft_session:
    plt.ylim(0, 1.2)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(handles, ["Not gamified", "Gamified"], frameon=False, fontsize=18, loc="best")


ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)


sns.barplot(
    data=trader_round[(trader_round["player.inner_name"] == "s1")],
    x="player.sr_badges",
    y="excessive_trading",
    hue="gamified",
    palette="Blues",
    errorbar="se",
)

plt.ylabel("Trading activity", fontsize=18)
plt.xlabel("Likert scale rating of achievement badges", fontsize=18)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(handles, ["Not gamified", "Gamified"], frameon=False, fontsize=18, loc="best")

plt.tight_layout(pad=5.0)

if uoft_session:
    plt.savefig("../figures/appendix_figure_g2.png", bbox_inches="tight")
else:
    plt.savefig("../figures/main_figure_6.png", bbox_inches="tight")


trader_round["bias_buy"] = 10000 * (0.5 - trader_round["filtered_prob_buy"])
trader_round["bias_sell"] = 10000 * (trader_round["filtered_prob_sell"] - 0.5)

#####
## FIGURE 6: PREFERENCES (After R&R Sep 2023)
#####
sizefigs_L = (18, 6)
gs = gridspec.GridSpec(1, 2)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)

sr_data["player.payoff_demean"] = (
    sr_data["player.payoff"] - sr_data["player.payoff"].mean()
) / sr_data["player.payoff"].std()

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)


sns.barplot(
    data=sr_data[(sr_data["player.inner_name"] == "s1")],
    x="player.sr_badges",
    y="player.payoff_demean",
    palette="Blues",
    errorbar="se",
)

plt.title("Session I: Hedonic gamification", fontsize=18)
plt.ylabel("Standardized quiz score", fontsize=18)
plt.xlabel("Likert scale rating of achievement badges", fontsize=18)

# Set custom x-axis tick locations and labels
custom_x_ticks = [0, 1, 2, 3, 4]
custom_x_labels = ["1\n(dislike badges)\n", 2, 3, 4, "5\n(like badges)\n"]

# Apply the custom x-axis ticks and labels
ax.set_xticks(custom_x_ticks)
ax.set_xticklabels(custom_x_labels)

ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)


sns.barplot(
    data=sr_data[(sr_data["player.inner_name"] == "s2")],
    x="player.sr_notifications",
    y="player.payoff_demean",
    palette="Blues",
    errorbar="se",
)

plt.title("Session II: Price notifications", fontsize=18)
plt.ylabel("Standardized quiz score", fontsize=18)
plt.xlabel("Likert scale rating of price notifications", fontsize=18)

# Set custom x-axis tick locations and labels
custom_x_ticks = [0, 1, 2, 3, 4]
custom_x_labels = [
    "1\n(dislike \n notifications)",
    2,
    3,
    4,
    "5\n(like \n notifications)",
]

# Apply the custom x-axis ticks and labels
ax.set_xticks(custom_x_ticks)
ax.set_xticklabels(custom_x_labels)

plt.tight_layout(pad=5.0)

if uoft_session:
    plt.savefig("../figures/appendix_figure_g1.png", bbox_inches="tight")
else:
    plt.savefig("../figures/main_figure_5.png", bbox_inches="tight")

#######


trader_round["bias_buy"] = 10000 * (0.5 - trader_round["filtered_prob_buy"])
trader_round["bias_sell"] = 10000 * (trader_round["filtered_prob_sell"] - 0.5)


info_treat = trader_round[trader_round["player.inner_name"] == "s2"]
info = (
    info_treat.set_index(
        ["participant_code", "round_number", "gamified", "player.sr_prefs"]
    )[["PLR_alerts", "PGR_alerts", "diff_PGR_PLR_alerts"]]
    .stack()
    .reset_index()
)
info.columns = [
    "participant_code",
    "round_number",
    "gamified",
    "player.sr_prefs",
    "measure",
    "value",
]


## FIGURE 8: Direction (Minor R&R, Sep 2023)
## ---------------------------
sizefigs_L = (16, 6)
gs = gridspec.GridSpec(1, 2)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

trade_data["excessive_trading"] = (
    trade_data["n_transactions"] / trade_data["optimal_trade_count"]
)
trade_data["dummy_trading"] = 1 * (trade_data["excessive_trading"] >= 1)

sns.kdeplot(
    data=trade_data[
        (trade_data["player.inner_name"] == "s1") & (trade_data.dummy_trading == 0)
    ],
    x="filtered_prob",
    hue="name",
    common_norm=False,
)

plt.xlabel(r"Probability of good state  ($\pi_t$)", fontsize=18)
plt.ylabel("Trade direction", fontsize=18)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(
    handles,
    ["Sell trades", "Buy trades"],
    title_fontsize=18,
    frameon=False,
    fontsize=18,
    loc="upper right",
)
plt.title("Trading activity < 1", fontsize=18)


ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)

trade_data["excessive_trading"] = (
    trade_data["n_transactions"] / trade_data["optimal_trade_count"]
)
trade_data["dummy_trading"] = 1 * (trade_data["excessive_trading"] >= 1)

sns.kdeplot(
    data=trade_data[
        (trade_data["player.inner_name"] == "s1") & (trade_data.dummy_trading == 1)
    ],
    x="filtered_prob",
    hue="name",
    common_norm=False,
)

plt.xlabel(r"Probability of good state  ($\pi_t$)", fontsize=18)
plt.ylabel("Trade direction", fontsize=18)

legend = ax.get_legend()
handles = legend.legendHandles
legend.remove()
ax.legend(
    handles,
    ["Sell trades", "Buy trades"],
    title_fontsize=18,
    frameon=False,
    fontsize=18,
    loc="upper right",
)
plt.title("Trading activity > 1", fontsize=18)


plt.tight_layout(pad=5.0)

if uoft_session:
    plt.savefig("../figures/appendix_figure_g3.png", bbox_inches="tight")
else:
    plt.savefig("../figures/main_figure_7.png", bbox_inches="tight")
