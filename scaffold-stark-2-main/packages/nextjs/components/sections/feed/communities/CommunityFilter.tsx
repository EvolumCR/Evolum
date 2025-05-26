import React from 'react'
import { Input } from '@/components/ui/input'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'

export type CommunityType = 'Todas' | 'Gratuitas' | 'Premium'

export interface CommunityFilterProps {
  search: string
  onSearch: (v: string) => void
  filter: CommunityType
  onFilter: (v: CommunityType) => void
}

export function CommunityFilter({
  search,
  onSearch,
  filter,
  onFilter,
}: CommunityFilterProps) {
  const tabs: CommunityType[] = ['Todas', 'Gratuitas', 'Premium']

  return (
    <div className="space-y-4">
      {/* Buscador */}
      <Input
        placeholder="Buscar comunidades por nombre o tema..."
        value={search}
        onChange={(e) => onSearch(e.target.value)}
        className="max-w-lg"
      />

      {/* Pestañas de tipo */}
      <Tabs value={filter} onValueChange={onFilter} className="w-full">
        <TabsList>
          {tabs.map((t) => (
            <TabsTrigger key={t} value={t}>
              {t}
            </TabsTrigger>
          ))}
        </TabsList>
      </Tabs>
    </div>
  )
}