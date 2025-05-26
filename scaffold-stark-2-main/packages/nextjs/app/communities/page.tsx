'use client'
import React, { useState } from 'react'
import { Community, CommunityCard } from '@/components/sections/feed/communities/CommunityCard'
import { CommunityFilter } from '@/components/sections/feed/communities/CommunityFilter'
import { Button } from '@/components/ui/button'

export default function CommunitiesPage() {
  // Datos de ejemplo
  const all: Community[] = [
    {
      id: '1',
      name: 'Meditación Mindfulness',
      category: 'Desarrollo Personal',
      description:
        'Comunidad dedicada a la práctica diaria de meditación y mindfulness para reducir el estrés.',
      members: 1250,
      type: 'Gratuitas',
      image: '/placeholder-community.jpg',
    },
    {
      id: '2',
      name: 'Fitness Elite',
      category: 'Fitness',
      description:
        'Entrenamientos personalizados y rutinas avanzadas con entrenadores certificados.',
      members: 890,
      type: 'Premium',
      price: '$29.99/mes',
      image: '/placeholder-community.jpg',
    },
    // ...más comunidades
  ]

  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState<'Todas' | 'Gratuitas' | 'Premium'>('Todas')

  const filtered = all
    .filter((c) => (filter === 'Todas' ? true : c.type === filter))
    .filter((c) => c.name.toLowerCase().includes(search.toLowerCase()))

  return (
    <main className="p-6 space-y-6">
      {/* Título y botón crear */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Comunidades</h1>
        <Button className="bg-gradient-to-r from-blue-500 to-purple-500 text-white">
          + Crear comunidad
        </Button>
      </div>

      {/* Filtro */}
      <CommunityFilter
        search={search}
        onSearch={setSearch}
        filter={filter}
        onFilter={setFilter}
      />

      {/* Grid de comunidades */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {filtered.map((c) => (
          <CommunityCard key={c.id} community={c} />
        ))}
      </div>
    </main>
  )
}