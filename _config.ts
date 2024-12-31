import lume from "lume/mod.ts";
import plugins from "./src/_lib/plugins.ts";
import { redirects, notFound } from "./src/_lib/middleware.ts";

const site = lume({
  src: "./src",
  location: new URL("https://www.kidsforcasabuna.com/"),
  server: {
    middlewares: [
        redirects,
        notFound(),
    ],
  },
});

site.data('cacheBusterVersion', '');

site.data("site", {
  title: "Frank Harris",
  name: "hirefrank",
  description: "Frank Harris's personal website.",
});

site.use(plugins());

export default site;