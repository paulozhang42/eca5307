<template>
  <div class="text-center">
    <v-dialog  v-model="dialog" width="800">
      
      <v-card>
        <v-card-title class="text-h5 grey lighten-2">   Purchasing initial stock </v-card-title>

        <v-card-text   class="text-left">
           
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primary"
            text
           
          @click="closeDialog"
          >
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>

export default {
  data() {
    return {
      dialog: false,
      
    };
  },
   
  methods: {
    closeDialog() {
      
      this.dialog = false;
    },
   
  },
};
</script>