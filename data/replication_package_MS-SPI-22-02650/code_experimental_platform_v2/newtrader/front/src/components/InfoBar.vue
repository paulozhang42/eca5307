<template>
  <v-row class="mx-1">
    <v-col cols="6">
      <pill label=" Purchase price" :value="market.purchasePrice !== null ? market.purchasePrice : 'NA'"></pill>
    </v-col>
    <v-col cols="6">

      <pill label="Profit" :value="market.profit !== null ? market.profit : 'NA'"></pill>
    </v-col>
  </v-row>
</template>

<script>
import Pill from "./Pill";
import _ from 'lodash'
export default {
  props: ['market'],
  components: { Pill },
  data() {
    return {};
  },

  methods: {},
};
</script>
