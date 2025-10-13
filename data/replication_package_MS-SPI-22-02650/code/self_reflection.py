import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import sys

uoft_session = int(sys.argv[1])

if uoft_session:
    metadata = pd.read_csv("../data_prolific/trader_metadata_uoft.csv", index_col=0)

    metadata["prefer_gamified"] = np.where(
        metadata["player.sr_prefs"] == "Design 2", 1, 0
    )
    metadata["better_decisions_gamified"] = np.where(
        metadata["player.sr_better_decs"] == "Design 2", 1, 0
    )
    metadata["lockout_gamified"] = np.where(
        metadata["player.sr_better_have_option"] == "Only trade on Design #1", 1, 0
    )

    metadata.groupby("player.inner_name")[
        [
            "prefer_gamified",
            "better_decisions_gamified",
            "lockout_gamified",
            "player.sr_notifications",
            "player.sr_badges",
            "player.sr_confetti",
        ]
    ].mean()

    metadata.to_csv("../data_processed/self_reflection_uoft.csv")

else:
    metadata = pd.read_csv("../data_prolific/trader_metadata.csv", index_col=0)

    metadata["prefer_gamified"] = np.where(
        metadata["player.sr_prefs"] == "Design 2", 1, 0
    )
    metadata["better_decisions_gamified"] = np.where(
        metadata["player.sr_better_decs"] == "Design 2", 1, 0
    )
    metadata["lockout_gamified"] = np.where(
        metadata["player.sr_better_have_option"] == "Only trade on Design #1", 1, 0
    )

    metadata.groupby("player.inner_name")[
        [
            "prefer_gamified",
            "better_decisions_gamified",
            "lockout_gamified",
            "player.sr_notifications",
            "player.sr_badges",
            "player.sr_confetti",
        ]
    ].mean()

    metadata.to_csv("../data_processed/self_reflection.csv")
