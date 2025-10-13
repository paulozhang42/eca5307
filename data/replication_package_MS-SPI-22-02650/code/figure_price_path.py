import pickle

import matplotlib.gridspec as gridspec
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib import font_manager

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


sizeOfFont = 18
ticks_font = font_manager.FontProperties(size=sizeOfFont)


# load a good seed
with open("../raw_data_dump/seed_markov.pickle", "rb") as f:
    seed = pickle.load(f)
np.random.set_state(seed)


class markovchain:
    def __init__(self, transition_prob):
        self.transition_prob = transition_prob
        self.states = list(transition_prob.keys())

    def next_state(self, current_state):
        return np.random.choice(
            self.states,
            p=[
                self.transition_prob[current_state][next_state]
                for next_state in self.states
            ],
        )

    def generate_states(self, current_state, no=60):
        future_states = []
        for _ in range(no):
            next_state = self.next_state(current_state)
            future_states.append(next_state)
            current_state = next_state
        return future_states


def states_to_changes(x, increments):
    if x == "g":
        draw = np.random.rand()
        if draw <= 0.55:
            return np.random.choice(increments) * 1
        else:
            return np.random.choice(increments) * (-1)
    elif x == "b":
        draw = np.random.rand()
        if draw <= 0.55:
            return np.random.choice(increments) * (-1)
        else:
            return np.random.choice(increments) * 1
    else:
        return np.nan


def states_to_prob(x):
    if x == "g":
        return 1
    elif x == "b":
        return 0
    else:
        return np.nan


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


# define transition matrix
transition_matrix = {"g": {"g": 0.85, "b": 0.15}, "b": {"g": 0.15, "b": 0.85}}

# initial states for the assets
initial_states = 1 * (np.random.uniform(size=2) <= 0.5)
# increments for price changes
increments = [5, 10, 15]
# initial price
price0 = 100


def get_price_prob(transition_matrix, initial_states, increments, price0):
    chain = markovchain(transition_matrix)
    states_chain = chain.generate_states(
        current_state=["g" if initial_states[0] < 0.5 else "b"][0]
    )

    d = {"stock": states_chain}
    prices = pd.DataFrame(d)
    prices = prices.applymap(lambda x: states_to_changes(x, increments))
    prices.loc[0] = [price0]
    prices = prices.cumsum()
    prices = prices.applymap(lambda x: np.maximum(x, 0))

    # get sign of price changes
    zt = prices.diff().applymap(np.sign)

    fwdprob = {
        "stock": filter_probs(
            zt["stock"].to_list(),
            [transition_matrix["g"]["g"], transition_matrix["g"]["b"]],
        )[1]
    }
    fwdprob = pd.DataFrame(fwdprob)

    return prices, fwdprob


prices, fwdprob = get_price_prob(transition_matrix, initial_states, increments, price0)

gs = gridspec.GridSpec(1, 2)

# Define the color and transparency of the bar
bar_color = "gray"
bar_alpha = 0.6  # Set the transparency (0 = fully transparent, 1 = fully opaque)


# plt.clf()
fig = plt.figure(figsize=(18, 6), facecolor="white")

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

plt.plot(prices["stock"], ls="-", c="b", label="Stock A", marker="o", markersize=5)

locations = [10, 20, 30, 40, 50]

for xc in locations:
    ax.axvspan(xc, xc + 1, facecolor=bar_color, alpha=bar_alpha)


plt.xlabel("Trial", fontsize=18)
plt.ylabel("Stock price", fontsize=18)

plt.xticks(np.arange(0, 61, step=10))
ax.set_xticklabels(ax.get_xticks(), rotation=45)
# plt.legend(loc='best',frameon=False,fontsize=18)

plt.title("Stock prices", fontsize=18)

ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)

plt.plot(fwdprob["stock"], ls="-", c="b", label="Stock A", marker="o", markersize=5)

for xc in locations:
    ax.axvspan(xc, xc + 1, facecolor=bar_color, alpha=bar_alpha)


plt.xlabel("Trial", fontsize=18)
plt.ylabel(r"Probability", fontsize=18)
plt.axhline(0.5, c="k", ls="--")

plt.xticks(np.arange(0, 61, step=10))
ax.set_xticklabels(ax.get_xticks(), rotation=45)
# plt.legend(loc='best',frameon=False,fontsize=18)

plt.title(
    "Probability of state $g$ at next update"
    "\n"
    r"($E\left[\pi_{t+1}\mid \mathcal{F}_t\right]$)",
    fontsize=18,
)

plt.tight_layout(pad=3.0)

plt.savefig("../figures/main_figure_3.png", bbox_inches="tight")
