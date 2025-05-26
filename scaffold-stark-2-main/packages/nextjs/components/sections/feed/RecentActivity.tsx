import React from 'react';
import { Card } from '@/components/ui/card';
import { Clock, Heart, MessageCircle, Share2, MoreHorizontal } from 'lucide-react';

interface ActivityItem {
  id: string;
  name: string;
  username: string;
  time: string;
  content: string;
  badge: string;
  likes: number;
  comments: number;
  shares: number;
}

const activities: ActivityItem[] = [
  {
    id: '1',
    name: 'María García',
    username: '@mariagarcia',
    time: '2 hours ago',
    content: 'Today I completed my 30-day meditation streak! 🧘‍♀️ I can really feel a difference in my stress levels and focus.',
    badge: 'Meditation Master',
    likes: 24,
    comments: 5,
    shares: 2
  },
  {
    id: '2',
    name: 'Carlos Rodríguez',
    username: '@carlosr',
    time: '5 hours ago',
    content: 'I reduced my screen time by 30% this week and replaced it with reading. I’ve already finished my second book of the month. 📚',
    badge: 'Avid Reader',
    likes: 18,
    comments: 7,
    shares: 1
  },
];


export function RecentActivity() {
  return (
    <section>
      <h2 className="text-lg font-semibold">Recent activity</h2>
      <div className="space-y-4">
        {activities.map(item => (
          <Card key={item.id} className="p-4 space-y-2">
            <div className="flex justify-between">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center">{item.name[0]}</div>
                <div>
                  <p className="font-semibold">{item.name}</p>
                  <p className="text-xs text-zinc-500">{item.username} · <Clock className="inline w-4 h-4" /> {item.time}</p>
                </div>
              </div>
              <MoreHorizontal className="w-5 h-5 text-zinc-400 cursor-pointer" />
            </div>
            <p>{item.content}</p>
            <span className="inline-block bg-indigo-100 text-indigo-700 px-2 py-0.5 rounded-full text-xs">{item.badge}</span>
            <div className="flex items-center gap-4 mt-2 text-zinc-500">
              <Heart className="w-5 h-5" /><span>{item.likes}</span>
              <MessageCircle className="w-5 h-5" /><span>{item.comments}</span>
              <Share2 className="w-5 h-5" /><span>{item.shares}</span>
            </div>
          </Card>
        ))}
      </div>
    </section>
  );
}
