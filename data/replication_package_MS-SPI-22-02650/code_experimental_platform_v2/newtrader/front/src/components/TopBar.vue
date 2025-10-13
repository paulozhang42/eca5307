<template>
  <v-app-bar app clipped-left class="" height="100">
    <monitor></monitor>
    <instructions-dialog></instructions-dialog>
    
    <pill label="Round" :value="getRoundInfo()" class="mx-3"></pill>
    <pill label="Price updates left" v-if="false" :value="getPriceUpdatesLeft()"></pill>
    <pill label="N. transactions" >
      <animated-counter :value="nTransactions()()" :tweenDuration="1000"></animated-counter>
    </pill>

    <v-spacer v-if="$isHedonic"></v-spacer>
    <div
      class="flex-grow-0 flex-shrink-0 d-flex align-center"
      style="height: 100%"
    >
      <award-block v-if="$isHedonic"></award-block>

 
    </div>
    <template #extension>
      <timer
        what-to-do="allowExitPermission"
        :progress-message="''"
        :show-progress="true"
        timer-finish="You may leave the chat now or continue for as long as you like."
        color="blue"
      />
    </template>
  </v-app-bar>
</template>

<script>
import AnimatedCounter from './AnimatedCounter.vue';
import InstructionsDialog from "./InstructionsDialog";
import Timer from "./TickProgress";
import AwardBlock from "./AwardBlock";
import Pill from "./Pill";
import { mapState, mapMutations, mapGetters } from "vuex";
import Monitor from "./Monitor";
export default {
  components: {
    AnimatedCounter,
    InstructionsDialog,
    AwardBlock,
    Pill,
    Timer,
    Monitor,
  },
  data() {
    return {};
  },
  computed: {
    ...mapState({  counter: "counter" }),
   
  },
  methods: {
   
    ...mapGetters(["nTransactions", 'hedonic']),
    getRoundInfo() {
      
      return `${window.round_number} out of ${window.num_rounds}`;
    },
    getPriceUpdatesLeft() {
      return `${window.window.initialPricesA.length - this.counter} `;
    },
  },
};
</script>
