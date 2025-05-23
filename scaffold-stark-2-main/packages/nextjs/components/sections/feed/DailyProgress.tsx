"use client"

import { Progress } from "@/components/ui/progress"

type DailyProgressProps = {
  completed: number
  total: number
}

export function DailyProgress({ completed, total }: DailyProgressProps) {
  const progressPercent = Math.round((completed / total) * 100)

  return (
    <section>
      <h2 className="text-lg font-semibold mb-2">Progreso diario</h2>
      <Progress value={progressPercent} />
      <p className="text-sm text-muted-foreground mt-2">
        {completed} de {total} hábitos completados hoy
      </p>
    </section>
  )
}
