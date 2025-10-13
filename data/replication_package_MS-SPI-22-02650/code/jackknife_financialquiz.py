import pandas as pd
import seaborn as sns
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


sizeOfFont = 18
ticks_font = font_manager.FontProperties(size=sizeOfFont)

main_sessions = ["vvlpwazd", "uw95ivu5"]

questions = pd.read_csv(
    "../raw_data_dump/post_experimental_2023-04-13_custom.csv", header=None
)
metadata = pd.read_csv("../raw_data_dump/post_experimental_2023-04-13.csv")
metadata = metadata[metadata["session.code"].isin(main_sessions)]
metadata = metadata[["participant.code", "player.payoff"]]
correct_answers = pd.read_csv(
    "../raw_data_dump/correct_finquiz_answers.csv", index_col=0
)

questions = questions[[0, 1, 2, 3]]
questions.columns = ["question", "answer", "participant.code", "session_code"]


questions = questions[questions["session_code"].isin(main_sessions)].reset_index(
    drop=True
)

questions = questions.merge(metadata, on="participant.code", how="left")
questions = questions.merge(correct_answers, on="question", how="left")
questions["correct"] = questions["answer"] == questions["correct_answer"]

no_questions = 12


for q in range(no_questions + 1):
    print(q)
    code = f"Q{q}"
    temp = questions[questions["question_code"] != code]
    temp_correct = questions[questions["question_code"] == code]

    if q == 0:
        jackknife = temp[["participant.code", "player.payoff"]]
        jackknife = jackknife.drop_duplicates().reset_index(drop=True)
        correct_matrix = temp[["participant.code", "player.payoff"]]
        continue

    temp[f"player.payoff_Q{q}"] = temp.groupby("participant.code")["correct"].transform(
        "sum"
    )
    temp_correct[f"correct_Q{q}"] = 1 * temp_correct["correct"]

    temp_correct = temp_correct[["participant.code", f"correct_Q{q}"]]
    temp_correct = temp_correct.drop_duplicates().reset_index(drop=True)
    correct_matrix = correct_matrix.merge(
        temp_correct, on="participant.code", how="left"
    )

    temp = temp[["participant.code", f"player.payoff_Q{q}"]]
    temp = temp.drop_duplicates().reset_index(drop=True)
    jackknife = jackknife.merge(temp, on="participant.code", how="left")


del jackknife["player.payoff"]
jackknife = jackknife.rename(columns={"participant.code": "participant_code"})
jackknife.to_csv("../data_processed/jackknife_finquiz.csv", index=False)

correct_matrix = correct_matrix.rename(columns={"participant.code": "participant_code"})
del correct_matrix["player.payoff"]

correct_matrix.columns = ["participant_code"] + [f"Q{x}" for x in range(1, 13)]
jackknife.columns = ["participant_code"] + [f"Q{x}" for x in range(1, 13)]

sizefigs_L = (16, 8)
gs = gridspec.GridSpec(1, 2)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)
sns.heatmap(
    correct_matrix[[f"Q{x}" for x in range(1, 13)]].corr(),
    annot=True,
    cmap="coolwarm",
    fmt=".2f",
    vmin=-1,
    vmax=1,
)
plt.title("(a) Correlation between correct answers", fontproperties=ticks_font)

ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)
sns.heatmap(
    jackknife[[f"Q{x}" for x in range(1, 13)]].corr(),
    annot=True,
    cmap="coolwarm",
    fmt=".2f",
    vmin=0.5,
    vmax=1,
)

plt.tight_layout(pad=5.0)
plt.title("(b) Correlation between jack-knifed quiz scores", fontproperties=ticks_font)
plt.savefig("../figures/appendix_figure_h1", bbox_inches="tight")
