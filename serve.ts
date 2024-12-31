import Server from "lume/core/server.ts";
import onDemand from "lume/middlewares/on_demand.ts";
import site from "./_config.ts";
import { redirects, notFound, cacheBusting } from "./src/_lib/middleware.ts";

const server = new Server({
  root: `${Deno.cwd()}/_site`,
  port: 3000,
});

server.use(redirects);
server.use(onDemand({ site }));
server.use(notFound());
server.use(cacheBusting());

server.start();

console.log("Listening on http://localhost:3000");