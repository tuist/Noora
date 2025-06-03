
declare interface Location {

    line: number;
    column: number;
}

declare interface ResolvedLocation<FileType> extends Location {

    sourceFile: FileType;
    sourceLine: string;
    error?: Error;
}

declare interface File {

    path: string;
    text: string;
    lines: string[];
    error?: Error;
}

declare interface FileAsync extends File {
    resolve (location: Location): Promise<ResolvedLocation<FileAsync>>
}

declare interface FileSync extends File {
    resolve (location: Location): ResolvedLocation<FileSync>
}

declare interface FileCache<T> {

    resetCache (): void;
    getCache (): { [key: string]: T };
}

declare interface getSourceAsync extends FileCache<FileAsync> {
    (path: string): Promise<FileAsync>;
}

declare interface getSourceSync extends FileCache<FileSync> {
    (path: string): FileSync;
    async: getSourceAsync;
}

declare const getSource: getSourceSync;

export = getSource;
