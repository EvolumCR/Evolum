"use client"

import { Card } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Button } from "@/components/ui/button"
import Image from "next/image"

export const UserSummary = () => {
  return (
    <Card className="p-4 flex flex-col gap-4">
      <div className="bg-gradient-to-r from-indigo-500 to-purple-500 h-16 rounded-t-md" />

      <div className="-mt-10 flex flex-col items-center">
        <div className="w-20 h-20 rounded-full border-4 border-white shadow-md bg-zinc-200 relative overflow-hidden">
          {/* Profile image */}
          <Image src="/avatar-placeholder.png" alt="Avatar" fill className="object-cover" />
        </div>
        <h3 className="mt-2 text-lg font-semibold">Ana Martínez</h3>
        <p className="text-sm text-zinc-500">@anamartinez</p>

        <div className="flex gap-2 mt-2">
          <Badge variant="secondary" className="bg-green-500 text-white text-xs">Level 12</Badge>
          <Badge variant="secondary" className="bg-purple-500 text-white text-xs">Explorer</Badge>
        </div>
      </div>

      <div className="px-4">
        <p className="text-xs text-zinc-500">Progress to level 13</p>
        <Progress value={65} className="h-2 mt-1" />
      </div>

      <div className="flex justify-around mt-2 text-center text-sm">
        <div>
          <p className="font-bold text-zinc-700">42</p>
          <p className="text-zinc-500 text-xs">Challenges</p>
        </div>
        <div>
          <p className="font-bold text-zinc-700">18</p>
          <p className="text-zinc-500 text-xs">Habits</p>
        </div>
        <div>
          <p className="font-bold text-zinc-700">156</p>
          <p className="text-zinc-500 text-xs">Followers</p>
        </div>
      </div>

      <Button className="w-full mt-4 bg-gradient-to-r from-indigo-500 to-purple-500 text-white">
        Edit profile
      </Button>
    </Card>
  )
}
