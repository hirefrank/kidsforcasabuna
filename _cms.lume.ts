import site from "./_config.ts";
import cms from "./_cms.ts";
import adapter from "lume/cms/adapters/lume.ts";


cms.options.auth = undefined;
// site.options.location = new URL("https://www.kidsforcasabuna.com/");

export default await adapter({ site, cms });