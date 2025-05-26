import React from 'react';
import { Card } from '@/components/ui/card';
import { Trophy } from 'lucide-react';

interface Achievement {
  id: string;
  title: string;
  description: string;
  icon: React.ReactNode;
}

const achievements: Achievement[] = [
  {
    id: '1',
    title: 'Early Riser',
    description: 'Complete a habit before 8 AM for 5 days',
    icon: <Trophy className="w-6 h-6 text-yellow-500" />
  },
  {
    id: '2',
    title: 'Clear Mind',
    description: 'Meditate for 10 consecutive days',
    icon: <Trophy className="w-6 h-6 text-blue-500" />
  },
  {
    id: '3',
    title: 'Avid Reader',
    description: 'Read for 30 minutes each day for 7 days straight',
    icon: <Trophy className="w-6 h-6 text-purple-500" />
  },
];

export function RecentAchievements() {
  return (
    <section>
      <h2 className="text-lg font-semibold">Recent Achievements</h2>
      <div className="flex flex-col space-y-4">
        {achievements.map(a => (
          <Card key={a.id} className="p-4 flex items-center gap-4">
            {a.icon}
            <div>
              <p className="font-medium">{a.title}</p>
              <p className="text-xs text-zinc-500">{a.description}</p>
            </div>
          </Card>
        ))}
      </div>
    </section>
  );
}
