'use client'
import React from 'react'
import { ProfileHeader } from '@/components/sections/profile/ProfileHeader'
import { ProfileStats } from '@/components/sections/profile/ProfileStats'
import { ProfileAchievements } from '@/components/sections/profile/ProfileAchievements'


export default function ProfilePage() {
  // Reemplaza con datos reales de tu API
  const user = {
    name: 'Ana Martínez',
    username: '@anamartinez',
    level: 12,
    role: 'Explorador',
    avatarUrl: '/profilePic.png',
    progress: 65,
  }
  const stats = {
    challengesCompleted: 42,
    activeHabits: 18,
    followers: 156,
  }
  const achievements = [
    { id: '1', title: 'Madrugador', iconUrl: '/achievements/early-riser.png' },
    { id: '2', title: 'Mente clara', iconUrl: '/achievements/clear-mind.png' },
    // …
  ]
  const activities = [
    { id: '1', text: 'Completaste el reto "Meditación matutina"', timeAgo: 'Hace 2 días', type: 'reto' },
    { id: '2', text: 'Alcanzaste una racha de 7 días en "Lectura diaria"', timeAgo: 'Hace 3 días', type: 'racha' },
    // …
  ]

  return (
    <main className="p-6 space-y-6">
      <ProfileHeader {...user} />
      <ProfileStats {...stats} />
      <ProfileAchievements achievements={achievements} />

    </main>
  )
}