
declare function asTable(rows: any[][]): string
declare function asTable(objects: {[column: string]: any}[]): string
declare namespace asTable {
    interface Config<T> {
        maxTotalWidth: number
        minColumnWidths?: number[]
        delimiter?: string
        dash: string
        right: boolean
        print(value: T, key?: string | number): string
        title(value: string): string
    }
    type OmitPrint<T> = Pick<T, Exclude<keyof T, 'print'>> & {print: undefined}
    type ValidValueType<O, T> = {
      [P in keyof O]: T;
    }
    interface Formatter<T> extends Readonly<Config<T>> {
        (rows: T[][]): string
        <O extends ValidValueType<O, T>>(objects: O[]): string
        configure(cfg: Partial<OmitPrint<Config<any>>>): Formatter<T>
        configure<T>(cfg: Partial<Config<T>>): Formatter<T>
    }
    function configure<T = any>(cfg: Partial<Config<T>>): Formatter<T>
    const maxTotalWidth: number
    const print: StringConstructor
    const title: StringConstructor
    const dash: '-'
    const right: false
}

export = asTable
