import React from 'react'
import Image from 'next/image'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Users } from 'lucide-react'

export interface Community {
  id: string
  name: string
  category: string
  description: string
  members: number
  type: 'Gratuitas' | 'Premium'
  price?: string         // Ej: "$29.99/mes"
  image?: string         // Ruta en /public, opcional
}

export function CommunityCard({ community }: { community: Community }) {
  return (
    <Card
      className={`overflow-hidden rounded-lg border-2 \$
        {community.type === 'Premium' ? 'border-yellow-400 bg-yellow-50' : ''}`}
    >
      {/* Imagen superior */}
      <div className="relative h-40 bg-gray-200">
        {community.image && (
          <Image
            src={community.image}
            alt={community.name}
            fill
            className="object-cover"
          />
        )}
      </div>

      <div className="p-4 space-y-2">
        {/* Badge Premium */}
        {community.type === 'Premium' && (
          <span className="inline-block bg-yellow-400 text-white text-xs font-medium px-2 py-1 rounded-full">
            Premium
          </span>
        )}

        {/* Título y categoría */}
        <h3 className="text-lg font-semibold">{community.name}</h3>
        <p className="text-xs uppercase text-zinc-500">{community.category}</p>

        {/* Descripción */}
        <p className="text-sm text-zinc-700">{community.description}</p>

        {/* Miembros */}
        <div className="flex items-center gap-1 text-xs text-zinc-600">
          <Users className="w-4 h-4" />
          <span>{community.members} miembros</span>
        </div>

        {/* Botón de acción */}
        <Button
          className={`w-full mt-2 \$
            {community.type === 'Premium'
              ? 'bg-yellow-400 hover:bg-yellow-500 text-white'
              : 'bg-gradient-to-r from-blue-500 to-purple-500 text-white'
          }`}
        >
          {community.type === 'Premium'
            ? `Unirse (${community.price})`
            : 'Unirse'}
        </Button>
      </div>
    </Card>
  )
}