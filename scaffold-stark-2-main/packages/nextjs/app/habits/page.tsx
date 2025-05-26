'use client'
import React, { useState } from 'react'
import { HabitSummary } from '@/components/sections/feed/habits/HabitSummary'
import { HabitGroup } from '@/components/sections/feed/habits/HabitGroup'
import { Button } from '@/components/ui/button'
import {
  Brain,
  BookOpen,
  Activity,
  Droplet,
  Sun,
  Moon,
} from 'lucide-react'
import { Habit } from '@/components/sections/feed/habits/HabitCard'

export default function HabitsPage() {
  // Datos de ejemplo: reemplaza por tu API o estado global
  const summary = {
    streak: 10,
    dailyCompleted: 3,
    dailyTotal: 6,
    activeHabits: 6,
  }

  const morningHabits: Habit[] = [
    {
      id: '1',
      title: 'Meditación matutina',
      description: 'Medita durante 10 minutos al despertar',
      time: '07:00',
      completedDays: 15,
      totalDays: 30,
      streak: 7,
      tokens: 50,
      icon: <Brain className="w-6 h-6 text-blue-500" />,
      completed: true,
    },
    {
      id: '2',
      title: 'Lectura diaria',
      description: 'Lee 20 páginas de un libro de desarrollo personal',
      time: '08:30',
      completedDays: 12,
      totalDays: 30,
      streak: 5,
      tokens: 75,
      icon: <BookOpen className="w-6 h-6 text-purple-500" />,
      completed: false,
    },
  ]

  const eveningHabits: Habit[] = [
    {
      id: '3',
      title: 'Ejercicio físico',
      description: 'Realiza 30 minutos de actividad física',
      time: '17:00',
      completedDays: 8,
      totalDays: 30,
      streak: 3,
      tokens: 100,
      icon: <Activity className="w-6 h-6 text-green-500" />,
      completed: false,
    },
    {
      id: '4',
      title: 'Agua saludable',
      description: 'Bebe 2 litros de agua durante el día',
      time: 'Todo el día',
      completedDays: 18,
      totalDays: 30,
      streak: 10,
      tokens: 40,
      icon: <Droplet className="w-6 h-6 text-cyan-500" />,
      completed: false,
    },
  ]

  return (
    <main className="p-6 space-y-6">
      {/* 1. Resumen superior */}
      <HabitSummary {...summary} />

      {/* 2. botón para crear nuevo hábito */}
      <div className="flex justify-end">
        <Button className="bg-gradient-to-r from-blue-500 to-purple-500 text-white">
          + Nuevo hábito
        </Button>
      </div>

      {/* 3. Mis hábitos */}
      <h1 className="text-2xl font-semibold">Mis hábitos</h1>
      <HabitGroup title="Hábitos matutinos" icon={<Sun className="w-6 h-6 text-yellow-500" />} habits={morningHabits} />
      <HabitGroup title="Hábitos vespertinos" icon={<Moon className="w-6 h-6 text-gray-500" />} habits={eveningHabits} />
    </main>
  )
}