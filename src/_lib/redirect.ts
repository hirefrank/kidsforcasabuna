import redirects from "lume/middlewares/redirects.ts";

export const definitions = {};

export default redirects({
  redirects: definitions as Record<string, string | {
    to: string;
    code: 301 | 302 | 303 | 307 | 308 | 200;
  }>,
  strict: false,
})