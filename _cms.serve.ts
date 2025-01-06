import serve from "lume/cms/server/proxy.ts";

// const username = Deno.env.get("AUTH_USERNAME") || "kcb";
// const password = Deno.env.get("AUTH_PASSWORD") || "kcb";

export default serve({
  serve: "_cms.lume.ts",
  git: true,
  // auth: {
  //   method: "basic",
  //   users: {
  //     [username]: password,
  //   },
  // },
  env: {
    LUME_LOGS: "error",
  }
});