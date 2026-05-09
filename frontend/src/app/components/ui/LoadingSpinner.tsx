import { cn } from './utils';

type LoadingSpinnerProps = {
  className?: string;
  size?: 'sm' | 'md' | 'lg';
  tone?: 'primary' | 'white' | 'muted';
};

const sizeClasses = {
  sm: 'h-4 w-4 border-2',
  md: 'h-7 w-7 border-2',
  lg: 'h-10 w-10 border-[3px]',
};

const toneClasses = {
  primary: 'border-[#008899]/25 border-t-[#008899]',
  white: 'border-white/35 border-t-white',
  muted: 'border-gray-200 border-t-gray-400',
};

export function LoadingSpinner({ className, size = 'md', tone = 'primary' }: LoadingSpinnerProps) {
  return (
    <span
      aria-label="Cargando"
      role="status"
      className={cn('inline-block animate-spin rounded-full', sizeClasses[size], toneClasses[tone], className)}
    />
  );
}

export function CenteredLoadingSpinner({ className, size = 'md', tone = 'primary' }: LoadingSpinnerProps) {
  return (
    <div className={cn('flex items-center justify-center py-8', className)}>
      <LoadingSpinner size={size} tone={tone} />
    </div>
  );
}
