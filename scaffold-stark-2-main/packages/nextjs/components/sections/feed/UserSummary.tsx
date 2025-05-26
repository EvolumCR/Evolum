// components/sections/feed/UserSummary.tsx
import React from 'react'
import Image from 'next/image'
import profilePic from '@/public/profilePic.jpg'  
import { Card } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { Button } from '@/components/ui/button'

export function UserSummary() {
  const user = {
    name: 'Ana Martínez',
    username: '@anamartinez',
    level: 12,
    role: 'Explorador',
    challenges: 42,
    habits: 18,
    followers: 156,
    progressToNext: 65,
  }

  return (
    <Card className="overflow-hidden rounded-lg">
      {/* Header gradient */}
      <div className="h-24 bg-gradient-to-r from-blue-500 to-purple-500 rounded-t-lg" />

      <div className="px-4 pt-8 text-center relative">
        {/* Avatar */}
        <div className="absolute -top-10 left-1/2 transform -translate-x-1/2 w-20 h-20 rounded-full overflow-hidden border-4 border-white">
          <Image
            src={profilePic}
            alt={`${user.name} avatar`}
            width={80}
            height={80}
            className="object-cover"
          />
        </div>

        {/* Nombre y usuario */}
        <h3 className="mt-12 font-semibold text-lg">{user.name}</h3>
        <p className="text-xs text-zinc-500">{user.username}</p>

        {/* Badges */}
        <div className="flex justify-center gap-2 mt-2">
          <span className="bg-green-100 text-green-700 px-2 py-0.5 rounded-full text-xs">
            Nivel {user.level}
          </span>
          <span className="border border-purple-200 text-purple-700 px-2 py-0.5 rounded-full text-xs">
            {user.role}
          </span>
        </div>

        {/* Barra de progreso con porcentaje */}
        <div className="mt-4">
          <div className="flex items-center justify-between text-xs mb-1">
            <span>Progress at the level {user.level + 1}</span>
            <span>{user.progressToNext}%</span>
          </div>
          <Progress
            value={user.progressToNext}
            className="h-2 rounded-full bg-gray-200/50"
          />
        </div>

        {/* Estadísticas en tres columnas */}
        <div className="grid grid-cols-3 mt-4 text-center">
          <div>
            <p className="font-semibold">{user.challenges}</p>
            <p className="text-xs text-zinc-500">Retos</p>
          </div>
          <div>
            <p className="font-semibold">{user.habits}</p>
            <p className="text-xs text-zinc-500">Hábitos</p>
          </div>
          <div>
            <p className="font-semibold">{user.followers}</p>
            <p className="text-xs text-zinc-500">Seguidores</p>
          </div>
        </div>

        {/* Botón “Ver perfil” */}
        <div className="mt-4">
          <Button className="w-full bg-gradient-to-r from-blue-500 to-purple-500 text-white">
          View profile
          </Button>
        </div>
      </div>
    </Card>
  )
}
