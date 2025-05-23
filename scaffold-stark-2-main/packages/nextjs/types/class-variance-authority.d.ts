declare module "class-variance-authority" {
    export type VariantProps<T> = Record<string, any>;
    export function cva(
      base?: string,
      config?: {
        variants?: Record<string, Record<string, string>>;
        defaultVariants?: Record<string, string>;
      }
    ): (props?: Record<string, string>) => string;
  }
  