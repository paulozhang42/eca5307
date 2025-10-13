<template>
    <div class="text-center">
        <v-dialog v-model="dialog" persistent width="400">
            <v-card>
                <v-card-title class="text-h5 red"> Information </v-card-title>
    
                <v-card-text class="my-3 text-center text-h5">
                    Trade is now allowed! <span v-if="$isHedonic">Complete your trades to earn your badges!</span>
                </v-card-text>
    
                <v-divider></v-divider>
    
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="primary" text @click="closeDialog"> Continue </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </div>
</template>

<script>
import { mapActions, mapMutations } from "vuex";
export default {
    data() {
        return {
            dialog: true,
        };
    },
    mounted() {
        this.PAUSE();
    },
    methods: {
        ...mapActions(["nextTick", "sendMessage"]),
        ...mapMutations(["PAUSE"]),
        closeDialog() {
            this.nextTick();
            this.dialog = false;
        },
    },
};
</script>
