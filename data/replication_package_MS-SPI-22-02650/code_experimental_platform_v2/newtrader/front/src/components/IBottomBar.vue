<template>
  <div class="text-center d-flex justify-center align-center" >
    <v-snackbars :objects="objects" top center>
      <template v-slot:default="{ message }">
        <transition appear enter-active-class="animate__animated animate__bounce "
          leave-active-class="animate__animated animate__slideOutDown animate__slow">
              <h3 class="mb-2">{{ message }}</h3>
        </transition>
      </template>
    </v-snackbars>
  </div>
</template>

<script>
import VSnackbars from "v-snackbars";
import { mapState, mapMutations, mapGetters } from "vuex";
export default {
  components: {
    "v-snackbars": VSnackbars,
  },
  data() {
    return {};
  },
  computed: {
    objects: {
      get() {
        return this.snackMessages;
      },
      set(newValue) {
        this.removeSnackMessage(newValue);
      },
    },
    ...mapState({ objects: "snackMessages" }),
  },
  mounted() { },
  methods: {
    ...mapMutations({ removeSnackMessage: "REMOVE_SNACK_MESSAGE" }),
  },
};
</script>
