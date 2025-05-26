import React from 'react'
import { Card } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { Button } from '@/components/ui/button'
import { Clock, Flame, Zap } from 'lucide-react'

export interface Habit {
  id: string
  title: string
  description: string
  time: string
  completedDays: number
  totalDays: number
  streak: number
  tokens: number
  icon: React.ReactNode
  completed: boolean
}

export function HabitCard({ habit }: { habit: Habit }) {
  const percent = Math.round((habit.completedDays / habit.totalDays) * 100)
  return (
    <Card
      className={`p-4 space-y-2 \$\{habit.completed ? 'bg-green-50 border border-green-200' : 'bg-white'\}`}
    >
      {/* Título + hora */}
      <div className="flex justify-between items-start">
        <div className="flex items-center gap-2">
          {habit.icon}
          <h3 className="font-semibold">{habit.title}</h3>
        </div>
        <span className="text-xs text-zinc-500 flex items-center gap-1">
          <Clock className="w-4 h-4" /> {habit.time}
        </span>
      </div>

      {/* Descripción */}
      <p className="text-sm text-zinc-700">{habit.description}</p>

      {/* Progreso diario */}
      <div className="flex items-center justify-between text-xs text-zinc-500">
        <span>Progreso</span>
        <span>
          {habit.completedDays}/{habit.totalDays} días
        </span>
      </div>
      <Progress value={percent} className="h-2 rounded-full bg-gray-200/50" />

      {/* Métricas */}
      <div className="grid grid-cols-2 gap-2">
        <Card className="p-2 flex items-center justify-between">
          <Flame className="w-4 h-4 text-orange-500" />
          <div className="text-right">
            <p className="text-xs text-zinc-500">Racha</p>
            <p className="font-semibold">{habit.streak}</p>
          </div>
        </Card>
        <Card className="p-2 flex items-center justify-between">
          <Zap className="w-4 h-4 text-green-500" />
          <div className="text-right">
            <p className="text-xs text-zinc-500">Tokens</p>
            <p className="font-semibold">{habit.tokens}</p>
          </div>
        </Card>
      </div>

      {/* Acción */}
      <Button
        className={`w-full text-white \$\{habit.completed
          ? 'bg-green-500 hover:bg-green-600'
          : 'bg-gradient-to-r from-blue-500 to-purple-500'
        }`}
      >
        {habit.completed ? 'Completado' : 'Marcar como hecho'}
      </Button>
    </Card>
  )
}