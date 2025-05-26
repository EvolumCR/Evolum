import { DailyChallenges } from "@/components/sections/feed/DailyChallenges";
import { RecentActivity } from "@/components/sections/feed/RecentActivity";
import { UserSummary } from "@/components/sections/feed/UserSummary";
import { RecentAchievements } from "@/components/sections/feed/RecentAchievements";
import { Card } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Zap, Flame } from "lucide-react";

export default function FeedPage() {
  
  const tokens = 1250;
  const streak = 7;
  const completed = 3;
  const total = 4;
  const percent = Math.round((completed / total) * 100);

  return (
    <div className="p-6 space-y-6">
      {/* 1. Resumen superior */}
      <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {/* Tokens ganados */}
        <Card className="p-4 flex items-center gap-4">
          <Zap className="w-6 h-6 text-primary" />
          <div>
            <p className="text-xs text-zinc-500">Tokens ganados</p>
            <p className="text-xl font-semibold">{tokens.toLocaleString()}</p>
          </div>
        </Card>

        {/* Racha actual */}
        <Card className="p-4 flex items-center gap-4">
          <Flame className="w-6 h-6 text-primary" />
          <div>
            <p className="text-xs text-zinc-500">Racha actual</p>
            <p className="text-xl font-semibold">{streak} días</p>
          </div>
        </Card>

        {/* Progreso diario */}
        <Card className="p-4 space-y-2">
          <p className="text-xs text-zinc-500">Progreso diario</p>
          <Progress value={percent} className="h-2 rounded-full bg-gray-200/50" />
          <p className="text-sm">{`${completed} de ${total} hábitos completados hoy`}</p>
        </Card>
      </section>

      {/* 2. Contenido principal */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-2 space-y-6">
          {/* 2.1 Retos del día */}
          <DailyChallenges />

          {/* 2.2 Actividad reciente */}
          <RecentActivity />
        </div>

        <div className="space-y-6">
          {/* 2.3 Resumen de usuario */}
          <UserSummary />

          {/* 2.4 Logros recientes */}
          <RecentAchievements />
        </div>
      </div>
    </div>
  );
}
