<template>
  <div class="d-flex">
    <div v-for="(award, ind) in awards" :key="ind" class="d-flex flex-column">
      <transition
        enter-active-class="animate__animated animate__flipInX animate__slow"
      >
        <v-img
          style="width: 80px"
          contain
          :key="getAward(award)"
          :src="getAward(award)"
          class="mx-3"
        ></v-img>
      </transition>
      <div class="text-center font-weight-bold">{{ awardSubtitle(ind) }}</div>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
export default {
  components: {},
  data() {
    return {};
  },
  computed: {
    ...mapState(["awards", "awardTrades"]),
  },
  methods: {
    getAward(award) {
      return award.lock ? award.locked : award.unlocked;
    },
    awardSubtitle(ind) {
      const nTrans = this.awardTrades[ind];
      const mult = nTrans === 1 ? "" : "s";
      return `${nTrans} trade${mult}`;
    },
  },
};
</script>
