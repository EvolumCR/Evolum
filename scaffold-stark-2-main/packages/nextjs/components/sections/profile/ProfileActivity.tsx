import React from 'react'
import { Card } from '@/components/ui/card'
import { Clock, Trophy, Star } from 'lucide-react'

interface ActivityItem {
  id: string
  text: string
  timeAgo: string
  type: 'reto' | 'racha' | 'logro'
}

export function ProfileActivity({ activities }: { activities: ActivityItem[] }) {
  const iconMap = {
    reto: <Trophy className="w-5 h-5 text-blue-500" />,
    racha: <Star className="w-5 h-5 text-purple-500" />,
    logro: <Trophy className="w-5 h-5 text-green-500" />,
  }

  return (
    <Card className="p-4 mt-6">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold">Actividad reciente</h2>
        <a href="#" className="text-sm text-purple-600 hover:underline">
          Ver todo
        </a>
      </div>
      <ul className="space-y-3">
        {activities.map(item => (
          <li key={item.id} className="flex items-start gap-3">
            <div>{iconMap[item.type]}</div>
            <div>
              <p className="text-sm text-gray-800">{item.text}</p>
              <div className="flex items-center gap-1 text-xs text-gray-500">
                <Clock className="w-3 h-3" />
                <span>{item.timeAgo}</span>
              </div>
            </div>
          </li>
        ))}
      </ul>
    </Card>
  )
}