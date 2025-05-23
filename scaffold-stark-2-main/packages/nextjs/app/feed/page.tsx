import { DailyChallenges } from "@/components/sections/feed/DailyChallenges"
import { DailyProgress } from "@/components/sections/feed/DailyProgress"
import { UserSummary } from "@/components/sections/feed/UserSummary"
import { RecentActivity } from "@/components/sections/feed/RecentActivity"
import { RecentAchievements } from "@/components/sections/feed/RecentAchievements"
import { user } from "@/data/ user" 


export default function FeedPage() {
  return (
    <div className="p-6 space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-2 space-y-6">
          <DailyChallenges />
          <RecentActivity />
        </div>
        <div className="space-y-6">
        <DailyProgress completed={3} total={4} />

          <UserSummary />
          <RecentAchievements />
        </div>
      </div>
    </div>
  )
}
