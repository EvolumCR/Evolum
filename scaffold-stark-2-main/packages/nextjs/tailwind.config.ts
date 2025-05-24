
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
        primary: "#794BFC",       // botón y acento
        secondary: "#F4F1FD",     // fondo claro
        accent: "#8B45FD",        // gradientes y badges
        success: "#34EEB6",       // tokens, hábitos y badges success
        info: "#7DD3FC",
        warning: "#FFCF72",
        error: "#FF8863",
        grayLight: "#F9FAFB",     // fondos suaves
        muted: "#F3F4F6",         // bg general
      },
      borderRadius: {
        xl: "1rem",
        "2xl": "1.25rem",
      },
      boxShadow: {
        card: "0 2px 12px rgba(0, 0, 0, 0.05)",
      },
      fontFamily: {
        // variable que seteamos en layout con next/font
        tinos: ["var(--font-tinos)", "serif"],
        sans: ["Inter", "ui-sans-serif", "system-ui"],
      },
      backgroundImage: {
        "gradient-primary": "linear-gradient(90deg, #794BFC 0%, #8B45FD 100%)",
        "page-pattern": "linear-gradient(135deg, rgba(121,75,252,0.05) 0%, rgba(139,69,253,0.05) 100%)",
      },
      animation: {
        "pulse-fast": "pulse 1s ease-in-out infinite",
      },
    },
  },
  plugins: [
    // si aún usas daisyUI, mantenlo aquí. Sino quita este bloque para simplificar.
    require("daisyui"),
  ],
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
