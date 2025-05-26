import React from 'react'
import { Card } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { Flame, Target, TrendingUp } from 'lucide-react'

interface HabitSummaryProps {
  streak: number
  dailyCompleted: number
  dailyTotal: number
  activeHabits: number
}

export function HabitSummary({ streak, dailyCompleted, dailyTotal, activeHabits }: HabitSummaryProps) {
  const percent = Math.round((dailyCompleted / dailyTotal) * 100)

  return (
    <Card className="p-4 bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Racha actual */}
        <div className="flex items-center gap-4">
          <Flame className="w-6 h-6 text-blue-500" />
          <div>
            <p className="text-xs text-zinc-500">Racha actual</p>
            <p className="text-xl font-semibold">{streak} días</p>
          </div>
        </div>

        {/* Progreso diario */}
        <div className="flex items-center gap-4">
          <Target className="w-6 h-6 text-purple-500" />
          <div>
            <p className="text-xs text-zinc-500">Progreso diario</p>
            <p className="text-xl font-semibold">{percent}% ({dailyCompleted}/{dailyTotal})</p>
          </div>
        </div>

        {/* Hábitos activos */}
        <div className="flex items-center gap-4">
          <TrendingUp className="w-6 h-6 text-green-500" />
          <div>
            <p className="text-xs text-zinc-500">Hábitos activos</p>
            <p className="text-xl font-semibold">{activeHabits}</p>
          </div>
        </div>

        {/* Meta diaria */}
        <div className="space-y-2">
          <div className="flex items-center justify-between text-xs text-zinc-500">
            <span>Meta diaria</span>
            <span>{percent}%</span>
          </div>
          <Progress value={percent} className="h-2 rounded-full bg-gray-200/50" />
          <p className="text-xs text-zinc-500">{dailyCompleted} hábitos completados hoy</p>
        </div>
      </div>
    </Card>
  )
}