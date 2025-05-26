"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  HomeIcon,
  TrophyIcon,
  CalendarIcon,
  LineChartIcon,
  UsersIcon,
  UserIcon,
  BellIcon,
  MessageSquareIcon,
  SettingsIcon,
  LogOutIcon
} from "lucide-react"

const navItems = [
  { label: "Feed", href: "/feed", icon: <HomeIcon className="w-4 h-4" /> },
  { label: "Retos", href: "/challenges", icon: <TrophyIcon className="w-4 h-4" />, badge: 3 },
  { label: "Hábitos", href: "/habits", icon: <CalendarIcon className="w-4 h-4" /> },
  { label: "Progreso", href: "/progress", icon: <LineChartIcon className="w-4 h-4" /> },
  { label: "Comunidad", href: "/communities", icon: <UsersIcon className="w-4 h-4" />, badge: 5 },
  { label: "Perfil", href: "/profile", icon: <UserIcon className="w-4 h-4" /> },
]

const secondaryItems = [
  { label: "Notificaciones", icon: <BellIcon className="w-4 h-4" /> },
  { label: "Mensajes", icon: <MessageSquareIcon className="w-4 h-4" /> },
  { label: "Configuración", icon: <SettingsIcon className="w-4 h-4" /> },
  { label: "Cerrar sesión", icon: <LogOutIcon className="w-4 h-4" /> },
]

export function Sidebar() {
  const pathname = usePathname()

  return (
    <aside className="w-[260px] bg-white border-r h-screen flex flex-col justify-between py-4">
      <div>
        

        <nav className="space-y-1">
          {navItems.map(({ label, href, icon, badge }) => {
            const isActive = pathname === href
            return (
              <Link
                key={href}
                href={href}
                className={`flex items-center justify-between px-6 py-2 rounded-md text-sm font-medium ${
                  isActive
                    ? "bg-gradient-to-r from-indigo-100 to-purple-100 text-indigo-700"
                    : "hover:bg-zinc-100 text-zinc-700"
                }`}
              >
                <div className="flex items-center gap-2">
                  {icon}
                  {label}
                </div>
                {badge && (
                  <span className="text-xs bg-lime-500 text-white rounded-full px-2 py-0.5">
                    {badge}
                  </span>
                )}
              </Link>
            )
          })}
        </nav>
      </div>

      <div className="space-y-1 px-6 mt-6">
        {secondaryItems.map(({ label, icon }) => (
          <div key={label} className="flex items-center gap-2 text-zinc-500 hover:text-zinc-800 cursor-pointer text-sm py-2">
            {icon}
            {label}
          </div>
        ))}
      </div>
    </aside>
  )
}
