import type { Metadata } from "next"
import { ScaffoldStarkAppWithProviders } from "@/components/ScaffoldStarkAppWithProviders"
import "@/styles/globals.css"
import { ThemeProvider } from "@/components/ThemeProvider"
import { Sidebar } from "@/components/layout/Sidebar"

export const metadata: Metadata = {
  title: "Evolum",
  description: "Red social descentralizada para tu crecimiento personal",
  icons: "/logo.ico",
}

const ScaffoldStarkApp = ({ children }: { children: React.ReactNode }) => {
  return (
    <html suppressHydrationWarning>
      <body suppressHydrationWarning>
        <ThemeProvider enableSystem>
          <ScaffoldStarkAppWithProviders>
            <div className="flex">
              <Sidebar />
              <main className="flex-1 bg-muted/50 min-h-screen">{children}</main>
            </div>
          </ScaffoldStarkAppWithProviders>
        </ThemeProvider>
      </body>
    </html>
  )
}

export default ScaffoldStarkApp
