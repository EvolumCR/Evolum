"use client"

import { Card } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Avatar } from "@/components/ui/avatar"
import { posts } from "@/data/posts"
import { MessageCircleIcon, Share2Icon, HeartIcon } from "lucide-react"

export function RecentActivity() {
  return (
    <div className="space-y-4">
      <h2 className="font-semibold text-lg">Actividad reciente</h2>
      {posts.map((post) => (
        <Card key={post.id} className="p-4 space-y-2">
          <div className="flex items-center gap-2">
            <Avatar name={post.name} />
            <div>
              <p className="font-medium">{post.name}</p>
              <span className="text-xs text-zinc-500">
                {post.username} · {post.time}
              </span>
            </div>
          </div>
          <p className="text-sm">{post.content}</p>
          <Badge className="bg-purple-100 text-purple-700">{post.badge}</Badge>
          <div className="flex gap-4 text-sm text-zinc-600 mt-2">
            <div className="flex items-center gap-1"><HeartIcon className="w-4 h-4" />{post.likes}</div>
            <div className="flex items-center gap-1"><MessageCircleIcon className="w-4 h-4" />{post.comments}</div>
            <div className="flex items-center gap-1"><Share2Icon className="w-4 h-4" />{post.shares}</div>
          </div>
        </Card>
      ))}
    </div>
  )
}
