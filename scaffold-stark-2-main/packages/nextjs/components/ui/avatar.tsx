import { cn } from "@/lib/utils"

export function Avatar({ name }: { name: string }) {
  return (
    <div
      className={cn("w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center text-sm font-medium")}
    >
      {name[0]}
    </div>
  )
}
