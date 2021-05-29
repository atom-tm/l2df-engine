window.matchMedia = window.matchMedia || function() {
  return {
    matches: false,
    addListener: function() { },
    removeListener: function() { }
  };
};
(function() {
  var btn = document.querySelector(".theme");
  var html = document.documentElement;
  var prefersDarkScheme = window.matchMedia("(prefers-color-scheme: dark)");
  var currentTheme = localStorage.getItem("theme");
  if (currentTheme == "dark") {
    html.setAttribute("data-theme", "dark");
    btn.classList.toggle("dark");
  } else if (currentTheme == "light") {
    html.setAttribute("data-theme", "light");
    btn.classList.toggle("light");
  } else if (prefersDarkScheme.matches) {
    html.setAttribute("data-theme", "dark");
    btn.classList.toggle("dark");
  } else {
    html.setAttribute("data-theme", "light");
    btn.classList.toggle("light");
  }
  btn.addEventListener("click", function () {
    var theme = html.attributes['data-theme'];
    if (prefersDarkScheme.matches) {
      theme = theme == undefined || theme.value == "dark"
        ? "light"
        : "dark";
    } else {
      theme = theme == undefined || theme.value == "light"
        ? "dark"
        : "light";
    }
    btn.classList.toggle("dark");
    btn.classList.toggle("light");
    localStorage.setItem("theme", theme);
    html.setAttribute("data-theme", theme);
  });
})();