const path = require("path");

module.exports = {
  lintOnSave: false,
  pages: {
    main: {
      entry: "./src/main.js",
      chunks: ["chunk-vendors"],
    },
  },
  // Should be STATIC_URL + path/to/build
  publicPath: "/static/front/",

  // Output to a directory in STATICFILES_DIRS
  outputDir: path.resolve(__dirname, "../_static/front/"),

  // Django will hash file names, not webpack
  filenameHashing: false,

  productionSourceMap: false,
  // See: https://vuejs.org/v2/guide/installation.html#Runtime-Compiler-vs-Runtime-only
  runtimeCompiler: true,

  devServer: {
    writeToDisk: true, // Write files to disk in dev mode, so Django can serve the assets
  },

  transpileDependencies: ["vuetify"],
};
