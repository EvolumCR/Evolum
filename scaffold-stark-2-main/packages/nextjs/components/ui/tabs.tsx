// components/ui/tabs.tsx
import React, { createContext, useContext, useState } from 'react'
import { cn } from '@/lib/utils'

// Context carries raw string values
interface TabsContextValue {
  value: string
  setValue: (val: string) => void
}

const TabsContext = createContext<TabsContextValue>({
  value: '',
  setValue: () => {},
})

export interface TabsProps<V extends string = string>
  extends React.HTMLAttributes<HTMLDivElement> {
  /** Valor controlado de la pestaña */
  value?: V
  /** Valor inicial si no se controla */
  defaultValue?: V
  /** Callback cuando cambia la pestaña */
  onValueChange?: (val: V) => void
}

export function Tabs<V extends string = string>({
  value,
  defaultValue,
  onValueChange,
  children,
  className,
  ...props
}: TabsProps<V>) {
  // Estado interno infiere V si value/defaultValue se suministra
  const [current, setCurrent] = useState<V>(
    (defaultValue ?? (value as V) ?? ('' as V)) as V
  )

  return (
    <TabsContext.Provider
      value={{
        value: current,
        setValue: (val: string) => {
          // Actualiza interno y notifica con tipo V
          setCurrent(val as V)
          onValueChange?.(val as V)
        },
      }}
    >
      <div {...props} className={cn(className)}>
        {children}
      </div>
    </TabsContext.Provider>
  )
}

export interface TabsListProps extends React.HTMLAttributes<HTMLDivElement> {}
export function TabsList({ children, className, ...props }: TabsListProps) {
  return (
    <div
      {...props}
      className={cn('bg-gray-100 rounded-full flex', className)}
    >
      {children}
    </div>
  )
}

export interface TabsTriggerProps<V extends string = string>
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Valor asociado a esta pestaña */
  value: V
}
export function TabsTrigger<V extends string = string>(
  { value, children, className, ...props }: TabsTriggerProps<V>
) {
  const ctx = useContext(TabsContext)
  const selected = ctx.value === value
  return (
    <button
      {...props}
      onClick={() => ctx.setValue(value)}
      className={cn(
        'px-4 py-2 rounded-full text-sm focus:outline-none',
        selected ? 'bg-white text-gray-900 shadow' : 'text-gray-600',
        className
      )}
    >
      {children}
    </button>
  )
}
