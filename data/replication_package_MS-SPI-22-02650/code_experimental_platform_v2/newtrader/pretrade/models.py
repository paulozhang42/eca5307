from otree.api import (
    models,
    widgets,
    BaseConstants,
    BaseSubsession,
    BaseGroup,
    BasePlayer,
    Currency as c,
    currency_range,
)
import urllib.request
from django.conf import settings
import yaml
from csv import DictReader

author = 'Philipp Chapkovski, HSE Moscow, chapkovski@gmail.com'

doc = """
Instructions, comprehension check for trader
"""


class Constants(BaseConstants):
    name_in_url = 'pretrade'
    players_per_group = None
    num_rounds = 1


class Subsession(BaseSubsession):
    pass


class Group(BaseGroup):
    pass


class Player(BasePlayer):
    treatment = models.StringField()
    martingale = models.BooleanField()

    def start(self):
        self.treatment = self.participant.vars.get('treatment')
        self.martingale = self.participant.vars.get('martingale')
    consent = models.BooleanField(widget=widgets.CheckboxInput,
                                  label=' By checking this box, I am agreeing to take part in this research study.')
    knowledge = models.IntegerField()

    cq1 = models.StringField(
        label="The stock price just went up. At the next price update,",
        choices=["The stock price is likelier to go up again",
                 "The stock price is likelier to go down",
                 "The stock price is equally likely to go up or down",
                 ],
        widget=widgets.RadioSelect
    )

    cq2 = models.StringField(
        label="If you do not have enough cash to purchase a stock",
        choices=["You cannot purchase it",
                 "You can purchase it, but any negative cash balance is subtracted from your final earnings",
                 "You can purchase it, and any negative cash balance is set to zero at the end of the round",
                 ],
        widget=widgets.RadioSelect
    )

#     cq3 = models.StringField(
#         label="Price change notifications are enabled:",
#         choices=["For both stocks, in all rounds",
#                  "For stock A only, in some rounds",
#                  "For stock A only, in all rounds",
#                  "For stock B only, in some rounds"
#                  ],
#         widget=widgets.RadioSelect
#     )

    cq4 = models.StringField(
        label="Your total bonus payment for the experiment depends on:",
        choices=["The sum of payoffs across all rounds",
                 "Your payoff in a randomly selected round",
                 "Your payoff in a randomly selected round and your correct answers in the post-experimental quiz",
                 ],
        widget=widgets.RadioSelect
    )

    cq5 = models.StringField(
        label="When is the trade count updated?",
        choices=["If your position in the stock changes between two consecutive price updates",
                 "If your position in the stock increases between two consecutive price updates.",
                 "Every time you click the BUY or SELL buttons, even between two consecutive price updates"
                 ],
        widget=widgets.RadioSelect
    )

    def cq1_error_message(self, value):
        if self.martingale:
             if value != "The stock price is equally likely to go up or down":
                return 'Wrong answer!'
        else:
            if value != "The stock price is likelier to go up again":
                return 'Wrong answer!'

    def cq2_error_message(self, value):
        if value != "You can purchase it, but any negative cash balance is subtracted from your final earnings":
            return 'Wrong answer!'

#     def cq3_error_message(self, value):
#         if value != "For stock A only, in some rounds":
#             return 'Wrong answer!'

    def cq4_error_message(self, value):
        if value != 'Your payoff in a randomly selected round and your correct answers in the post-experimental quiz':
            return 'Wrong answer!'

    def cq5_error_message(self, value):
        if value != "If your position in the stock changes between two consecutive price updates":
            return 'Wrong answer!'
