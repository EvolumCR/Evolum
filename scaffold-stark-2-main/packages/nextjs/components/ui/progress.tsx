
import * as React from "react";
import { cn } from "@/lib/utils";

export interface ProgressProps extends React.HTMLAttributes<HTMLDivElement> {
  value: number;
}

const Progress = React.forwardRef<HTMLDivElement, ProgressProps>(
  ({ className, value, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          "relative w-full overflow-hidden rounded-full bg-gray-200 shadow-inner",
          className
        )}
        {...props}
      >
        <div
          className="
            h-3                             
            bg-gradient-to-r               
            from-indigo-500
            via-purple-500
            to-pink-500
            rounded-full                   
            transition-all
            duration-500
            ease-out
          "
          style={{ width: `${value}%` }}
        />
      </div>
    );
  }
);

Progress.displayName = "Progress";

export { Progress };
