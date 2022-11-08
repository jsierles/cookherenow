module.exports = {
  mode: "jit",
  purge: ["./app/views/**/*.html.erb", "./app/helpers/*.rb"],
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
};
