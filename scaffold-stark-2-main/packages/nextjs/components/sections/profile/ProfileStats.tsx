import React from 'react'
import { Card } from '@/components/ui/card'
import { Trophy, Star, Users } from 'lucide-react'

interface ProfileStatsProps {
  challengesCompleted: number
  activeHabits: number
  followers: number
}

export function ProfileStats({
  challengesCompleted,
  activeHabits,
  followers,
}: ProfileStatsProps) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
      <Card className="p-4 flex items-center gap-4">
        <Trophy className="w-6 h-6 text-blue-500" />
        <div>
          <p className="text-sm text-gray-500">Retos completados</p>
          <p className="text-xl font-semibold">{challengesCompleted}</p>
        </div>
      </Card>
      <Card className="p-4 flex items-center gap-4">
        <Star className="w-6 h-6 text-purple-500" />
        <div>
          <p className="text-sm text-gray-500">Hábitos activos</p>
          <p className="text-xl font-semibold">{activeHabits}</p>
        </div>
      </Card>
      <Card className="p-4 flex items-center gap-4">
        <Users className="w-6 h-6 text-green-500" />
        <div>
          <p className="text-sm text-gray-500">Seguidores</p>
          <p className="text-xl font-semibold">{followers}</p>
        </div>
      </Card>
    </div>
  )
}