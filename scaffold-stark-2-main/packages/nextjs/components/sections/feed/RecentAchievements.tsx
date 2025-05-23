import { Card } from "@/components/ui/card"
import { achievements } from "~/data/achievements"

export function RecentAchievements() {
  return (
    <Card className="p-4 space-y-4">
      <h2 className="font-semibold text-lg">Logros recientes</h2>
      {achievements.map((ach, index) => (
        <div key={index} className="flex items-start gap-3">
          <span className="text-2xl">{ach.icon}</span>
          <div>
            <p className="font-medium text-sm">{ach.title}</p>
            <p className="text-xs text-zinc-500">{ach.description}</p>
          </div>
        </div>
      ))}
    </Card>
  )
}
