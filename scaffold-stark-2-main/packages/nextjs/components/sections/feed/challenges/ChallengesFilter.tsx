// components/sections/challenges/ChallengesFilter.tsx
import React from 'react'
import { Input } from '@/components/ui/input'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'

export type Difficulty = 'Todas' | 'Fácil' | 'Medio' | 'Difícil'

export interface ChallengesFilterProps {
  search: string
  onSearch: (v: string) => void
  filter: Difficulty
  onFilter: (v: Difficulty) => void
}

export function ChallengesFilter({
  search,
  onSearch,
  filter,
  onFilter,
}: ChallengesFilterProps) {
  const tabs: Difficulty[] = ['Todas', 'Fácil', 'Medio', 'Difícil']

  return (
    <div className="space-y-4">
      <Input
        placeholder="Buscar retos…"
        value={search}
        onChange={(e) => onSearch(e.target.value)}
        className="max-w-md"
      />

      <Tabs value={filter} onValueChange={onFilter} className="w-full">
        <TabsList>
          {tabs.map((difficulty) => (
            <TabsTrigger key={difficulty} value={difficulty}>
              {difficulty}
            </TabsTrigger>
          ))}
        </TabsList>
      </Tabs>
    </div>
  )
}
