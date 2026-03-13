function setupTrophyToggling() {
  const expandAllIcon = document.querySelector("h2 .min-max-trophies");
  if (!expandAllIcon) {
    return;
  }

  expandAllIcon.addEventListener("click", function() {
    uls = document.querySelectorAll(".container ul, .card-body ul");

    uls.forEach(function (ul) {
      ul.classList.toggle("collapsed");
    });
  });

  const expandIcons = document.querySelectorAll("h3 .min-max-trophies");
  expandIcons.forEach(function (expandIcon) {
    expandIcon.addEventListener("click", function() {
      section = expandIcon.closest("section, .card-body");
      if (!section) {
        return;
      }
      uls = section.querySelectorAll("ul");

      uls.forEach(function (ul) {
        ul.classList.toggle("collapsed");
      });
    });
  });
}

document.addEventListener("DOMContentLoaded", function () {
  setupTrophyToggling();
});
