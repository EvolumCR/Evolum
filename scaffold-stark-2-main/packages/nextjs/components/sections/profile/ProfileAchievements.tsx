import React from 'react'
import { Card } from '@/components/ui/card'
import { Trophy } from 'lucide-react'

interface Achievement {
  id: string
  title: string
  iconUrl: string
}

export function ProfileAchievements({ achievements }: { achievements: Achievement[] }) {
  return (
    <Card className="p-4 mt-6">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold">Logros recientes</h2>
        <a href="#" className="text-sm text-purple-600 hover:underline">
          Ver todos
        </a>
      </div>
      <div className="flex space-x-4 overflow-x-auto">
        {achievements.map(a => (
          <div key={a.id} className="flex flex-col items-center">
            <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center">
              <img src={a.iconUrl} alt={a.title} className="w-8 h-8" />
            </div>
            <p className="mt-2 text-sm text-center">{a.title}</p>
          </div>
        ))}
      </div>
    </Card>
  )
}