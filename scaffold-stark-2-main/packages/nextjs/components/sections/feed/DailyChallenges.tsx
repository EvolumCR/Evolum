import React from 'react';
import { Card } from '@/components/ui/card';
import { Brain, BookOpen, Activity } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface Challenge {
  id: string;
  title: string;
  description: string;
  reward: number;
  icon: React.ReactNode;
}

const challenges: Challenge[] = [
  {
    id: '1',
    title: 'Morning Meditation',
    description: 'Meditate for 10 minutes upon waking',
    reward: 50,
    icon: <Brain className="w-6 h-6 text-blue-500" />
  },
  {
    id: '2',
    title: 'Daily Reading',
    description: 'Read 20 pages of a personal development book',
    reward: 75,
    icon: <BookOpen className="w-6 h-6 text-purple-500" />
  },
  {
    id: '3',
    title: 'Physical Activity',
    description: 'Do 30 minutes of physical exercise',
    reward: 100,
    icon: <Activity className="w-6 h-6 text-green-500" />
  },
];

export function DailyChallenges() {
  return (
    <section>
      <h2 className="text-lg font-semibold">Daily Challenges</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {challenges.map(challenge => (
          <Card key={challenge.id} className="p-4 space-y-2">
            <div className="flex items-center gap-2">
              {challenge.icon}
              <span className="uppercase text-xs font-medium text-zinc-500">
                {challenge.title}
              </span>
            </div>
            <p className="text-sm text-zinc-700">{challenge.description}</p>
            <div className="flex justify-between items-center">
              <span className="text-sm font-semibold text-green-600">
                {challenge.reward} tokens
              </span>
              <Button>Start</Button>
            </div>
          </Card>
        ))}
      </div>
    </section>
  );
}
