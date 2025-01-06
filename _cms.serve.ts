import serve from "lume/cms/server/proxy.ts";

const username = Deno.env.get("AUTH_USERNAME") || "admin";
const password = Deno.env.get("AUTH_PASSWORD") || "demo";

export default serve({
  serve: "_cms.lume.ts",
  git: true,
  auth: {
    method: "basic",
    users: {
      [username]: password,
    },
  },
  env: {
    LUME_LOGS: "error",
  }
});