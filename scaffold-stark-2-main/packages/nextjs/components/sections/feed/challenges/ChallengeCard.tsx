// components/sections/challenges/ChallengeCard.tsx
import React from 'react'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Brain, BookOpen, Activity } from 'lucide-react'  // <–– íconos que usarás

export interface Challenge {
  id: string
  title: string
  description: string
  difficulty: 'Fácil' | 'Medio' | 'Difícil'
  duration: string
  reward: number
  icon: React.ReactNode
}

export function ChallengeCard({ challenge }: { challenge: Challenge }) {
  return (
    <Card className="p-4 space-y-2">
      <div className="flex justify-between items-start">
        <div className="flex items-center gap-2">
          {/* Si challenge.icon viene predefinido, úsalo; si no, puedes hacer un switch */}
          {challenge.icon}
          <h3 className="font-semibold">{challenge.title}</h3>
        </div>
        <span className="uppercase text-xs bg-gray-100 px-2 py-0.5 rounded-full">
          {challenge.difficulty}
        </span>
      </div>
      <p className="text-sm text-zinc-700">{challenge.description}</p>
      <div className="flex items-center gap-4 text-xs text-zinc-500">
        <span className="flex items-center gap-1">
          {/* Aquí podrías reemplazar por un icono de reloj si quieres */}
          🕒 {challenge.duration}
        </span>
        <span className="flex items-center gap-1 text-green-600">
          ⚡ {challenge.reward} tokens
        </span>
      </div>
      <Button className="w-full bg-gradient-to-r from-blue-500 to-purple-500 text-white">
        Comenzar
      </Button>
    </Card>
  )
}
