import React from 'react'
import { StaticImageData } from 'next/image'
// Si importas la imagen estática, puedes tiparla como StaticImageData
import Image from 'next/image'
import { Button } from '@/components/ui/button'
import { Edit3 } from 'lucide-react'

interface ProfileHeaderProps {
  name: string
  username: string
  level: number
  role: string
  avatarUrl: string
  progress: number
}

export function ProfileHeader({
  name,
  username,
  level,
  role,
  avatarUrl,
  progress,
}: ProfileHeaderProps) {
  return (
    <div className="relative overflow-hidden rounded-lg bg-white shadow">
      <div className="h-32 bg-gradient-to-r from-blue-500 to-purple-500" />
      <div className="px-6 pt-6 flex flex-col md:flex-row md:items-center md:justify-between">
        <div className="flex items-center">
          <div className="relative -mt-16 w-32 h-32 rounded-full border-4 border-white overflow-hidden">
            <Image
              src={avatarUrl}
              alt={`${name} avatar`}
              fill
              className="object-cover"
            />
          </div>
          <div className="ml-4 mt-2 md:mt-0">
            <h1 className="text-2xl font-semibold text-gray-900">{name}</h1>
            <p className="text-sm text-gray-500">{username}</p>
            <div className="flex items-center gap-2 mt-2">
              <span className="bg-green-100 text-green-800 px-2 py-0.5 rounded-full text-xs">
                Nivel {level}
              </span>
              <span className="bg-purple-100 text-purple-800 px-2 py-0.5 rounded-full text-xs">
                {role}
              </span>
            </div>
          </div>
        </div>
        <Button className="mt-4 md:mt-0 bg-gradient-to-r from-blue-500 to-purple-500 text-white">
          <Edit3 className="w-4 h-4 mr-2" /> Editar perfil
        </Button>
      </div>
      <div className="px-6 pb-6">
        <div className="flex items-center justify-between text-sm text-gray-500 mb-1">
          <span>Progreso al nivel {level + 1}</span>
          <span>{progress}%</span>
        </div>
        <div className="h-2 bg-gray-200 rounded-full">
          <div
            className="h-2 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full"
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>
    </div>
  )
}