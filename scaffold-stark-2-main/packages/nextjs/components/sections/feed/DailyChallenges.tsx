"use client"

import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { BoltIcon, BookOpenIcon, HeartIcon } from "lucide-react"

const challenges = [
  {
    title: "Meditación matutina",
    description: "Medita durante 10 minutos al despertar",
    difficulty: "Fácil",
    icon: <HeartIcon className="w-5 h-5 text-blue-500" />,
    tokens: 50,
  },
  {
    title: "Lectura diaria",
    description: "Lee 20 páginas de un libro de desarrollo personal",
    difficulty: "Medio",
    icon: <BookOpenIcon className="w-5 h-5 text-purple-500" />,
    tokens: 75,
  },
  {
    title: "Ejercicio físico",
    description: "Realiza 30 minutos de actividad física",
    difficulty: "Medio",
    icon: <BoltIcon className="w-5 h-5 text-green-500" />,
    tokens: 100,
  },
]

export function DailyChallenges() {
  return (
    <section>
      <h2 className="text-lg font-semibold mb-2">Retos del día</h2>
      <div className="flex flex-col md:flex-row gap-4">
        {challenges.map((challenge, index) => (
          <Card key={index} className="flex-1 p-4 space-y-2">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                {challenge.icon}
                <span className="text-sm text-muted-foreground">{challenge.difficulty}</span>
              </div>
            </div>
            <h3 className="font-medium">{challenge.title}</h3>
            <p className="text-sm text-muted-foreground">{challenge.description}</p>
            <p className="text-sm text-green-600 font-medium">{challenge.tokens} tokens</p>
            <Button className="mt-2 w-full">Comenzar</Button>
          </Card>
        ))}
      </div>
    </section>
  )
}
