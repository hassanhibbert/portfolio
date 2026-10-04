export const ActiveSection = (() => {
  const links = document.querySelectorAll(".toc a");

  return { init };

  function init() {
    if (!links.length || !("IntersectionObserver" in window)) return;

    const observer = new IntersectionObserver(onIntersect, {
      rootMargin: "-40% 0px -55% 0px",
    });

    links.forEach((link) => {
      const section = document.querySelector(link.hash);
      if (section) observer.observe(section);
    });
  }

  function onIntersect(entries) {
    entries
      .filter((entry) => entry.isIntersecting)
      .forEach((entry) => {
        links.forEach((link) =>
          link.classList.toggle("active", link.hash === `#${entry.target.id}`)
        );
      });
  }
})();
