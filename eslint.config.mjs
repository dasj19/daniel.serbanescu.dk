import js from "@eslint/js";

export default [
    js.configs.recommended,
    {
        files: ["script/**/*.js"],
        languageOptions: {
            sourceType: "module",
            // Browser globals the scripts use. Add new ones here as needed.
            globals: {
                Audio: "readonly",
                console: "readonly",
                document: "readonly",
            },
        },
    },
];
