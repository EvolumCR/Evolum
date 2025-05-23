import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#794BFC", // botón y acento principal
        secondary: "#F4F1FD", // fondo claro
        accent: "#8B45FD", // gradientes y badges
        success: "#B6F58E", // tokens ganados / hábitos completos
        info: "#7DD3FC",
        warning: "#FFCF72",
        error: "#FF8863",
        grayLight: "#F9FAFB",
      },
      borderRadius: {
        xl: "1rem",
        "2xl": "1.25rem",
      },
      boxShadow: {
        card: "0 2px 12px rgba(0,0,0,0.05)",
      },
      fontFamily: {
        sans: ["Inter", "ui-sans-serif", "system-ui"],
      },
      backgroundImage: {
        "gradient-primary": "linear-gradient(90deg, #794BFC 0%, #8B45FD 100%)",
      },
      animation: {
        "pulse-fast": "pulse 1s cubic-bezier(0.4, 0, 0.6, 1) infinite",
      },
    },
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: [
      {
        evolum: {
          primary: "#794BFC",
          secondary: "#F4F1FD",
          accent: "#8B45FD",
          neutral: "#212638",
          "base-100": "#ffffff",
          info: "#7DD3FC",
          success: "#34EEB6",
          warning: "#FFCF72",
          error: "#FF8863",
        },
      },
    ],
  },
};

export default config;
