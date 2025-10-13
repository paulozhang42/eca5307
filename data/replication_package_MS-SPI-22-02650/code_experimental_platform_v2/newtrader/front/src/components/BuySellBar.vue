<template>
  <v-sheet outlined class=" rounded-lg" >
    <v-list-item>
      <v-list-item-content>
         
          <v-btn large @click="clickBuy" :color="colorBuy" :disabled="!btnEnabled('buy')"
          >Buy</v-btn
        >
        <v-btn large @click="clickSell" :color="colorSell" :disabled="!btnEnabled('sell')"
          >Sell</v-btn
        >
         
        </v-list-item-content>
        </v-list-item>
        
      </v-sheet>

</template>

<script>
import "vuetify/dist/vuetify.min.css";
import Pill from "./Pill";
import { mapGetters, mapState , mapActions} from "vuex";
export default {
  props: ["market"],
  components: { Pill },
  data() {
    return {};
  },
  computed: {
    ...mapGetters(["isTransactionAllowed", 'hedonic']),
    
    colorSell() {
      return this.$isHedonic ? "red" : "";
    },
    colorBuy() {
      return this.$isHedonic ? "green" : "";
    },
  },
  methods: {
    ...mapActions(["setPrice", "purchase", "sell"]),
    btnEnabled(btn) {
      return this.isTransactionAllowed(this.market.name, btn);
    },

    clickSell() {
      this.sell({ market: this.market.name });
      // this.$emit("sell");
    },
    clickBuy() {
      this.purchase({ market: this.market.name });
      // this.$emit("buy");
    },
  },
};
</script>
