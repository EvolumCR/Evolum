import { DailyChallenges } from "@/components/sections/feed/DailyChallenges"
import { DailyProgress } from "@/components/sections/feed/DailyProgress"
import { UserSummary } from "@/components/sections/feed/UserSummary"
import { RecentActivity } from "@/components/sections/feed/RecentActivity"
import { RecentAchievements } from "@/components/sections/feed/RecentAchievements"
import { Card } from "@/components/ui/card"
import { BoltIcon, FlameIcon } from "lucide-react"

export default function FeedPage() {
  return (
    <div className="p-6 space-y-6">
      {/* Top summary row */}
      <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <Card className="p-4 flex items-center gap-4">
          <BoltIcon className="w-6 h-6 text-blue-500" />
          <div>
            <p className="text-xs text-zinc-500">Tokens ganados</p>
            <p className="text-xl font-semibold">1,250</p>
          </div>
        </Card>
        <Card className="p-4 flex items-center gap-4">
          <FlameIcon className="w-6 h-6 text-purple-500" />
          <div>
            <p className="text-xs text-zinc-500">Racha actual</p>
            <p className="text-xl font-semibold">7 días</p>
          </div>
        </Card>
        <DailyProgress completed={3} total={4} />
      </section>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-2 space-y-6">
          <DailyChallenges />
          
          <RecentActivity />
        </div>
        <div className="space-y-6">
          <UserSummary />
          <RecentAchievements />
        </div>
      </div>
    </div>
  )
}
