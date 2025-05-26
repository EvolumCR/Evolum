import React from 'react'
import { Habit, HabitCard } from './HabitCard'
import { Card } from '@/components/ui/card'

export function HabitGroup({
  title,
  icon,
  habits,
}: {
  title: string
  icon: React.ReactNode
  habits: Habit[]
}) {
  const completedCount = habits.filter((h) => h.completed).length
  return (
    <section className="space-y-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          {icon}
          <h2 className="text-lg font-semibold">{title}</h2>
          <span className="text-xs bg-gray-100 px-2 py-0.5 rounded-full">
            {completedCount}/{habits.length}
          </span>
        </div>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {habits.map((h) => (
          <HabitCard key={h.id} habit={h} />
        ))}
      </div>
    </section>
  )
}