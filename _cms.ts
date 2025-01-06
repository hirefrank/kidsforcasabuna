import lumeCMS from "lume/cms/mod.ts";
// import GitHub from "lume/cms/storage/github.ts";
// import { Octokit } from "npm:octokit";

// const username = Deno.env.get("AUTH_USERNAME") || "admin";
// const password = Deno.env.get("AUTH_PASSWORD") || "demo";
// const gh_pat = Deno.env.get("GITHUB_PAT") || "";

const cms = lumeCMS({
  site: {
    name: "Kids for Casa Buna CMS",
    description: "Welcome to your site's content management dashboard. Manage and update your website content from one central location.",
    url: "https://kidsforcasabuna.com",
    body: `
    <p>Please note: Content updates may take up to 5-8 minutes to be visible on your live site.</p>
    `,
  },
  // auth: {
  //   method: "basic",
  //   users: {
  //     [username]: password,
  //   },
  // },
});

// cms.storage("gh",
//   new GitHub({
//     client: new Octokit({ auth: gh_pat }),
//     owner: "hirefrank",
//     repo: "kidsforcasabuna",
//     branch: "main",
//   })
// );

cms.upload("images:Here you can manage all images of your posts","src:img");

cms.document({
  name: "Site Information",
  description: "Manage your site's basic settings and general information",
  store: "src:_data/site.yaml",
  fields: [
    "name: text",
    "description: textarea",
    "donate_url: url",
    {
      name: "contact",
      type: "object",
      fields: [
        {
          name: "email",
          type: "text",
        },
        {
          name: "phone",
          type: "text",
        },
      ],
    },
    {
      name: "social",
      type: "object-list",
      fields: [
        {
          name: "name",
          type: "text",
        },
        {
          name: "url",
          type: "text",
        },
      ],
    },
  ],
});

cms.document({
  name: "Hero Content",
  description: "Update the main banner section displayed on your homepage",
  store: "src:_data/hero.yaml",
  fields: [
    {
      name: "title",
      type: "text",
    },
    {
      name: "description",
      type: "textarea",
    },
    {
      name: "cta",
      type: "object",
      fields: [
        {
          name: "text",
          type: "text",
        },
        {
          name: "url",
          type: "url",
        },
      ],
    },
    {
      name: "secondary_cta",
      type: "object",
      fields: [
        {
          name: "text",
          type: "text",
        },
        {
          name: "url",
          type: "url",
        },
      ],
    },
  ],
});


cms.document({
  name: "About Us",
  description: "Customize your organization's story and mission",
  store: "src:about.md",
  fields: [
    "title: text",
    "content: markdown",
  ],
});

cms.document({
  name: "Initiatives",
  description: "Manage and update your program information and current projects",
  store: "src:_data/initiatives.yaml",
  fields: [
    {
      name: "title",
      type: "text",
    },
    {
      name: "description",
      type: "textarea",
    },
    {
      name: "items",
      type: "object-list",
      fields: [
        {
          name: "title",
          type: "text",
        },
        {
          name: "description",
          type: "textarea",
        },
        {
          name: "image",
          type: "file",
        },
      ],
    },
  ],
});

cms.collection({
  name: "Blog Posts",
  description: "Manage and edit your blog posts",
  store: "src:blog/*.md",
  fields: [
    "title: text!",
    {
      name: "author",
      type: "text",
      value: "Ionela Thomas",
      attributes: {
        required: true,
      },
    },
    "excerpt: textarea!",
    {
      name: "date",
      type: "datetime",
      value: new Date(),
      attributes: {
        required: true,
      },
    },
    "content: markdown",
    "tags: list",
  ],
  nameField: "title",
});

export default cms;
