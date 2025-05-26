'use client'
import React, { useState } from 'react'

import { Challenge, ChallengeCard } from '@/components/sections/feed/challenges/ChallengeCard'
import { ChallengesFilter } from '@/components/sections/feed/challenges/ChallengesFilter'
import { Brain, BookOpen, Activity } from 'lucide-react'  // Imports necesarios

export default function ChallengesPage() {
  const allChallenges: Challenge[] = [
    {
      id: '1',
      title: 'Meditación matutina',
      description: 'Medita durante 10 minutos al despertar',
      difficulty: 'Fácil',
      duration: '8 horas',
      reward: 50,
      icon: <Brain className="w-6 h-6 text-blue-500" />,
    },
    {
      id: '2',
      title: 'Lectura diaria',
      description: 'Lee 20 páginas de un libro de desarrollo personal',
      difficulty: 'Medio',
      duration: 'Todo el día',
      reward: 75,
      icon: <BookOpen className="w-6 h-6 text-purple-500" />,
    },
    {
      id: '3',
      title: 'Ejercicio físico',
      description: 'Realiza 30 minutos de actividad física',
      difficulty: 'Medio',
      duration: 'Todo el día',
      reward: 100,
      icon: <Activity className="w-6 h-6 text-green-500" />,
    },
    // …otros retos
  ]

  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState<'Todas'|'Fácil'|'Medio'|'Difícil'>('Todas')

  const filtered = allChallenges
    .filter((c) => (filter === 'Todas' ? true : c.difficulty === filter))
    .filter((c) => c.title.toLowerCase().includes(search.toLowerCase()))

  return (
    <main className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">
          Retos{' '}
          <span className="inline-block bg-green-500 text-white px-2 text-xs rounded-full">
            {allChallenges.length}
          </span>
        </h1>
        <a href="/feed" className="text-sm text-purple-600 hover:underline">
          Ver todos
        </a>
      </div>

      {/* Filtro */}
      <ChallengesFilter
        search={search}
        onSearch={setSearch}
        filter={filter}
        onFilter={setFilter}
      />

      {/* Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {filtered.map((c) => (
          <ChallengeCard key={c.id} challenge={c} />
        ))}
      </div>
    </main>
  )
}
