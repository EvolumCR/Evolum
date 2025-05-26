// components/ui/card.tsx
import React from 'react'
import { cn } from '@/lib/utils'

export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {}
export function Card({ className, ...props }: CardProps) {
  return (
    <div
      {...props}
      className={cn(
        'bg-white rounded-2xl shadow',
        className
      )}
    />
  )
}

export interface CardHeaderProps extends React.HTMLAttributes<HTMLDivElement> {}
export function CardHeader({ className, ...props }: CardHeaderProps) {
  return <div {...props} className={cn('px-6 pt-6', className)} />
}

export interface CardTitleProps extends React.HTMLAttributes<HTMLHeadingElement> {}
export function CardTitle({ className, ...props }: CardTitleProps) {
  return <h3 {...props} className={cn('text-lg font-semibold', className)} />
}

export interface CardDescriptionProps extends React.HTMLAttributes<HTMLParagraphElement> {}
export function CardDescription({ className, ...props }: CardDescriptionProps) {
  return <p {...props} className={cn('text-sm text-zinc-500', className)} />
}

export interface CardContentProps extends React.HTMLAttributes<HTMLDivElement> {}
export function CardContent({ className, ...props }: CardContentProps) {
  return <div {...props} className={cn('p-6', className)} />
}

export interface CardFooterProps extends React.HTMLAttributes<HTMLDivElement> {}
export function CardFooter({ className, ...props }: CardFooterProps) {
  return <div {...props} className={cn('px-6 pb-6', className)} />
}
