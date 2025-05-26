import React from 'react'
import { cn } from '@/lib/utils'

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {}
export function Input({ className, ...props }: InputProps) {
  return (
    <input
      {...props}
      className={cn(
        'w-full rounded-lg border border-gray-300 px-4 py-2 transition focus:border-blue-500 focus:outline-none',
        className
      )}
    />
  )
}
