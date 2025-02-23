function setupTrophyToggling() {
  const expandAllIcon = document.querySelector("h2 .min-max-trophies");
  expandAllIcon.addEventListener("click", function() {
    uls = document.querySelectorAll(".content_bulk ul")

    uls.forEach(function (ul) {
      ul.classList.toggle("collapsed");
    });
  });

  const expandIcons = document.querySelectorAll("h3 .min-max-trophies");
  expandIcons.forEach(function (expandIcon) {
    expandIcon.addEventListener("click", function() {
      section = expandIcon.closest("section");
      uls = section.querySelectorAll("ul")

      uls.forEach(function (ul) {
        ul.classList.toggle("collapsed");
      });
    });
  });

}

document.addEventListener("DOMContentLoaded", function () {
  setupTrophyToggling();
});
