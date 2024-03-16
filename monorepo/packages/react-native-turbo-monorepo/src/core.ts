import { TurboMonorepo } from './TurboMonorepo';

export function multiply(a: number, b: number): Promise<number> {
  return TurboMonorepo.multiply(a, b);
}
