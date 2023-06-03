function setupTrophyToggling() {
  const expandIcons = document.querySelectorAll(".min-max-trophies");

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
