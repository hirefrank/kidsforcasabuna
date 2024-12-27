import redirects from "lume/middlewares/redirects.ts";

export const definitions = {
  "/donate": {
    to: "https://www.paypal.com/donate/?hosted_button_id=RGMKR4SU8LN2S",
    code: 301,
  },
};

export default redirects({
  redirects: definitions as Record<string, string | {
    to: string;
    code: 301 | 302 | 303 | 307 | 308 | 200;
  }>,
  strict: false,
})